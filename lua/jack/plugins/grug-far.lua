-- Project-wide search and replace in a buffer you can edit: tweak the
-- pattern, see every match update live, then apply. Backed by ripgrep.
--
-- Complements <leader>s in keymaps.lua, which only substitutes in the
-- current file.
return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    {
      "<leader>sr",
      function()
        require("grug-far").open({ transient = true })
      end,
      desc = "Search & replace (project)",
    },
    {
      "<leader>sw",
      function()
        require("grug-far").open({
          transient = true,
          prefills = { search = vim.fn.expand("<cword>") },
        })
      end,
      desc = "Search & replace word under cursor",
    },
    {
      "<leader>sr",
      mode = "v",
      function()
        require("grug-far").with_visual_selection({ transient = true })
      end,
      desc = "Search & replace selection",
    },
    {
      "<leader>sf",
      function()
        require("grug-far").open({
          transient = true,
          prefills = { paths = vim.fn.expand("%") },
        })
      end,
      desc = "Search & replace (current file)",
    },
  },
  opts = {
    -- `transient` above keeps these buffers out of the buffer list; this
    -- just stops the window from stealing a vertical split by default.
    windowCreationCommand = "botright vsplit",
  },
}
