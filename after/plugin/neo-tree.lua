require("neo-tree").setup({
  popup_border_style = "rounded",
  close_if_last_window = false,
  enable_git_status = true,
  enable_diagnostics = true,
  use_libuv_file_watcher = true,

  default_component_configs = {
    indent = {
      indent_size = 2,
      padding = 1,
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      with_expanders = true,
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "󰜌",
      default = "*",
      highlight = "NeoTreeFileIcon",
    },
    modified = {
      symbol = "[+]",
      highlight = "NeoTreeModified",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = "NeoTreeFileName",
    },
    git_status = {
      symbols = {
        added     = "",
        modified  = "",
        deleted   = "✖",
        renamed   = "󰁕",
        untracked = "",
        ignored   = "",
        unstaged  = "󰄱",
        staged    = "",
        conflict  = "",
      },
    },
    diagnostics = {
      symbols = {
        hint = "󰌵",
        info = "",
        warn = "",
        error = "",
      },
      highlights = {
        hint = "DiagnosticSignHint",
        info = "DiagnosticSignInfo",
        warn = "DiagnosticSignWarn",
        error = "DiagnosticSignError",
      },
    },
  },

  window = {
    width = 32,
    mappings = {
      ["<tab>"] = "next_source",
      ["<s-tab>"] = "prev_source",
    },
  },

  source_selector = {
    winbar = true,
    sources = {
      { source = "filesystem", display_name = " 󰉓 Files" },
      { source = "buffers",    display_name = " 󰈚 Bufs" },
      { source = "git_status", display_name = " 󰊢 Git" },
    },
  },

  filesystem = {
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    window = {
      mappings = {
        ["H"] = "toggle_hidden",
      },
    },
  },
})

vim.keymap.set("n", "<leader>ft", "<cmd>Neotree filesystem toggle<cr>", { desc = "NeoTree" })
vim.keymap.set("n", "<leader>fm", "<cmd>Neotree float git_status git_base=main<cr>", { desc = "NeoTree git status" })
vim.keymap.set("n", "<leader>fb", "<cmd>Neotree float buffers<cr>", { desc = "NeoTree buffers" })
