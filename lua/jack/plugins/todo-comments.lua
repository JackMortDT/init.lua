return {
  "folke/todo-comments.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "TodoTelescope" },
  dependencies = { "nvim-lua/plenary.nvim", "AlexvZyl/nordic.nvim" },
  keys = {
    { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    { "<leader>fT", "<cmd>TodoTelescope<cr>",                            desc = "Find todos" },
  },
  config = function()
    -- Colors come from nordic rather than being hardcoded, hence the
    -- dependency and the function form instead of plain `opts`.
    local C = require("nordic.colors")

    require("todo-comments").setup({
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*:?]],
      },
      colors = {
        error = { C.red.base },
        warning = { C.yellow.base },
        info = { C.blue2 },
        hint = { C.green.base },
        default = { C.magenta.base },
        test = { C.cyan.base },
      },
    })
  end,
}
