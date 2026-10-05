local M = {}

-- Exported: lualine's neo-tree extension renders it as a component.
function M.get_short_cwd()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

function M.current_buffer_lsp()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if next(clients) == nil then
        return ""
    end
    local current_clients = ""

    for _, client in ipairs(clients) do
        current_clients = current_clients .. client.name .. " "
    end

    return current_clients
end

function M.is_recording()
    return vim.fn.reg_recording() ~= ""
end

function M.refresh_statusline()
    local ok, lualine = pcall(require, "lualine")
    if ok then
        lualine.refresh({ statusline = true })
    end
end

-- Patch attributes onto existing highlight groups instead of replacing them,
-- so toggling one attribute (undercurl, say) doesn't wipe the colorscheme's
-- colors for that group.
function M.merge_highlights_table(highlights)
    for group, attrs in pairs(highlights) do
        local ok, current = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", ok and current or {}, attrs))
    end
end

return M
