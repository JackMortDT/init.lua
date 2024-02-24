require("neo-tree").setup({
  close_if_last_window = false,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  enable_normal_mode_for_inputs = false,
  open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
  sort_case_insensitive = false,
  sort_function = nil,
  icon = {
    folder_closed = "",
    folder_open = "",
    folder_empty = "󰜌",
    default = "*",
    highlight = "NeoTreeFileIcon"
  },
  file_size = {
    enabled = true,
    required_width = 64
  }
})

vim.keymap.set("n", "<leader>b", ":Neotree<CR>")
