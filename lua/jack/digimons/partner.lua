-- The session's digimon partner.
--
-- jack.digimons is the loader; this is the one that gets picked when nvim
-- starts and then sticks around. The dashboard asks for it rather than
-- rolling its own, so the sprite on the start screen and the name in the
-- statusline always agree.
local digimons = require("jack.digimons")

local M = {}

local partner = nil
local picked = false

-- Each sprite "pixel" is a fullwidth emoji (~2 cols), so a digimon needs
-- roughly (#art[1] * 2) columns and (#art + a few) lines to look right.
function M.fits(candidate)
  if not candidate then
    return false
  end
  return vim.o.columns >= vim.fn.strwidth(candidate.art[1]) + 4
    and vim.o.lines >= #candidate.art + 10
end

-- Prefers a sprite that fits the current window, but falls back to the
-- whole roster rather than returning nothing in a narrow tmux split.
local function pick()
  local candidates = vim.tbl_filter(M.fits, digimons.digimons)
  local pool = #candidates > 0 and candidates or digimons.digimons
  if #pool == 0 then
    return nil
  end
  math.randomseed(os.time() + (vim.uv or vim.loop).hrtime())
  math.random()
  math.random()
  math.random()
  return pool[math.random(#pool)]
end

-- nil when ~/.config/digimons is missing or empty. Every caller has to
-- cope: the sprites live in the dotfiles repo, not in here.
function M.get()
  if not picked then
    partner = pick()
    picked = true
  end
  return partner
end

function M.reroll()
  partner = pick()
  picked = true
  return partner
end

-- The catchphrase starts with an emoji ("🦖 Agumon warp digivolve to..."),
-- which doubles as the partner's icon.
function M.icon()
  local p = M.get()
  if not p or not p.catchphrase then
    return ""
  end
  return p.catchphrase:match("^(%S+)") or ""
end

--------------------------------------------------------------------------
-- Live stats
--------------------------------------------------------------------------

local function diagnostic_damage()
  local counts = vim.diagnostic.count()
  local errors = counts[vim.diagnostic.severity.ERROR] or 0
  local warns = counts[vim.diagnostic.severity.WARN] or 0
  return errors * 10 + warns * 2, errors, warns
end

local function git_churn()
  local added, removed = 0, 0
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local dict = vim.b[info.bufnr].gitsigns_status_dict
    if dict then
      added = added + (dict.added or 0) + (dict.changed or 0)
      removed = removed + (dict.removed or 0)
    end
  end
  return added, removed
end

---@return table[] list of { label, value, note }
function M.stats()
  local p = M.get()
  if not p then
    return {}
  end

  local base = p.stats or {}
  local damage, errors, warns = diagnostic_damage()
  local max_hp = base.hp or 0
  local hp = math.max(0, max_hp - damage)
  local added, removed = git_churn()
  local lazy = require("lazy").stats()

  local bar = ""
  if max_hp > 0 then
    local filled = math.floor((hp / max_hp) * 10 + 0.5)
    bar = ("█"):rep(filled) .. ("▁"):rep(10 - filled)
  end

  return {
    {
      label = "HP",
      value = ("%d/%d"):format(hp, max_hp),
      note = ("%s  %d errors, %d warnings"):format(bar, errors, warns),
    },
    {
      label = "MP",
      value = tostring(base.mp or 0),
      note = ("%d LSP client(s)"):format(#vim.lsp.get_clients()),
    },
    {
      label = "OFF",
      value = ("+%d"):format(added),
      note = "lines added (unstaged)",
    },
    {
      label = "DEF",
      value = ("-%d"):format(removed),
      note = "lines removed (unstaged)",
    },
    {
      label = "SPD",
      value = ("%dms"):format(math.floor(lazy.startuptime + 0.5)),
      note = "startup",
    },
    {
      label = "BRN",
      value = tostring(base.brains or 0),
      note = ("%d/%d plugins loaded"):format(lazy.loaded, lazy.count),
    },
  }
end

--------------------------------------------------------------------------
-- The :Digimon float
--------------------------------------------------------------------------

local function build_lines()
  local p = M.get()
  local stats = M.stats()

  -- Sprite on the left, name and stats on the right. The sprite is padded
  -- to a rectangle already, so art[1] is as wide as any other row.
  local art = p.art
  local art_width = vim.fn.strwidth(art[1])
  local rows = math.max(#art, #stats + 2)
  local lines = {}

  local right = { p.name, "" }
  for _, s in ipairs(stats) do
    table.insert(right, ("%-4s %-10s %s"):format(s.label, s.value, s.note))
  end

  for i = 1, rows do
    local left = art[i] or (" "):rep(art_width)
    -- strwidth-aware padding: the emoji cells are not one column each.
    local pad = art_width - vim.fn.strwidth(left)
    table.insert(lines, left .. (" "):rep(math.max(0, pad)) .. "   " .. (right[i] or ""))
  end

  table.insert(lines, "")
  table.insert(lines, p.catchphrase or "")
  return lines
end

function M.show()
  local p = M.get()
  if not p then
    vim.notify(
      "No digimon sprites found in " .. digimons.dir .. " (they live in the dotfiles repo)",
      vim.log.levels.WARN
    )
    return
  end

  local lines = build_lines()
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strwidth(line))
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "digimon"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.min(width + 2, vim.o.columns - 4),
    height = math.min(#lines, vim.o.lines - 4),
    row = math.floor((vim.o.lines - #lines) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    -- border comes from the global `winborder` in options.lua
    title = " " .. p.name .. " ",
    title_pos = "center",
  })
  vim.wo[win].wrap = false

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf, nowait = true, silent = true })
  end
end

--------------------------------------------------------------------------
-- Digivolve
--------------------------------------------------------------------------

-- Fires the catchphrase when a buffer goes from "has errors" to "clean".
-- Tracked per buffer so it only celebrates an actual transition, not every
-- DiagnosticChanged on an already-clean file.
local had_errors = {}

local function on_diagnostics_changed(args)
  local buf = args.buf
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
    return
  end

  local errors = vim.diagnostic.count(buf)[vim.diagnostic.severity.ERROR] or 0

  if errors > 0 then
    had_errors[buf] = true
  elseif had_errors[buf] then
    had_errors[buf] = nil
    local p = M.get()
    if p and p.catchphrase then
      vim.notify(p.catchphrase, vim.log.levels.INFO, { title = "Digivolve!" })
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("jack_digimon_partner", { clear = true })

  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = group,
    callback = on_diagnostics_changed,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      had_errors[args.buf] = nil
    end,
  })

  vim.api.nvim_create_user_command("Digimon", function(opts)
    if opts.args == "reroll" then
      local p = M.reroll()
      vim.notify(p and ("Your partner is now " .. p.name) or "No sprites available")
      require("jack.utils").refresh_statusline()
    else
      M.show()
    end
  end, {
    nargs = "?",
    complete = function()
      return { "reroll" }
    end,
    desc = "Show the session's digimon partner",
  })

  -- Not under <leader>p: that group is plugin management (Lazy, Mason),
  -- and this isn't a plugin.
  vim.keymap.set("n", "<leader>d", M.show, { desc = "Digimon partner" })
end

return M
