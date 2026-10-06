-- Markers that say "a self-contained project starts here". `src` carries
-- most of the weight: subprojects in a Scala/sbt monorepo often contain
-- nothing but `src/` and `target/`.
local PROJECT_MARKERS = {
  "src",
  "build.sbt",
  "project.clj",
  "deps.edn",
  "pom.xml",
  "build.gradle",
  "package.json",
  "Cargo.toml",
  "pyproject.toml",
}

-- The innermost project containing the current buffer, clamped to the
-- editor's cwd so it can never wander off above the repo.
--
-- Why this exists: in a monorepo, grepping from the repo root is not a
-- nicety, it's the difference between working and not. Measured on a
-- ~115k-file monorepo: a content search costs ~2.85s from the root versus
-- ~51ms inside one subproject, and live_grep re-runs ripgrep on every
-- keystroke.
--
-- In a single-project repo this returns the repo root, so the scoped and
-- unscoped pickers are the same thing and nothing changes.
local function project_root()
  local cwd = vim.uv.cwd()
  local buf = vim.api.nvim_buf_get_name(0)

  -- No real file (dashboard, a picker, a scratch buffer): nothing to scope to.
  if buf == "" or vim.bo.buftype ~= "" then
    return cwd
  end

  local found = vim.fs.root(buf, PROJECT_MARKERS)
  if not found then
    return cwd
  end

  -- vim.fs.root walks to the filesystem root; reject anything that isn't
  -- inside the cwd (a stray `src/` in a parent directory, say).
  local rel = vim.fs.relpath(cwd, found)
  if not rel then
    return cwd
  end
  return found
end

local TITLES = { find_files = "Files", live_grep = "Grep" }

-- Shows which scope a picker is using, since otherwise "no results" is
-- ambiguous between "not in this subproject" and "not in the repo". The
-- directory's own name identifies the project; the path leading to it is
-- noise in a narrow prompt.
local function scoped(builtin, opts)
  return function()
    local root = project_root()
    require("telescope.builtin")[builtin](vim.tbl_extend("force", {
      cwd = root,
      prompt_title = ("%s  ·  %s"):format(TITLES[builtin] or builtin, vim.fn.fnamemodify(root, ":t")),
    }, opts or {}))
  end
end

local function repo_wide(builtin)
  return function()
    local cwd = vim.uv.cwd()
    require("telescope.builtin")[builtin]({
      cwd = cwd,
      prompt_title = ("%s  ·  all of %s"):format(TITLES[builtin] or builtin, vim.fn.fnamemodify(cwd, ":t")),
    })
  end
end

return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-frecency.nvim",
  },
  keys = {
    -- Scoped to the innermost project around the current file; identical to
    -- the repo-wide pair in a single-project repo.
    { "<leader>ff", scoped("find_files"), desc = "Find files (this project)" },
    { "<leader>fg", scoped("live_grep"),  desc = "Live grep (this project)" },
    { "<leader>fA", repo_wide("find_files"), desc = "Find files (whole repo)" },
    { "<leader>fG", repo_wide("live_grep"),  desc = "Live grep (whole repo)" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end,  desc = "Help tags" },
    { "<leader>fr", function() require("telescope.builtin").oldfiles() end,   desc = "Recent files" },
    { "<leader>fe", "<cmd>Telescope file_browser<cr>",                        desc = "File browser" },
    { "<leader>fF", function() require("telescope").extensions.frecency.frecency() end, desc = "Frecency" },
    -- Diagnostics as a fuzzy picker: good for "jump to that one error I
    -- half remember". Trouble (<leader>xx) is the persistent list.
    -- Global rather than buffer-local on LspAttach: vim.diagnostic is not
    -- LSP-only, and the key should exist even with no client attached.
    { "<leader>xt", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics (picker)" },
    { "gs",         function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics (picker)" },
  },
  config = function()
    local TS = require("telescope")
    local actions = require("telescope.actions")
    local U = require("jack.utils")

    local prompt_chars = U.border_chars_telescope_default
    local vert_preview_chars = U.border_chars_telescope_default
    local borderchars = {
      prompt = prompt_chars,
      preview = vert_preview_chars,
      results = U.get_border_chars("telescope"),
    }

    -- Registers are short and need no preview, so give them a small square.
    local picker_register = {
      sort_mru = true,
      preview = false,
      wrap_results = false,
      layout_config = {
        height = 0.6,
        width = 0.6,
      },
    }

    -- LSP jumps usually have few results but benefit from a preview, so
    -- they get a narrower window than the default full-height one.
    local small_lsp_layout = {
      layout_strategy = "vertical",
      preview_title = "",
      preview = true,
      wrap_results = false,
      layout_config = {
        height = 0.85,
        width = 0.65,
        mirror = true,
      },
      borderchars = borderchars,
    }

    local defaults = {
      layout_strategy = "vertical",
      preview_title = "",
      dynamic_preview_title = false,

      layout_config = {
        prompt_position = "top",
        mirror = true,
        preview_height = 0.55,
        height = 0.95,
        width = 0.85,
      },
      borderchars = borderchars,

      sort_mru = true,
      sorting_strategy = "ascending",
      border = true,
      multi_icon = "",
      entry_prefix = "   ",
      prompt_prefix = "   ",
      selection_caret = "  ",
      hl_result_eol = true,
      results_title = "",
      winblend = 0,
      wrap_results = true,
      mappings = {
        i = {
          ["<Esc>"] = actions.close,
          ["<C-Esc>"] = actions.close,
        },
      },
    }

    TS.setup({
      defaults = defaults,
      extensions = {
        ["ui-select"] = {
          layout_strategy = "vertical",
          preview_title = "",
          preview = false,
          wrap_results = false,
          layout_config = {
            height = function(_, _, max_lines)
              return math.min(max_lines, 15)
            end,
            width = 0.5,
          },
          borderchars = borderchars,
        },
        file_browser = {
          hijack_netrw = true,
          grouped = true,
          layout_config = defaults.layout_config,
          borderchars = defaults.borderchars,
        },
        frecency = {
          show_scores = false,
          show_unindexed = true,
          ignore_patterns = { "*.git/*", "*/tmp/*" },
          layout_config = defaults.layout_config,
          borderchars = defaults.borderchars,
        },
      },
      pickers = {
        diagnostics = { sort_by = "severity", preview_title = "" },
        registers = picker_register,

        lsp_definitions = small_lsp_layout,
        lsp_references = small_lsp_layout,
        lsp_implementations = small_lsp_layout,

        live_grep = { preview_title = "" },
        help_tags = {
          preview_title = "",
          mappings = { i = { ["<CR>"] = actions.select_vertical } },
        },
        oldfiles = { preview_title = "" },
        find_files = { preview_title = "" },
        lsp_document_symbols = { preview_title = "" },
        man_pages = {
          preview_title = "",
          mappings = { i = { ["<CR>"] = actions.select_vertical } },
        },
      },
    })

    -- pcall: a missing native build (fzf) or an extension that failed to
    -- install shouldn't take the whole picker down.
    pcall(TS.load_extension, "fzf")
    pcall(TS.load_extension, "ui-select")
    pcall(TS.load_extension, "file_browser")
    pcall(TS.load_extension, "frecency")

    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("jack_telescope", { clear = true }),
      pattern = "TelescopePreviewerLoaded",
      callback = function()
        vim.opt_local.number = true
      end,
    })
  end,
}
