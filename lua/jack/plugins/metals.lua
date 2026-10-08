-- Scala via Metals.
--
-- Deliberately NOT routed through mason-lspconfig: nvim-metals installs and
-- launches the server itself and sets up its own LSP client, and having
-- lspconfig also start one gives you two clients fighting over the same
-- buffer. plugins/lsp.lua excludes `metals` from automatic_enable for this.
--
-- Build server: Bloop (Metals' default), not sbt BSP.
--
-- This is the opposite of what you'd want on paper. sbt BSP compiles per
-- target on demand, while Bloop makes sbt export every project in the
-- build to .bloop/ up front, which on a large multi-module build is a
-- real cost. But sbt BSP does not work against sbt 1.4.x, which is what
-- the monorepo I need this for pins, so Bloop it is.
--
-- Flip it per-machine without editing this file:
--     vim.g.jack_metals_sbt_bsp = true
--
-- Caveat: letting Metals run the Bloop export in the background can hang
-- nvim on a build that size. Generate it from a terminal instead, where
-- you can watch it:
--     sbt bloopInstall          # after Metals has written project/metals.sbt
-- then restart the build server.
--
-- Under v2 (below) a build server is optional: first-party navigation
-- comes from v2's own index and needs no build at all. It is still what
-- resolves third-party dependencies, tests and debugging, so these
-- settings keep mattering the moment you connect one. Note that Metals
-- connects to -- or starts -- a build server regardless; removing the
-- export directory only makes it connect to an empty one.
local M = {}

-- Keyed by jdk+pin so each project warns at most once per session.
local warned = {}

-- Reads the JDK a project pins, if it says. A project committing
-- `.java-version` usually means it, and running the wrong JDK against an
-- old toolchain causes JVM crashes rather than clean errors -- worth
-- checking instead of silently using whatever is around.
local function pinned_jdk(from)
  local found = vim.fs.find(".java-version", {
    path = from,
    upward = true,
    type = "file",
  })[1]
  if not found then
    return nil
  end
  local lines = vim.fn.readfile(found)
  return lines[1] and vim.trim(lines[1]) or nil
end

local function major(version)
  if not version then
    return nil
  end
  return version:match("^1%.(%d+)") or version:match("^(%d+)")
end

-- The major version of an install, verified from the install itself.
-- Necessary because `/usr/libexec/java_home -v 1.8` on this machine exits 0
-- and hands back a JDK 26, so asking politely is not enough.
--
-- Two mechanisms, because the `release` file only arrived with JDK 9's
-- modular runtime -- a JDK 8 install simply has no such file and would be
-- invisible otherwise. `jre/lib/rt.jar` is the complement: the monolithic
-- runtime jar JDK 9 removed, so its presence means 8 and nothing else.
local function installed_major(home)
  local release = home .. "/release"
  if vim.fn.filereadable(release) == 1 then
    for _, line in ipairs(vim.fn.readfile(release)) do
      local v = line:match('^JAVA_VERSION="([^"]+)"')
      if v then
        return major(v)
      end
    end
  end

  if vim.fn.filereadable(home .. "/jre/lib/rt.jar") == 1 then
    return "8"
  end

  return nil
end

-- Distributions worth preferring, best first. `jbr` is JetBrains Runtime --
-- it ships with IntelliJ and is built for running the IDE, not as a general
-- build JDK, so it loses to anything else even though it sorts earlier.
local DISTRO_RANK = { tem = 1, temurin = 1, corretto = 2, zulu = 3, amzn = 2, librca = 4, jbr = 99 }

local function distro_rank(dir)
  local suffix = dir:match("-([%a]+)$")
  return (suffix and DISTRO_RANK[suffix:lower()]) or 50
end

-- Every JDK install this machine can offer, grouped by verified major
-- version. `java_home` is asked but never trusted -- see installed_major.
local function jdks_by_major()
  local homes = {}
  for _, version in ipairs({ "1.8", "11", "17", "21" }) do
    local out = vim.fn.system({ "/usr/libexec/java_home", "-v", version })
    if vim.v.shell_error == 0 then
      table.insert(homes, { path = vim.trim(out), rank = 0 })
    end
  end

  local sdkman = vim.fn.expand("~/.sdkman/candidates/java")
  if vim.fn.isdirectory(sdkman) == 1 then
    for _, dir in ipairs(vim.fn.readdir(sdkman)) do
      if dir ~= "current" then
        table.insert(homes, { path = sdkman .. "/" .. dir, rank = distro_rank(dir) })
      end
    end
  end

  local by_major = {}
  for _, home in ipairs(homes) do
    local m = installed_major(home.path)
    if m then
      by_major[m] = by_major[m] or {}
      table.insert(by_major[m], home)
    end
  end
  return by_major
end

-- First match walking `order`, best distribution first within a version.
local function pick(by_major, order)
  for _, version in ipairs(order) do
    local found = by_major[version]
    if found then
      table.sort(found, function(a, b)
        return a.rank < b.rank
      end)
      return found[1].path
    end
  end
  return nil
end

-- Resolve a JDK for the *build server*. sbt 1.4.x supports JDK 8 and 11
-- only -- anything newer makes its internal Scala 2.12.12 fail to read
-- class files ("bad constant pool index") before the build even starts.
---@param want string|nil  preferred major version ("8"), else 8 then 11
function M.find_build_jdk(want)
  local order = want and { want, want == "8" and "11" or "8" } or { "8", "11" }
  return pick(jdks_by_major(), order)
end

-- Resolve a JDK for the *Metals server process*, which needs 17+.
--
-- This exists because the two requirements conflict: the build needs an
-- old JDK, Metals needs a new one, and nvim inherits whatever the shell
-- that launched it had. Open nvim from a shell switched to JDK 11 for sbt
-- and Metals dies on startup. Pinning it here via cmd_env means the shell
-- no longer matters.
function M.find_server_jdk()
  return pick(jdks_by_major(), { "21", "17", "25", "26" })
end

-- The JDK an existing Bloop export was generated with.
--
-- `sbt bloopInstall` bakes whatever JVM it ran under into every config it
-- writes, as `platform.config.home`, and that is the JDK Bloop will
-- actually compile with. If Metals is told a different one it pops "Java
-- home has been updated, do you want to reconnect to the BSP server?" on
-- every start, and accepting changes the compile setup Zinc keys its
-- incremental analysis on -- which throws away every target compiled so
-- far. Seen here: 446 configs exported under JDK 11 against a repo
-- pinning 1.8 in .java-version.
--
-- So when an export exists it outranks the pin: it is a fact about what
-- will run, where the pin is only an intention. Disagreement is reported
-- rather than silently resolved -- the way to change it is to re-run
-- `sbt bloopInstall` under the JDK you want.
--
-- Only `.bloop` counts, never a parked copy; if it is not there, Metals
-- will not be reading it either. The configs carry the full classpath and
-- run to half a megabyte of pretty-printed JSON, so this matches on the
-- text rather than parsing it -- `home` appears only under
-- platform.config and its identical runtimeConfig twin. The whole file
-- has to be read regardless: the key sits wherever the classpath above it
-- ends, line 632 of 8847 in the one measured here. Cached per export so
-- opening fifty Scala buffers reads it once.
---@param from string  path to search upward from
local bloop_cache = {}
local function bloop_jdk(from)
  local dir = vim.fs.find(".bloop", { path = from, upward = true, type = "directory" })[1]
  if not dir then
    return nil
  end
  if bloop_cache[dir] ~= nil then
    return bloop_cache[dir] or nil
  end

  local found = false
  local config = vim.fn.glob(dir .. "/*.json", false, true)[1]
  if config then
    local home = table.concat(vim.fn.readfile(config), "\n"):match('"home"%s*:%s*"([^"]+)"')
    if home and vim.fn.isdirectory(home) == 1 and installed_major(home) then
      found = home
    end
  end
  bloop_cache[dir] = found
  return found or nil
end

-- Returns the JDK path plus whether it satisfies the project's pin, so the
-- caller can say something useful instead of failing twenty minutes into an
-- import.
-- Resolved from the buffer's own path, not the editor's cwd.
--
-- cwd is the wrong anchor: it changes as you move around, so the same
-- project would resolve a different javaHome depending on where you
-- happened to be, Metals would notice the setting change and pop
-- "Java home has been updated, do you want to restart the sbt BSP
-- server?" on every switch. The buffer's path is stable for a given file
-- and is also how Metals itself finds the project root.
---@param from string|nil  path to resolve the pin from; defaults to the buffer
---@return string|nil jdk, string|nil pin, boolean matches, string source
function M.build_jdk(from)
  from = from or vim.api.nvim_buf_get_name(0)
  if from == "" then
    from = vim.fn.getcwd()
  end
  local pin = pinned_jdk(from)
  local want = major(pin)

  local exported = bloop_jdk(from)
  local path = exported or M.find_build_jdk(want)
  if not path then
    return nil, pin, false, "none"
  end
  return path, pin, want == nil or installed_major(path) == want, exported and "export" or "pin"
end

function M.config()
  local metals = require("metals")
  local config = metals.bare_config()

  local jdk, pin, matches, source = M.build_jdk()

  -- Once per project per session. This fires from a FileType autocmd, so
  -- without the guard it would repeat on every Scala buffer you open --
  -- useful the first time, noise the fiftieth. `:MetalsJdk` reprints it.
  local key = (jdk or "none") .. "\0" .. (pin or "none")
  if not warned[key] then
    warned[key] = true
    if not jdk then
      vim.notify(
        "Metals: no JDK 8 or 11 found (sbt 1.4.x supports only those).",
        vim.log.levels.ERROR
      )
    elseif pin and not matches then
      vim.notify(
        ("Metals: JDK %s (from %s), project pins %s. :MetalsJdk"):format(
          vim.fn.fnamemodify(jdk, ":t"),
          source == "export" and ".bloop export" or "installed JDKs",
          pin
        ),
        vim.log.levels.WARN
      )
    end
  end

  -- Metals v2 (opt in with `vim.g.jack_metals_v2 = "2.0.0-M19"`).
  --
  -- v2 indexes sources directly instead of going through BSP, so core
  -- navigation works without importing the build at all. That matters on
  -- a large monorepo, where a v1 connect triggers a cascade compile over
  -- every build target -- by design, with no setting to disable it -- and
  -- a session closed before it finishes starts over next time.
  --
  -- nvim-metals is a supported editor for v2 and sbt needs no extra
  -- setup. The `--add-opens`/`--add-exports` flags v2 requires are
  -- already injected automatically by this version of the plugin.
  --
  -- What you give up: jump-to-definition into third-party library code,
  -- tests and debugging all still need a build server, and completions
  -- are thinner. It is also a milestone build -- upstream still calls v1
  -- the recommendation for smaller projects, so this stays opt-in.
  local v2 = vim.g.jack_metals_v2

  config.settings = {
    serverVersion = v2 or nil,
    -- See the note at the top: Bloop by default, sbt BSP opt-in.
    defaultBspToBuildTool = vim.g.jack_metals_sbt_bsp == true,
    showImplicitArguments = true,
    showInferredType = true,
    excludedPackages = {},
    javaHome = jdk,

    -- Bloop outlives the editor by default, and on a monorepo it does so
    -- holding multiple GB. Observed: a Bloop server orphaned by a previous
    -- nvim still resident at 6.6 GB with 0% CPU two and a half hours
    -- later, while a fresh one started alongside it. On 18 GB of RAM that
    -- stacks into swap death after two or three restarts.
    shutdownBloopOnEditorClose = true,

    -- Cap the build server's heap. Metals documents a default of
    -- ["-Xmx1G"], which is far too small for a build this size, but the
    -- server observed here was running with no -Xmx at all under ZGC and
    -- had grown to 6.6 GB. 4G is a compromise: enough for the dependency
    -- closure, small enough that two of them can't exhaust the machine.
    bloopJvmProperties = { "-Xmx4G", "-Xss4m" },
    -- Heap for the *build server* (sbt). The internal guide suggests 12G
    -- per project; that is set in .jvmopts at the repo root, not here.

    -- The Metals server process itself. v1 offloads the expensive work to
    -- the build server; v2 does the indexing in-process and the docs ask
    -- for more headroom.
    --
    -- This belongs *inside* settings, not next to it. nvim-metals wraps
    -- the whole table under a `metals` key and then reads
    -- `settings.metals.serverProperties`; a top-level
    -- `config.serverProperties` is read by nobody and silently does
    -- nothing, which is how a server ended up running with no -Xmx at all
    -- -- the -Xss4m and -Xms100m it did have come from the Coursier
    -- bootstrap, baked in at install time.
    --
    -- Merged after the plugin's own required VM options, so these win.
    -- Verify with
    --   ps -axo command | grep nvim-metals/metals | tr " " "\n" | grep Xmx
    -- after a restart.
    serverProperties = { v2 and "-Xmx6G" or "-Xmx3G", "-Xss4m" },
  }

  -- Pin the JVM the Metals server itself runs on, so it no longer depends
  -- on which shell launched nvim. This matters because the two JDK
  -- requirements pull in opposite directions: sbt 1.4.x needs 8 or 11,
  -- Metals v2 needs 17+. Without this, switching a terminal to JDK 11 to
  -- run tests and opening nvim from it kills the language server.
  --
  -- The Metals launcher is a /bin/sh script that invokes plain `java`, so
  -- prepending to PATH is what actually decides; JAVA_HOME is set too for
  -- anything downstream that reads it.
  local server_jdk = M.find_server_jdk()
  if server_jdk then
    config.cmd_env = vim.tbl_extend("force", config.cmd_env or {}, {
      JAVA_HOME = server_jdk,
      PATH = server_jdk .. "/bin:" .. (vim.env.PATH or ""),
    })

    -- cmd_env only covers the language server. nvim-metals downloads the
    -- server with Coursier through a plain `vim.system()` call that
    -- inherits nvim's own environment, and Coursier is compiled for JDK 17
    -- -- under an older JVM it dies with UnsupportedClassVersionError and
    -- all you see is "Something went wrong with the Metals install".
    --
    -- That happens as soon as the shell nvim was launched from is on an
    -- old JDK, which is exactly what a per-directory version manager does
    -- in a project pinning JDK 8. So fix nvim's own environment too.
    -- Nothing nvim spawns wants the old JDK: the build server gets its own
    -- via `javaHome`, and sbt is run from the terminal.
    if not vim.env.PATH:find(server_jdk .. "/bin", 1, true) then
      vim.env.JAVA_HOME = server_jdk
      vim.env.PATH = server_jdk .. "/bin:" .. (vim.env.PATH or "")
    end
  elseif v2 then
    vim.notify("Metals v2 needs a JDK 17+ to run on; none found.", vim.log.levels.ERROR)
  end

  config.capabilities = require("blink.cmp").get_lsp_capabilities()

  config.init_options.statusBarProvider = "off"

  config.on_attach = function(_, bufnr)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end
    map("<leader>mc", function() require("telescope").extensions.metals.commands() end, "Metals commands")
    map("<leader>mi", metals.import_build, "Import build")
    map("<leader>mr", metals.restart_build_server, "Restart build server")
    -- Which build server is connected decides whether third-party symbols
    -- resolve. On a repo with a build tool Metals picks Bloop, and Bloop
    -- without an export resolves nothing; MBT reads .metals/mbt.json and
    -- gives you the dependency classpath with no compile at all. The
    -- choice sticks, so this is a once-per-project key -- but it is the
    -- one that matters.
    map("<leader>mb", metals.switch_bsp, "Switch build server (Bloop/MBT/sbt)")
    map("<leader>ml", metals.toggle_logs, "Toggle Metals logs")
    map("<leader>mt", metals.type_of_range, "Type of range")
    map("<leader>mo", metals.organize_imports, "Organize imports")
  end

  return config
end

return {
  "scalameta/nvim-metals",
  dependencies = { "nvim-lua/plenary.nvim", "saghen/blink.cmp" },
  -- `ft` is the only trigger needed: every Metals keymap is buffer-local,
  -- applied from on_attach once the server is up.
  ft = { "scala", "sbt" },
  init = function()
    -- Trying Metals v2. Delete this line to go back to v1; the .bloop
    -- directory v1 built is left untouched either way.
    --
    -- M19 rather than the M2 the docs still name: it is the current
    -- release on Maven Central, and its META-INF/metals-required-vm-options
    -- matches the 24 flags this plugin version injects exactly, so there
    -- is nothing to patch up.
    vim.g.jack_metals_v2 = "2.0.0-M19"
  end,
  config = function()
    -- The startup warning is deliberately terse; this is where the whole
    -- story lives, on demand.
    vim.api.nvim_create_user_command("MetalsJdk", function()
      local jdk, pin, matches, source = M.build_jdk()
      local lines = {
        "Build JDK (what sbt/Bloop will run on):",
        "  " .. (jdk or "none found -- install JDK 8 or 11"),
        "  source: "
          .. (source == "export" and ".bloop export (platform.config.home)" or "installed JDKs, picked to match the pin"),
        "Project pin (.java-version):",
        "  " .. (pin or "none"),
        "",
        matches and "Match: ok" or "Match: NO",
      }
      if jdk and pin and not matches then
        vim.list_extend(lines, {
          "",
          "Compiling will most likely still work: scalac 2.12 defaults to",
          "-target:jvm-1.8, so the bytecode stays Java 8 regardless.",
          "The risk is running tests -- this build sets no --add-opens,",
          "which Spark needs for reflective access on JDK 11+.",
        })
        if source == "export" then
          vim.list_extend(lines, {
            "",
            "The export wins on purpose: it is what Bloop will compile with.",
            "Overriding it makes Metals ask to reconnect on every start, and",
            "accepting invalidates every target compiled so far.",
            "",
            "To change it: sdk use java " .. (pin or "<version>") .. " && sbt bloopInstall",
          })
        else
          vim.list_extend(lines, { "", "Fix: sdk install java 8.0.462-tem" })
        end
      end
      vim.notify(table.concat(lines, "\n"), matches and vim.log.levels.INFO or vim.log.levels.WARN)
    end, { desc = "Which JDK Metals will build with, and whether it matches the project" })

    local group = vim.api.nvim_create_augroup("jack_metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "scala", "sbt" },
      callback = function()
        require("metals").initialize_or_attach(M.config())
      end,
    })
  end,
}
