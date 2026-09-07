local ignored_filetypes = {
  "neo-tree",
  "dashboard",
  "TelescopePrompt",
  "TelescopeResults",
  "noice",
  "lazy",
  "mason",
  "which_key",
}

require("tint").setup({
  tint = -35,
  saturation = 0.7,
  transforms = require("tint").transforms.SATURATE_TINT,
  tint_background_colors = true,
  highlight_ignore_patterns = { "WinSeparator", "St.*", "Status.*" },
  window_ignore_function = function(winid)
    local bufid = vim.api.nvim_win_get_buf(winid)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufid })
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufid })

    if vim.api.nvim_win_get_config(winid).relative ~= "" then
      return true
    end

    return buftype == "terminal" or vim.tbl_contains(ignored_filetypes, filetype)
  end,
})
