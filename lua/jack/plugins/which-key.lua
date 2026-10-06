return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>?", function() require("which-key").show() end, desc = "Show which-key" },
  },
  opts = {
    -- Floating, centred, rounded border, title. The other presets are
    -- `classic` (full-width bottom split, which is the default) and
    -- `helix` (narrow panel bottom-right).
    preset = "modern",

    -- No automatic popups: which-key is on demand via <leader>? only.
    triggers = {},

    -- Cap the column width. <leader>? lists everything at once, and
    -- without a max a single long description ("Substitute word under
    -- cursor (this file)") widens its whole column and pushes the rest
    -- off screen. `min` stays at the default 20.
    layout = {
      width = { max = 40 },
    },

    spec = {
      { "<leader>b", group = "buffers" },
      { "<leader>f", group = "find / files" },
      { "<leader>h", group = "git hunks" },
      { "<leader>s", group = "search & replace" },
      { "<leader>q", group = "sessions" },
      { "<leader>v", group = "lsp" },
      { "<leader>u", group = "toggles" },
      { "<leader>x", group = "diagnostics" },
      { "<leader>m", group = "metals (scala)" },
      { "<leader>p", group = "plugins" },
    },
  },
}
