-- A persistent, grouped diagnostics list you work through, as opposed to
-- Telescope's picker (gs / <leader>xt) which closes as soon as you pick
-- something. Both read the same vim.diagnostic store.
--
-- Note on scope: clojure-lsp analyses the whole project and publishes
-- diagnostics per URI, so this lists errors in files you never opened
-- (nvim holds them in unloaded buffers). It is not limited to open
-- buffers -- use <leader>xX when you only care about the current file.
return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (project)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (this buffer)" },
    { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location list" },
  },
  opts = {
    focus = true,
    -- Errors first, then warnings, matching the severity_sort in
    -- jack/lsp/init.lua.
    modes = {
      diagnostics = {
        groups = { { "filename", format = "{file_icon} {filename} {count}" } },
      },
    },
  },
}
