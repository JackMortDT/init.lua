# Neovim Configuration

A modular Neovim configuration in Lua, managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Directory Structure

```
nvim/
├── init.lua                   # Entry point, just requires jack
└── lua/jack/
    ├── init.lua               # Load order, see below
    ├── options.lua            # vim.opt settings and leader keys
    ├── keymaps.lua            # Core keymaps (no plugins involved)
    ├── toggles.lua            # Toggle registry: keymap + state + statusline icon
    ├── buffers.lua            # BufferKill: close a buffer, keep the layout
    ├── autocmds.lua           # Core autocommands
    ├── filetypes.lua          # vim.filetype.add rules
    ├── lazy.lua               # lazy.nvim bootstrap + setup
    ├── digimons/
    │   ├── init.lua           # Sprite loader, reads ~/.config/digimons
    │   └── partner.lua        # The session's digimon: float, stats, digivolve
    ├── lsp/
    │   ├── init.lua           # Diagnostic presentation + the LspAttach hook
    │   ├── keymaps.lua        # Buffer-local keymaps applied on LspAttach
    │   └── winbar.lua         # nvim-navic breadcrumbs, attached per client
    ├── utils/                 # Border chars, icons, small helpers
    └── plugins/               # One file per plugin, auto-imported by lazy
```

Load order is `options → keymaps → toggles → buffers → autocmds → filetypes → lazy`.
Options go first because `mapleader` must be set before any mapping is
defined; lazy goes last so plugin specs can override core mappings.

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

Declared in `lua/jack/toggles.lua`. One entry gives you the keymap, the
notification and the statusline indicator — lualine renders whatever is in
the registry, so there is nothing to wire up by hand.

```lua
require("jack.toggles").register({
  name = "wrap",
  desc = "line wrap",
  icon = "󰖶",          -- omit to keep it off the statusline
  keys = "<leader>uw",  -- string or list
  get = function() return vim.wo.wrap end,
  set = function(v) vim.wo.wrap = v end,
})
```

| Key                    | Toggle                            |
| ---------------------- | --------------------------------- |
| `<leader>ud`           | inline diagnostics on/off         |
| `<leader>uD`           | inline diagnostics: cursor line only ↔ every line |
| `<leader>uf`           | format on save (conform)          |
| `<leader>uw`, `<leader>w` | line wrap                      |
| `<leader>uh`           | search highlight (clears `*`)     |
| `<leader>us`           | spell check                       |

### Diagnostics

Inline diagnostics default to **cursor line only**, and do not refresh
while you're in insert mode. Both of those are deliberate: `virtual_lines =
true` gives every diagnostic its own screen line, so a half-typed Clojure
form produces one "unresolved symbol" line per binding and the file
visually triples in height as you type. Everything off the cursor line is
still marked with a sign and an undercurl; `<leader>uD` shows them all
inline when you actually want to read them, and `<leader>vd` opens the
float for the current line.

To see **all** of them at once there are two lists, both reading the same
`vim.diagnostic` store:

- `<leader>xx` — Trouble, a persistent window grouped by file. Use this to
  work through a backlog; it updates as you fix things.
- `gs` / `<leader>xt` — Telescope picker. Use this to jump to one specific
  diagnostic you half remember.

Both are **global**, not buffer-local on `LspAttach`: `vim.diagnostic` is
not LSP-only and the key should exist even with no client attached. `gd`
and `gr` do stay buffer-local, since those genuinely need a client.

Scope is wider than "open buffers": clojure-lsp analyses the whole project
and publishes per URI, so errors in files you never opened show up too
(nvim keeps them in unloaded buffers). `<leader>xX` narrows to the current
file.

## Other keys worth remembering

| Key | Action |
| --- | ------ |
| `<leader>?` | which-key |
| `<leader>ff` / `<leader>fg` | find / grep, scoped to the project around the current file |
| `<leader>fA` / `<leader>fG` | find / grep across the whole repo |
| `<leader>xx` / `<leader>xX` | diagnostics list: project / this buffer (Trouble) |
| `gs`, `<leader>xt` | diagnostics as a fuzzy picker (Telescope) |
| `<leader>bd` / `<leader>bD` | close buffer, keep the split layout (`:BufferKill`) |
| `<leader>U` | undo tree |
| `<leader>j` / `<leader>J` | flash jump / flash treesitter select |
| `<leader>ss` | substitute word under cursor (this file) |
| `<leader>sr` / `<leader>sw` | search & replace across the project (grug-far) |
| `*` / `g*` | mark every occurrence of the word under the cursor, **without moving** (whole word / substring) |
| `*` (visual) | mark every occurrence of the selection, literally |
| `zR` / `zM` / `zK` | open all folds / close all / peek fold |
| `ysiw"` `cs"'` `ds"` | nvim-surround |
| `<localleader>` (`,`) | paredit, in Lisp buffers |

