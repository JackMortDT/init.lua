require("neo-tree").setup({
  popup_border_style = "",
  close_if_last_window = false,
  enable_git_status = true,
  enable_diagnostics = true,
})

vim.keymap.set("n", "<leader>ft", "<cmd>Neotree filesystem toggle<cr>", {desc = "NeoTree"})
vim.keymap.set("n", "<leader>fm", "<cmd>Neotree float git_status git_base=main<cr>", {desc = "NeoTree"})
