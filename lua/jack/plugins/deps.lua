-- Shared libraries. Nothing loads these on its own; they come in as
-- `dependencies` of the plugins that need them, which is what keeps them
-- off the startup path.
return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-lua/popup.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "echasnovski/mini.icons", lazy = true, opts = {} },
}
