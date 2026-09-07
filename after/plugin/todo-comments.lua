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

vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

vim.keymap.set("n", "<leader>fT", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
