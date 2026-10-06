return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>?", function() require("which-key").show() end, desc = "Show which-key" },
  },
  opts = {
    -- No automatic popups: which-key is on demand via <leader>? only.
    triggers = {},
    spec = {
      { "<leader>b", group = "buffers" },
      { "<leader>f", group = "find / files" },
      { "<leader>h", group = "git hunks" },
      { "<leader>s", group = "search & replace" },
      { "<leader>q", group = "sessions" },
      { "<leader>v", group = "lsp" },
      { "<leader>u", group = "toggles" },
      { "<leader>x", group = "diagnostics" },
      { "<leader>p", group = "plugins" },
    },
  },
}