## Digimon partner

One digimon is picked per session from `~/.config/digimons` and sticks
around: the dashboard header, the statusline name and `:Digimon` all show
the same one (`jack/digimons/partner.lua` memoizes the pick, so nothing
rolls its own).

| | |
|---|---|
| `:Digimon`, `<leader>d` | float with the sprite and **live** stats |
| `:Digimon reroll` | pick a new partner |

Dashboard stats are the sprite's base values — the character sheet you
started with. The float's are derived from the session: HP is the base
minus diagnostic damage (errors ×10, warnings ×2), OFF/DEF are unstaged
lines added/removed from gitsigns, MP notes attached LSP clients, SPD is
lazy's startup time, BRN notes loaded plugins.

**Digivolve:** when a buffer goes from having errors to having none, the
partner's `catchphrase` fires as a notification. It only triggers on that
transition — not on files that were already clean, not twice in a row, and
not for warnings.

The whole directory is optional. With no sprites installed everything
no-ops: no statusline component, and `:Digimon` says where it looked.

## Scala / Metals

`nvim-metals` drives Metals itself — it is excluded from
`mason-lspconfig`'s `automatic_enable`, since letting lspconfig also start a
client gives you two fighting over the same buffer.

Build server is **Bloop**, not sbt BSP, despite sbt BSP being the better fit
for a monorepo on paper. sbt BSP reportedly does not work against the sbt
1.4.x that the monorepo this was set up for pins. Flip it with
`vim.g.jack_metals_sbt_bsp = true`.

The build JDK is resolved by reading each candidate's own `release` file,
never by trusting `/usr/libexec/java_home -v <version>` — on this machine
that exits 0 and hands back a JDK 26 install no matter which version you
ask for. `:MetalsJdk` shows what was picked and whether it satisfies the
project's `.java-version`; a mismatch warns once per project per session.

## Monorepos

`<leader>ff` and `<leader>fg` scope themselves to the innermost directory
above the current file that looks like a project (`src/`, `build.sbt`,
`project.clj`, `deps.edn`, ...), clamped to the editor's cwd.
`<leader>fA` / `<leader>fG` are the unscoped versions.

In a single-project repo both pairs do the same thing, so this costs
nothing there. It matters in a monorepo: on a ~115k-file Scala repo a
content search takes ~2.85s from the repo root versus ~51ms
inside one subproject — and `live_grep` re-runs ripgrep on every keystroke,
so the unscoped version is unusable for typing.

## Large files

`bigfile.nvim` turns off the per-buffer machinery past 2 MiB: treesitter,
syntax, LSP, indent guides, colorizer, gitsigns, rainbow-delimiters and
ufo.

Two of its *built-in* features are dead against this config — its
`treesitter` feature drives `nvim-treesitter.configs`, which no longer
exists on the `main` branch, and `indent_blankline` calls the ibl v2 API.
Both fail silently through a pcall, so `plugins/bigfile.lua` replaces them
with custom ones.

**If you add a plugin that walks the whole buffer, add a feature for it
here too.** rainbow-delimiters and ufo alone took a 13 MB JSON from 0.6 s
to 2.9 s to open before they were added to this list.

## Requirements

- Neovim >= 0.11 (uses `vim.lsp.config`, `vim.diagnostic.jump`, `vim.hl`)
- Mason installs `clojure_lsp`, `jsonls` and `lua_ls`. lua_ls is what gives
  this config itself diagnostics and `vim.*` completion; it needs a project
  root (`.git` or `.luarc.json`) to analyse anything, which this repo has.
- Git, a C compiler and `make` (treesitter parsers, telescope-fzf-native)
- Optional: `~/.config/digimons` for the dashboard sprites — the config works
  fine without it.
