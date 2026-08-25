local plugins = {}

plugins.setup = {
  -- Common dependencies
  { "nvim-lua/plenary.nvim" },
  { "nvim-lua/popup.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "MunifTanjim/nui.nvim" },
  { "echasnovski/mini.icons" },

  -- Editor
  { "declancm/maximize.nvim" },
  {
    "nvimdev/dashboard-nvim",
    event = 'VimEnter',
    lazy = false,
    priority = 999,
  },
  {
    "karb94/neoscroll.nvim",
    event = { "VeryLazy" },
  },
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('nordic').setup({
        transparent = {
          bg = true,
          float = true,
        },
      })
      require('nordic').load()
    end
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    opts = {},
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },
  { "nvim-treesitter/nvim-treesitter", branch = "main", lazy = false, build = ":TSUpdate" },
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
  },
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    event = { "VeryLazy" }
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  },

  -- Lsp
  { "mason-org/mason.nvim" },
  { 'mason-org/mason-lspconfig.nvim' },
  { 'neovim/nvim-lspconfig' },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x'
  },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/nvim-cmp' },
  { 'L3MON4D3/LuaSnip' },
  { 'saadparwaiz1/cmp_luasnip' },

  -- Clojure
  { "Olical/conjure" },

  -- Notes
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    config = true,
  },
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins.setup)
