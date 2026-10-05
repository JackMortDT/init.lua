local U = require("jack.utils.neovim")
local M = {}

-- Border chars.
M.border_chars_round = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }

-- Telscope chars.
M.border_helix_telescope = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
M.border_chars_outer_thick_telescope = { "▀", "▐", "▄", "▌", "▛", "▜", "▟", "▙" }
M.border_chars_outer_thin_telescope = { "▔", "▕", "▁", "▏", "🭽", "🭾", "🭿", "🭼" }
M.border_chars_telescope_default = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
M.border_chars_telescope_prompt_thin = { "▔", "▕", " ", "▏", "🭽", "🭾", "▕", "▏" }
M.border_chars_telescope_vert_preview_thin = { " ", "▕", "▁", "▏", "▏", "▕", "🭿", "🭼" }

-- Icons.
M.diagnostic_signs = {
    error = " ",
    warning = " ",
    warn = " ",
    info = " ",
    information = " ",
    hint = " ",
    other = " ",
}

-- Small icon set for statusline components. `None` is an empty string so a
-- component can render "nothing" without lualine collapsing padding oddly.
M.kind_icons = {
    Recording = "󰑊 ",
    None = "",
}

function M.get_border_chars(desc)
  if desc == "telescope" then
    return M.border_chars_telescope_default
  end
end

function M.get_recording_state_icon()
    if U.is_recording() then
        return M.kind_icons.Recording .. vim.fn.reg_recording()
    else
        return M.kind_icons.None
    end
end

return M
