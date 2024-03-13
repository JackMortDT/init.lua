local plugins = {}

plugins.setup = {
  -- Code editor
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'stevearc/dressing.nvim',
    opts = {},
  },
  { "folke/neodev.nvim" },
  { 'nvim-lualine/lualine.nvim' },
  { 'linrongbin16/lsp-progress.nvim' },

  -- File plugins
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "MunifTanjim/nui.nvim" },
  { "VonHeikemen/fine-cmdline.nvim" },
  { "nvim-neo-tree/neo-tree.nvim",      branch = "v3.x" },
  { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate" },
  { 'nvim-telescope/telescope.nvim',    tag = '0.1.5' },

  -- Lsp plugins
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'VonHeikemen/lsp-zero.nvim',        branch = 'v3.x' },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/nvim-cmp' },
  { 'L3MON4D3/LuaSnip' },

  -- Clojure
  { "Olical/conjure" },

  -- Other stuff
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
  },
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins.setup)
