return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, opts)
        vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = bufnr }, opts or {}))
      end

      -- In a diff, ]c/[c already mean "next/prev change"; only take them
      -- over in a normal buffer.
      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(gs.next_hunk)
        return "<Ignore>"
      end, { expr = true, desc = "Next hunk" })

      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(gs.prev_hunk)
        return "<Ignore>"
      end, { expr = true, desc = "Previous hunk" })

      map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
      map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
      map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
      map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
      map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
    end,
  },
}
