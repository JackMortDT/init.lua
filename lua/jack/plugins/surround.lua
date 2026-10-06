-- Add, change and delete surrounding pairs:
--   ysiw"  surround word with quotes      cs"'  change " to '
--   ds"    delete surrounding quotes      yss)  surround whole line
--
-- Lisp buffers already have nvim-paredit for this (,w / ,i / ,[ wrap by
-- form rather than by text object), so this is mainly for Lua, Elixir,
-- JSON and markdown.
return {
  "kylechui/nvim-surround",
  version = "*",
  event = { "BufReadPost", "BufNewFile" },
  opts = {},
}
