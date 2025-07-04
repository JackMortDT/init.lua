local M = {}

local function get_short_cwd()
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
    require("lualine").refresh({ statusline = true })
end

return M
