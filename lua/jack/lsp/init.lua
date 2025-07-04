local M = {}

M.virtual_diagnostics = true
function M.toggle_virtual_diagnostics()
    M.virtual_diagnostics = not M.virtual_diagnostics
    vim.diagnostic.config({
        signs = signs,
        virtual_lines = M.virtual_diagnostics,
        virtual_text = false,
        update_in_insert = true,
        severity_sort = true,
    })
    U.merge_highlights_table({
        DiagnosticUnderlineError = { undercurl = not M.virtual_diagnostics },
        DiagnosticUnderlineWarn = { undercurl = not M.virtual_diagnostics },
        DiagnosticUnderlineHint = { undercurl = not M.virtual_diagnostics },
        DiagnosticUnderlineOk = { undercurl = not M.virtual_diagnostics },
        DiagnosticUnderlineInfo = { undercurl = not M.virtual_diagnostics },
    })
    require("jack.utils").refresh_statusline()
end

M.format_enabled = false
function M.toggle_format_enabled()
    M.format_enabled = not M.format_enabled
    require("jack.utils").refresh_statusline()
end

return M
