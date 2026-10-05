-- The colorscheme. Loaded eagerly and ahead of everything else, because
-- lualine, indent-blankline and todo-comments all read `nordic.colors` at
-- config time to derive their own highlights.
return {
  "AlexvZyl/nordic.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nordic").setup({
      transparent = {
        bg = true,
        float = true,
      },
    })
    require("nordic").load()
  end,
}
