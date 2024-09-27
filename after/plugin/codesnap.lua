require("codesnap").setup()

vim.api.nvim_set_keymap("x", "<leader>cc", "<cmd>CodeSnap<cr>", {desc = "Save selected snapshot into clipboard"})
vim.api.nvim_set_keymap("x", "<leader>cs", "<cmd>CodeSnapSave<cr>", {desc = "Save selected snapshot in ~/Pictures"})
