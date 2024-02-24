require("mix").setup()
vim.g.mix_format_on_save = 1

vim.api.nvim_set_keymap('n', '<Leader>em', ':!mix test<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>ef', ':!mix test %<CR>', { noremap = true, silent = true })
