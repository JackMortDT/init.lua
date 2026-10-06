-- Breadcrumbs for the winbar. Attached per-client from jack/lsp/winbar.lua
-- on LspAttach, which is also where the winbar string gets set.
return {
  "SmiteshP/nvim-navic",
  lazy = true,
  opts = {
    icons = require("jack.utils").navic_icons,
    highlight = true,
    separator = "  ",
    depth_limit = 5,
    depth_limit_indicator = "..",
    -- The winbar is set by hand in jack/lsp/winbar.lua so it can skip
    -- floats and sidebars; navic must not also do it.
    lsp = { auto_attach = false },
    click = false,
  },
}
