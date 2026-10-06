-- LSP-adjacent glue: diagnostic presentation and the LspAttach hook.
-- The on/off state itself is owned by jack.toggles; this module only knows
-- how to apply it.
local M = {}

-- Show diagnostic text inline at all.
M.virtual_diagnostics = true
-- When inline is on: every diagnostic in the buffer, or only the ones on
-- the cursor's line. Defaults to cursor-line only.
--
-- `virtual_lines = true` gives each diagnostic its own screen line, which
-- on a half-written Clojure form means clojure-lsp's "unresolved symbol"
-- for every binding at once -- the file visually triples in height while
-- you type. Cursor-line scoping keeps the full message where you're
-- working and leaves the rest as signs and undercurl.
M.diagnostics_all_lines = false

local function apply_diagnostic_config()
    local U = require("jack.utils")
    local signs = U.diagnostic_signs

    local virtual_lines = false
    if M.virtual_diagnostics then
        virtual_lines = M.diagnostics_all_lines or { current_line = true }
    end

    vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = signs.error,
                [vim.diagnostic.severity.WARN] = signs.warn,
                [vim.diagnostic.severity.INFO] = signs.info,
                [vim.diagnostic.severity.HINT] = signs.hint,
            },
        },
        virtual_lines = virtual_lines,
        virtual_text = false,
        -- Off deliberately: with it on, every keystroke mid-form
        -- re-renders a wall of "unresolved symbol" for bindings that
        -- simply aren't typed yet. Diagnostics refresh on leaving insert.
        update_in_insert = false,
        severity_sort = true,
    })

    -- Underline only carries information when the message isn't already
    -- spelled out on that line. In cursor-line mode it marks everything
    -- the inline text isn't currently showing.
    local undercurl = not (M.virtual_diagnostics and M.diagnostics_all_lines)
    U.merge_highlights_table({
        DiagnosticUnderlineError = { undercurl = undercurl },
        DiagnosticUnderlineWarn = { undercurl = undercurl },
        DiagnosticUnderlineHint = { undercurl = undercurl },
        DiagnosticUnderlineOk = { undercurl = undercurl },
        DiagnosticUnderlineInfo = { undercurl = undercurl },
    })
end

function M.set_virtual_diagnostics(value)
    M.virtual_diagnostics = value
    apply_diagnostic_config()
end

function M.set_diagnostics_all_lines(value)
    M.diagnostics_all_lines = value
    apply_diagnostic_config()
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

            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client then
                require("jack.lsp.winbar").attach(client, args.buf)
            end
        end,
    })
end

return M
