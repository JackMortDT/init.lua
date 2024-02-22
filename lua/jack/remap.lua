local maximized = false
function ToggleMaximize()
  if maximized then
    vim.cmd(":execute 'wincmd ='")
  else
    vim.cmd(':vertical resize +999')
    vim.cmd(':resize +999')
  end
  maximized = not maximized
end

vim.keymap.set("n", "<C-w>z", "<cmd>lua ToggleMaximize() <CR>", {noremap = true, silent = true})

vim.keymap.set("n", "<leader>.", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv'")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv'")

vim.keymap.set("i", "<C-c>", "<Esc>")
