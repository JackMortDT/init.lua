-- Breadcrumbs in the winbar: "file > namespace > function" from the LSP's
-- document symbols, via nvim-navic.
--
-- Only attached for clients that actually provide document symbols, and
-- only in real file windows -- a winbar in neo-tree or a float just eats a
-- line of screen.
local M = {}

local IGNORED_FILETYPES = {
  "neo-tree",
  "dashboard",
  "TelescopePrompt",
  "lazy",
  "mason",
  "help",
  "man",
  "qf",
  "checkhealth",
  "noice",
}

local function eligible(bufnr)
  if vim.bo[bufnr].buftype ~= "" then
    return false
  end
  if vim.tbl_contains(IGNORED_FILETYPES, vim.bo[bufnr].filetype) then
    return false
  end
  -- Floating windows have no room for a winbar.
  return vim.api.nvim_win_get_config(0).relative == ""
end

function M.attach(client, bufnr)
  if not client:supports_method("textDocument/documentSymbol") then
    return
  end

  local ok, navic = pcall(require, "nvim-navic")
  if not ok then
    return
  end

  navic.attach(client, bufnr)

  if eligible(bufnr) then
    vim.wo.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
  end
end

return M
