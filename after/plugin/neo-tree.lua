require("neo-tree").setup({
  close_if_last_window = false,
  enable_git_status = true,
  enable_diagnostics = true,
})

vim.keymap.set("n", "<leader>ft", "<cmd>Neotree toggle<cr>", {desc = "NeoTree"})
