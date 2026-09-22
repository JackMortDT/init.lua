-- Same keys as the old nvim-cmp setup, mapped onto blink.cmp's action names.
-- No LuaSnip: blink ships its own snippet engine, so `snippet_forward` /
-- `snippet_backward` cover what LuaSnip's expand_or_jump / jump(-1) did.
require('blink.cmp').setup({
  keymap = {
    preset = 'none',
    ['<C-j>'] = { 'select_next', 'fallback' },
    ['<C-k>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<C-Leader>'] = { 'show', 'fallback' },
    ['<C-e>'] = { 'hide', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
  },
  completion = {
    list = { selection = { preselect = false } },
    documentation = { auto_show = true },
  },
  -- Prebuilt fuzzy matcher binary; falls back to the Lua implementation
  -- automatically if a platform build isn't available.
  fuzzy = { implementation = 'prefer_rust_with_warning' },
})
