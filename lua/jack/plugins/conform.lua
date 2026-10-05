-- Formatting. `jack.lsp.format_enabled` already existed as a statusline
-- indicator with nothing behind it; conform is what it now actually
-- controls. Manual formatting (gf) always works, format-on-save only when
-- the toggle is on -- it starts off, same as the old default.
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
    {
      "<leader>uf",
      function()
        require("jack.lsp").toggle_format_enabled()
      end,
      desc = "Toggle format on save",
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
      if not require("jack.lsp").format_enabled then
        return nil
      end
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
  },
}
