-- Structural editing for Clojure and friends: slurp, barf, raise, drag,
-- splice -- treesitter-based, so it understands forms rather than matching
-- characters.
--
-- Default keys, which hang off <localleader> (`,` here):
--   >) <)   slurp/barf forwards      >( <(   barf/slurp backwards
--   >e <e   drag element             >f <f   drag form
--   ,o      raise form               ,O      raise element
--   ,@      splice                   ,w/,i/,[  wrap in (), [], {}
return {
  "julienvincent/nvim-paredit",
  ft = { "clojure", "fennel", "scheme", "lisp", "janet" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    -- Keep the cursor where it was unless the edit moves it out of the
    -- form it started in.
    cursor_behaviour = "auto",
    -- Off by default upstream; without it a slurp leaves the pulled-in
    -- form at its old indentation.
    indent = { enabled = true },
    dragging = { auto_drag_pairs = true },
  },
}
