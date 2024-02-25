require("mix").setup()
vim.g.mix_format_on_save = 1

vim.api.nvim_set_keymap('n', '<Leader>ea', ':!mix test<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>et', ':!mix test %<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>ec', ":execute '!mix test %:' . line('.')<CR>", { noremap = true, silent = true })
