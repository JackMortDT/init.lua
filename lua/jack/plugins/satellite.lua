-- A scrollbar that doubles as a minimap of what matters: git hunks,
-- diagnostics, search hits and marks, all in the right-hand edge.
-- Reads from gitsigns, which is already here.
return {
  "lewis6991/satellite.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    current_only = true,
    winblend = 0,
    zindex = 40,
    excluded_filetypes = {
      "dashboard",
      "neo-tree",
      "TelescopePrompt",
      "lazy",
      "mason",
      "help",
      "qf",
      "undotree",
      "diff",
      "grug-far",
      "trouble",
    },
    handlers = {
      cursor = { enable = false },
      search = { enable = true },
      diagnostic = { enable = true, min_severity = vim.diagnostic.severity.HINT },
      gitsigns = { enable = true },
      marks = { enable = false },
    },
  },
}
