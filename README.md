# Neovim Configuration

A modular Neovim configuration in Lua, managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Directory Structure

```
nvim/
├── init.lua                   # Entry point, just requires jack
└── lua/jack/
    ├── init.lua               # Load order: options → keymaps → autocmds → filetypes → lazy
    ├── options.lua            # vim.opt settings and leader keys
    ├── keymaps.lua            # Core keymaps (no plugins involved)
    ├── autocmds.lua           # Core autocommands
    ├── filetypes.lua          # vim.filetype.add rules
    ├── lazy.lua               # lazy.nvim bootstrap + setup
    ├── digimons/              # Sprite loader for the dashboard header
    ├── lsp/
    │   ├── init.lua           # Diagnostic/format toggles shared with the statusline
    │   └── keymaps.lua        # Buffer-local keymaps applied on LspAttach
    ├── utils/                 # Border chars, icons, small helpers
    └── plugins/               # One file per plugin, auto-imported by lazy
```

## How to add a plugin

Create one file in `lua/jack/plugins/` returning a lazy spec. That's it —
`lazy.lua` imports the whole directory, so nothing else needs editing.

```lua
-- lua/jack/plugins/my-plugin.lua
return {
  "owner/my-plugin",
  keys = { { "<leader>x", "<cmd>MyPlugin<cr>", desc = "Do the thing" } },
  opts = {},
}
```

The rule is **spec and config live together**: the plugin's `opts`/`config`,
its keymaps and its load trigger all go in that one file. Keymaps declared as
`keys` double as lazy-load triggers, which is what keeps startup small —
anything that calls `require("some-plugin")` at startup defeats that.

## Conventions

- `lazy = true` by default. A spec opts out with `lazy = false` only when it
  genuinely must run at startup: the colorscheme, treesitter, the dashboard.
- Plugin keymaps go in the plugin's spec; `keymaps.lua` is only for mappings
  that work with zero plugins loaded.
- Anything shared between plugins (icons, border chars, toggle state) goes in
  `utils/` or `lsp/`, never required from one plugin spec into another.

## Toggles

| Key          | Action                        |
| ------------ | ----------------------------- |
| `<leader>?`  | which-key                     |
| `<leader>w`  | line wrap                     |
| `<leader>ud` | inline (virtual line) diagnostics |
| `<leader>uf` | format on save                |

## Requirements

- Neovim >= 0.11 (uses `vim.lsp.config`, `vim.diagnostic.jump`, `vim.hl`)
- Git, a C compiler and `make` (treesitter parsers, telescope-fzf-native)
- Optional: `~/.config/digimons` for the dashboard sprites — the config works
  fine without it.
