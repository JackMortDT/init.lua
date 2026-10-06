-- Buffer-local keymaps applied on LspAttach. Telescope is required inside
-- the callbacks so it stays lazy until a mapping is actually used.
local M = {}

function M.on_attach(bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  -- gd/gr genuinely need a client attached, so they stay buffer-local.
  -- The diagnostics list does not -- it reads vim.diagnostic, which any
  -- source can write to -- so it lives globally in plugins/trouble.lua
  -- and plugins/telescope.lua instead.
  map("n", "gd", function() require("telescope.builtin").lsp_definitions() end, "Goto definition")
  map("n", "gr", function() require("telescope.builtin").lsp_references() end, "Goto references")
  map("n", "ga", vim.lsp.buf.code_action, "Code action")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature help")

  map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "Workspace symbol")
  map("n", "<leader>vrn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>vd", vim.diagnostic.open_float, "Line diagnostics")

  -- `]` forward, `[` backward -- these used to be swapped. Also moved off
  -- the deprecated goto_next/goto_prev onto vim.diagnostic.jump.
  map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
  map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
end

return M
