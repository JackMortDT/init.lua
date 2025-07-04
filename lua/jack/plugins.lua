local plugins = {}

plugins.setup = {
  -- Common dependencies
  { "nvim-lua/plenary.nvim" },
  { "nvim-lua/popup.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "MunifTanjim/nui.nvim" },
  { "echasnovski/mini.icons" },

  -- Editor
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
      require('nordic').load()
    end
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8"
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

  -- Clojure
  { "Olical/conjure" },
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
