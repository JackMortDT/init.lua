-- Formatting. The `format` toggle in jack/toggles.lua was a statusline
-- indicator with nothing behind it; conform is what it now actually
-- controls. Manual formatting (gf) always works, format-on-save only when
-- the toggle is on -- it starts off, same as the old default.
--
-- The <leader>uf keymap lives in jack/toggles.lua with the rest of them.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "gf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    -- Anything not listed falls through to the language server, which is
    -- what handles clojure (clojure-lsp) and elixir here.
    formatters_by_ft = {
      lua = { "stylua" },
      json = { "jq" },
      jsonc = { "jq" },
    },
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function()
      if not require("jack.toggles").get("format") then
        return nil
      end
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
  },
}
