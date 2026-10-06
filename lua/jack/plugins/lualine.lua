return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "AlexvZyl/nordic.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local U = require("jack.utils")

    -- lualine's own mode names are wide enough to push the rest of the bar
    -- around; pin them all to six characters.
    local function fmt_mode(s)
      local mode_map = {
        ["COMMAND"] = "COMMND",
        ["V-BLOCK"] = "V-BLCK",
        ["TERMINAL"] = "TERMNL",
        ["V-REPLACE"] = "V-RPLC",
        ["O-PENDING"] = "0PNDNG",
      }
      return mode_map[s] or s
    end

    -- Theme dependant custom colors.
    local C = require("nordic.colors")
    local text_hl = { fg = C.gray3 }
    local icon_hl = { fg = C.gray4 }
    local green = C.green.base
    local red = C.red.base

    local function get_recording_color()
      if U.is_recording() then
        return { fg = red }
      end
      return text_hl
    end

    local function diff_source()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end

    local default_z = {
      {
        "searchcount",
        color = text_hl,
      },
      {
        "location",
        icon = { "", align = "left" },
        fmt = function(str)
          local fixed_width = 7
          return string.format("%" .. fixed_width .. "s", str)
        end,
      },
      {
        "progress",
        icon = { "", align = "left" },
        separator = { right = "", left = "" },
      },
    }

    local mode_section = {
      {
        "mode",
        fmt = fmt_mode,
        icon = { "" },
        separator = { right = " ", left = "" },
      },
    }

    -- Extensions: in neo-tree and Telescope the usual file/git components
    -- are meaningless, so swap section c for a single label.
    local tree = {
      sections = {
        lualine_a = mode_section,
        lualine_b = {},
        lualine_c = {
          {
            U.get_short_cwd,
            padding = 0,
            icon = { "   ", color = icon_hl },
            color = text_hl,
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = default_z,
      },
      filetypes = { "neo-tree" },
    }

    local telescope = {
      sections = {
        lualine_a = mode_section,
        lualine_b = {},
        lualine_c = {
          {
            function()
              return "Telescope"
            end,
            color = text_hl,
            icon = { "  ", color = icon_hl },
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = default_z,
      },
      filetypes = { "TelescopePrompt" },
    }

    require("lualine").setup({
      sections = {
        lualine_a = mode_section,
        lualine_b = {},
        lualine_c = {
          {
            "branch",
            color = text_hl,
            icon = { " ", color = icon_hl },
            padding = 2,
          },
          {
            "diff",
            color = text_hl,
            source = diff_source,
            symbols = {
              added = " ",
              modified = " ",
              removed = " ",
            },
            diff_color = {
              added = icon_hl,
              modified = icon_hl,
              removed = icon_hl,
            },
            padding = 1,
          },
          {
            U.get_recording_state_icon,
            color = get_recording_color,
            padding = 1,
          },
          {
            "filetype",
            icon_only = true,
            colored = true,
            padding = { left = 2, right = 1 },
          },
          {
            "filename",
            path = 0,
            color = text_hl,
            symbols = {
              modified = " ●",
              readonly = " ",
              unnamed = "[No Name]",
            },
          },
        },
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = {
              error = U.diagnostic_signs.error,
              warn = U.diagnostic_signs.warn,
              info = U.diagnostic_signs.info,
              hint = U.diagnostic_signs.hint,
              other = U.diagnostic_signs.other,
            },
            colored = true,
            padding = 2,
          },
          {
            U.current_buffer_lsp,
            padding = 1,
            color = text_hl,
            icon = { " ", color = icon_hl },
          },
          -- One indicator per <leader>u toggle, generated from the
          -- registry -- adding a toggle adds its icon here for free.
          unpack(require("jack.toggles").lualine_components({ fg = green }, icon_hl)),
        },
        lualine_y = {
          -- The session's digimon partner. Static text, like the encoding
          -- next to it -- :Digimon has the live stats.
          {
            function()
              local partner = require("jack.digimons.partner").get()
              return partner and partner.name or ""
            end,
            cond = function()
              return require("jack.digimons.partner").get() ~= nil
            end,
            icon = { require("jack.digimons.partner").icon(), color = icon_hl },
            color = text_hl,
            padding = 1,
          },
          {
            "fileformat",
            color = text_hl,
          },
          {
            "encoding",
            color = text_hl,
            fmt = string.upper,
          },
        },
        lualine_z = default_z,
      },
      options = {
        disabled_filetypes = { "dashboard" },
        globalstatus = true,
        section_separators = { left = " ", right = " " },
        component_separators = { left = "", right = "" },
      },
      extensions = {
        telescope,
        tree,
      },
    })

    -- Nordic is transparent, and lualine caches the background it computed
    -- when it first ran. Re-running setup once a real window exists makes
    -- it pick up the transparent background instead of the default one.
    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
      group = vim.api.nvim_create_augroup("jack_lualine_bg", { clear = true }),
      pattern = { "*.*" },
      once = true,
      callback = function()
        require("lualine").setup({})
      end,
    })
    vim.defer_fn(function()
      require("lualine").setup({})
    end, 1)
  end,
}
