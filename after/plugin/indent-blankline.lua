local C = require("nordic.colors")

vim.api.nvim_set_hl(0, "IblIndent", { fg = C.gray2 })
vim.api.nvim_set_hl(0, "IblScope", { fg = C.blue2 })

require("ibl").setup({
  indent = {
    char = "│",
    highlight = "IblIndent",
  },
  scope = {
    enabled = true,
    highlight = "IblScope",
    show_start = false,
    show_end = false,
  },
  exclude = {
    filetypes = { "dashboard", "neo-tree", "lazy", "mason" },
  },
})
