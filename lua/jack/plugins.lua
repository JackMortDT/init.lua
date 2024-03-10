local M = {}

M.setup = {
  -- Code editor
  {"rose-pine/neovim", name = "rose-pine"},
  {"folke/neodev.nvim"},

  -- File plugins
  {"nvim-lua/plenary.nvim"},
  {"nvim-tree/nvim-web-devicons"},
  {"MunifTanjim/nui.nvim"},
  {"nvim-neo-tree/neo-tree.nvim", branch = "v3.x"},

  -- Lsp plugins
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'L3MON4D3/LuaSnip'},

  -- Clojure
  {"Olical/conjure"}
}

return M