-- Close a buffer without taking its windows down with it.
--
-- Plain `:bdelete` closes every window displaying the buffer, which with a
-- neo-tree sidebar and splits means the layout collapses. This moves each
-- affected window to another buffer first, then deletes. Modelled on
-- LunarVim's BufferKill.
local M = {}

---@param force boolean|nil  discard unsaved changes
function M.kill(force)
  local bufnr = vim.api.nvim_get_current_buf()

  if not force and vim.bo[bufnr].modified then
    local choice = vim.fn.confirm(
      ("Save changes to %q?"):format(vim.fn.bufname(bufnr)),
      "&Yes\n&No\n&Cancel"
    )
    if choice == 1 then
      vim.cmd.write()
    elseif choice == 2 then
      force = true
    else
      return
    end
  end

  -- Buffers we could fall back to, most recently used first. `buflisted`
  -- excludes the help/quickfix/terminal scratch buffers.
  local candidates = vim.tbl_filter(function(b)
    return b.bufnr ~= bufnr and b.listed == 1
  end, vim.fn.getbufinfo({ buflisted = 1 }))

  table.sort(candidates, function(a, b)
    return a.lastused > b.lastused
  end)

  local replacement = candidates[1] and candidates[1].bufnr

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      if replacement then
        vim.api.nvim_win_set_buf(win, replacement)
      else
        -- Last listed buffer: leave the window on a fresh empty one rather
        -- than closing it (or quitting nvim).
        vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
      end
    end
  end

  if vim.api.nvim_buf_is_valid(bufnr) then
    pcall(vim.api.nvim_buf_delete, bufnr, { force = force or false })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("BufferKill", function(opts)
    M.kill(opts.bang)
  end, { bang = true, desc = "Close buffer, keep the window layout" })

  vim.keymap.set("n", "<leader>bd", function()
    M.kill(false)
  end, { desc = "Close buffer" })

  vim.keymap.set("n", "<leader>bD", function()
    M.kill(true)
  end, { desc = "Close buffer (force)" })
end

return M
