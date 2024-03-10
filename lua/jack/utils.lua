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
