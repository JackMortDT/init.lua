return {
  "nvimdev/dashboard-nvim",
  -- Not lazy: it has to claim the first buffer before anything else opens
  -- one, and `event = "VimEnter"` alone lands too late for that.
  lazy = false,
  priority = 999,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
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

    -- The session partner, not a fresh roll: whatever shows up here is the
    -- same one :Digimon and the statusline report. nil when
    -- ~/.config/digimons is missing or empty -- the sprites live in the
    -- dotfiles repo, so this has to survive without them.
    local partner = require("jack.digimons.partner")
    local digimon = partner.get()

    -- The partner falls back to the full roster when nothing fits the
    -- window, so a sprite that was picked may still be too big to draw.
    -- In a narrow tmux split, show a plain text header instead of a
    -- squashed one.
    local fits = partner.fits(digimon)

    config.project = { enable = false }
    config.mru = { enable = false }
    config.week_header = { enable = false }

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
        desc = (partner.icon() ~= "" and partner.icon() .. "  " or " 󰄛  ") .. "Partner ",
        action = "Digimon",
        group = "@string",
        key = "d",
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

    config.footer = function()
      local lazy_stats = require("lazy").stats()
      local ms = math.floor(lazy_stats.startuptime * 100 + 0.5) / 100

      local lines = { "" }
      -- Three cases, not two: the sprite fits, it does not fit but we know
      -- who it is, or there are no sprites installed at all and the footer
      -- just says nothing about Digimon.
      if fits and digimon.catchphrase then
        table.insert(lines, digimon.catchphrase)
      elseif digimon then
        table.insert(lines, "⚡ " .. digimon.name .. " is out there somewhere")
      end
      if fits and digimon.stats then
        table.insert(lines, stats_line(digimon.stats))
      end
      table.insert(lines, "")
      table.insert(lines, string.format("⚡ %d/%d plugins · %sms", lazy_stats.loaded, lazy_stats.count, ms))
      return lines
    end

    config.packages = { enable = false }

    require("dashboard").setup({
      theme = "hyper",
      config = config,
    })
  end,
}
