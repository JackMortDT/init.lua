local config = {}

local function greeting()
  local hour = tonumber(os.date("%H"))
  if hour < 12 then
    return "Good morning, Sastré 🦎"
  elseif hour < 19 then
    return "Good afternoon, Sastré 🦎"
  else
    return "Good evening, Sastré 🦎"
  end
end

local dt_greeting = os.date("%Y-%m-%d %H:%M:%S") .. "  ·  " .. greeting()

-- Each sprite "pixel" is a fullwidth emoji (~2 cols), so a digimon needs
-- roughly (#art[1] * 2) columns and (#art + a few) lines to look right.
-- In a narrow tmux split there's no room for that, so fall back to a
-- plain text header instead of a squashed/wrapped sprite.
local digimons = require("jack.digimons").digimons

local function fits_screen(candidate)
  local needed_cols = vim.fn.strwidth(candidate.art[1]) + 4
  local needed_lines = #candidate.art + 10
  return vim.o.columns >= needed_cols and vim.o.lines >= needed_lines
end

local candidates = vim.tbl_filter(fits_screen, digimons)
local pool = #candidates > 0 and candidates or digimons

-- os.time() alone is too coarse and the first math.random() draw right
-- after seeding is weakly distributed for small ranges, so mix in
-- hrtime (nanoseconds) and throw away a few warm-up draws.
math.randomseed(os.time() + (vim.uv or vim.loop).hrtime())
math.random()
math.random()
math.random()
local digimon = pool[math.random(#pool)]

config.project = { enable = false }
config.mru = { enable = false }
config.week_header = { enable = false }

local fits = vim.fn.strwidth(digimon.art[1]) + 4 <= vim.o.columns
  and #digimon.art + 10 <= vim.o.lines

config.header = fits
  and vim.list_extend(vim.deepcopy(digimon.art), { "", dt_greeting })
  or { "", dt_greeting, "" }

config.shortcut = {
    {
        desc = " 󰱼  File ",
        action = "Telescope find_files find_command=rg,--hidden,--files",
        group = "@string",
        key = "fF",
    },
    {
        desc = "   Update ",
        action = "Lazy sync",
        group = "@string",
        key = "u",
    },
    {
        desc = " 󰓅  Profile ",
        action = "Lazy profile",
        group = "@string",
        key = "p",
    },
    {
        desc = " 󰅙  Quit ",
        action = "q!",
        group = "DiagnosticError",
        key = "q",
    },
}

local function stats_line(stats)
  return string.format(
    "HP %d · MP %d · OFF %d · DEF %d · SPD %d · BRN %d",
    stats.hp,
    stats.mp,
    stats.offense,
    stats.defense,
    stats.speed,
    stats.brains
  )
end

local function footer()
  local lazy_stats = require("lazy").stats()
  local ms = math.floor(lazy_stats.startuptime * 100 + 0.5) / 100

  local lines = {
    "",
    fits and digimon.catchphrase or ("⚡ " .. digimon.name .. " is out there somewhere"),
  }
  if fits and digimon.stats then
    table.insert(lines, stats_line(digimon.stats))
  end
  table.insert(lines, "")
  table.insert(lines, string.format("⚡ %d/%d plugins · %sms", lazy_stats.loaded, lazy_stats.count, ms))
  return lines
end

config.footer = footer
config.packages = { enable = false }

require("dashboard").setup({
    theme = "hyper",
    config = config,
})
