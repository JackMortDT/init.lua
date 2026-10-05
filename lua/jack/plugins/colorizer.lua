return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    filetypes = { "*" },
    user_default_options = {
      names = false,
      RGB = true,
      RRGGBB = true,
      RRGGBBAA = true,
      css = true,
      css_fn = true,
      mode = "background",
    },
  },
}
