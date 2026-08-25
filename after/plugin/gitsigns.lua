require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local opts = { buffer = bufnr }

    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(gs.next_hunk)
      return '<Ignore>'
    end, { buffer = bufnr, expr = true })

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(gs.prev_hunk)
      return '<Ignore>'
    end, { buffer = bufnr, expr = true })

    vim.keymap.set('n', '<leader>hs', gs.stage_hunk, opts)
    vim.keymap.set('n', '<leader>hr', gs.reset_hunk, opts)
    vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, opts)
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, opts)
    vim.keymap.set('n', '<leader>hb', function() gs.blame_line({ full = true }) end, opts)
    vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame, opts)
  end,
})
