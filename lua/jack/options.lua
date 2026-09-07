-- Define the basic nvim options
local opt = vim.opt

opt.nu = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")
opt.updatetime =  50

opt.undofile = true
opt.shortmess:append("I")

vim.g.mapleader = " "
vim.g.maplocalleader = ','
