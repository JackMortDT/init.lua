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
    { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Live grep" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end,  desc = "Help tags" },
    { "<leader>fr", function() require("telescope.builtin").oldfiles() end,   desc = "Recent files" },
    { "<leader>fe", "<cmd>Telescope file_browser<cr>",                        desc = "File browser" },
    { "<leader>fF", function() require("telescope").extensions.frecency.frecency() end, desc = "Frecency" },
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
