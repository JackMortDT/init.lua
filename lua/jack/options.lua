-- Define the basic nvim options
local opt = vim.opt

-- Leaders first: they have to be set before any mapping is defined.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Numbers: hybrid. Absolute on the cursor line, relative everywhere else,
-- which is what makes the counted j/k mappings in keymaps.lua useful (5j
-- jumps to the line labelled 5).
opt.nu = true
opt.relativenumber = true
opt.cursorline = true

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
opt.updatetime = 50

-- Case-insensitive search, unless the pattern has an uppercase letter in it.
opt.ignorecase = true
opt.smartcase = true

-- New splits open below and to the right, matching reading order.
opt.splitbelow = true
opt.splitright = true

-- Global default border for floating windows (nvim 0.11+). Replaces the
-- per-plugin `border = "rounded"` that neo-tree, lazy and friends each
-- needed. Plugins that pass an explicit border still win.
opt.winborder = "rounded"

-- Folding. Fold ranges come from nvim-ufo and the column is drawn by
-- statuscol.nvim (see plugins/folds.lua).
--
-- 'foldcolumn' has to be non-zero globally: statuscol's foldfunc segment
-- only renders while it is. The side effect is that windows statuscol
-- ignores (neo-tree, dashboard, help, ...) would get vim's own fold column
-- instead -- plugins/folds.lua zeroes it per-window for those.
opt.foldlevelstart = 99
opt.foldcolumn = "1"
opt.fillchars:append("fold: ")

opt.undofile = true
opt.shortmess:append("I")

-- NOTE: conceallevel is deliberately left at 0. render-markdown.nvim sets
-- it to 3 per-window while rendering and back to 0 otherwise, and setting
-- it globally would make vim's json syntax hide quote characters.
