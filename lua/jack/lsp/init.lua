-- Shared LSP-adjacent state: the toggles the statusline reads and the
-- keymaps flip. Kept out of the plugin specs so both lualine and
-- lspconfig can require it without creating a load-order dependency.
local M = {}

M.virtual_diagnostics = true
M.format_enabled = false

local function apply_diagnostic_config()
    local signs = require("jack.utils").diagnostic_signs

    vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = signs.error,
                [vim.diagnostic.severity.WARN] = signs.warn,
                [vim.diagnostic.severity.INFO] = signs.info,
                [vim.diagnostic.severity.HINT] = signs.hint,
            },
        },
        virtual_lines = M.virtual_diagnostics,
        virtual_text = false,
        update_in_insert = true,
        severity_sort = true,
    })

    -- When the diagnostic text is already shown inline there's no need to
    -- also underline the offending range; it just adds noise.
    require("jack.utils").merge_highlights_table({
        DiagnosticUnderlineError = { undercurl = not M.virtual_diagnostics },
        DiagnosticUnderlineWarn = { undercurl = not M.virtual_diagnostics },
        DiagnosticUnderlineHint = { undercurl = not M.virtual_diagnostics },
        DiagnosticUnderlineOk = { undercurl = not M.virtual_diagnostics },
        DiagnosticUnderlineInfo = { undercurl = not M.virtual_diagnostics },
    })
end

-- Called once from the lspconfig spec so the startup state matches what the
-- statusline claims. Previously the config was only ever applied on toggle,
-- so a fresh session showed `virtual_diagnostics = true` while nvim was
-- still using its stock virtual_text.
function M.setup()
    apply_diagnostic_config()

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("jack_lsp_attach", { clear = true }),
        callback = function(args)
            require("jack.lsp.keymaps").on_attach(args.buf)
        end,
    })
end

function M.toggle_virtual_diagnostics()
    M.virtual_diagnostics = not M.virtual_diagnostics
    apply_diagnostic_config()
    require("jack.utils").refresh_statusline()
end

function M.toggle_format_enabled()
    M.format_enabled = not M.format_enabled
    vim.notify("format on save " .. (M.format_enabled and "on" or "off"))
    require("jack.utils").refresh_statusline()
end

return M
