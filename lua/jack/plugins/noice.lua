return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = function()
    local chars = require("jack.utils.chars")

    return {
      cmdline = {
        format = {
          cmdline = { title = "", icon = " " },
          lua = { title = "", icon = "󰢱 " },
          help = { title = "", icon = "󰋖 " },
          input = { title = "", icon = " " },
          filter = { title = "", icon = " " },
          search_up = { icon = "    " },
          search_down = { icon = "    " },
        },
      },
      views = {
        cmdline_popup = {
          border = {
            style = chars.border_chars_round,
            padding = { 0, 2 },
          },
          position = {
            row = "49%",
            col = "50%",
          },
        },
        hover = { border = { style = "rounded" } },
        float = { border = { style = "rounded" } },
        popup = { border = { style = "rounded" } },
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        signature = { enabled = false, view = "popup" },
        progress = { enabled = true, view = "mini" },
      },
      presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,        -- add a border to hover docs and signature help
      },
    }
  end,
}
