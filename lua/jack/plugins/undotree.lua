-- Browse the undo history as a tree. `undofile` is already on in
-- options.lua, so this history survives across sessions -- it was being
-- written and never read.
return {
  "mbbill/undotree",
  cmd = { "UndotreeToggle", "UndotreeShow" },
  keys = {
    -- <leader>U, not <leader>u: the latter is the toggles group prefix,
    -- and claiming it would make every <leader>u… wait out timeoutlen.
    { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
  },
  init = function()
    -- Must be set before the plugin loads.
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_SplitWidth = 34
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_ShortIndicators = 1
  end,
}
