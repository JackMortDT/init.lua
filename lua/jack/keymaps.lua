-- Core keymaps only: everything here works with zero plugins loaded.
-- Plugin keymaps live in that plugin's spec under lua/jack/plugins/, so
-- lazy.nvim can use them as load triggers.
local map = vim.keymap.set

-- Move the visual selection up/down, re-indenting as it goes.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Join without losing the cursor column.
map("n", "J", "mzJ`z", { desc = "Join line" })

-- Keep the cursor centered while jumping around.
-- NOTE: <C-d>/<C-u> are owned by neoscroll (see plugins/neoscroll.lua),
-- which registers them as lazy-load triggers and would override anything
-- set here anyway.
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })

-- Yank straight to the system clipboard.
map({ "n", "v" }, "y", '"+y', { desc = "Yank to clipboard" })
map("n", "Y", '"+y', { desc = "Yank to clipboard" })

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute word under cursor" })

map("i", "<C-c>", "<Esc>", { desc = "Escape" })

map("n", "<leader><leader>", "<cmd>source<cr>", { desc = "Source current file" })

map("n", "<leader>w", function()
  local on = not vim.wo.wrap
  vim.wo.wrap = on
  vim.wo.linebreak = on
  vim.wo.breakindent = on
  vim.notify("wrap " .. (on and "on" or "off"))
end, { desc = "Toggle line wrap" })

-- Move by display line when wrapped, by real line otherwise (and always by
-- real line when a count is given, so 5j still lands where relative numbers
-- say it should).
map("n", "j", "v:count || !&wrap ? 'j' : 'gj'", { expr = true, desc = "Down" })
map("n", "k", "v:count || !&wrap ? 'k' : 'gk'", { expr = true, desc = "Up" })
