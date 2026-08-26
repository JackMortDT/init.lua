local TS = require("telescope")
local U = require("jack.utils")

local prompt_chars = U.border_chars_telescope_default
local vert_preview_chars = U.border_chars_telescope_default

local picker_register = {
  sort_mru = true,
  preview = false,
  wrap_results = false,
  layout_config = {
    height = 0.6,
    width = 0.6,
  },
}

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
  borderchars = {
    prompt = prompt_chars,
    preview = vert_preview_chars,
    results = U.get_border_chars("telescope"),
  },
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
  borderchars = {
    prompt = prompt_chars,
    preview = vert_preview_chars,
    results = U.get_border_chars("telescope"),
  },

  sort_mru = true,
  sorting_strategy = "ascending",
  border = true,
  multi_icon = "",
  entry_prefix = "   ",
  prompt_prefix = "   ",
  selection_caret = "  ",
  hl_result_eol = true,
  results_title = "",
  winblend = 0,
  wrap_results = true,
  mappings = {
    i = {
      ["<Esc>"] = require("telescope.actions").close,
      ["<C-Esc>"] = require("telescope.actions").close,
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
      borderchars = {
        prompt = prompt_chars,
        preview = vert_preview_chars,
        results = U.get_border_chars("telescope"),
      },
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
      mappings = { i = { ["<CR>"] = require("telescope.actions").select_vertical } },
    },
    oldfiles = { preview_title = "" },
    find_files = { preview_title = "" },
    lsp_document_symbols = { preview_title = "" },
    man_pages = {
      preview_title = "",
      mappings = { i = { ["<CR>"] = require("telescope.actions").select_vertical } },
    },
  },
})

pcall(TS.load_extension, "fzf")
pcall(TS.load_extension, "ui-select")
pcall(TS.load_extension, "file_browser")
pcall(TS.load_extension, "frecency")

vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function()
    vim.opt_local.number = true
  end,
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Telescope recent files' })
vim.keymap.set('n', '<leader>fe', "<cmd>Telescope file_browser<cr>", { desc = 'Telescope file browser' })
vim.keymap.set('n', '<leader>fF', function()
  TS.extensions.frecency.frecency()
end, { desc = 'Telescope frecency' })
