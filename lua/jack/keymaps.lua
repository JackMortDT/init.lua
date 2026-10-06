-- Core keymaps only: everything here works with zero plugins loaded.
-- Plugin keymaps live in that plugin's spec under lua/jack/plugins/, so
-- lazy.nvim can use them as load triggers.
local map = vim.keymap.set

-- Move the visual selection up/down, re-indenting as it goes.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Join without losing the cursor column.
map("n", "J", "mzJ`z", { desc = "Join line" })

-- Keep the cursor centered while jumping around.
-- NOTE: <C-d>/<C-u> are owned by neoscroll (see plugins/neoscroll.lua),
-- which registers them as lazy-load triggers and would override anything
-- set here anyway.
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })

-- Mark every occurrence of the word under the cursor without moving.
--
-- Native * sets the search register and immediately jumps to the next
-- match, so "show me where else this appears" costs you your cursor
-- position. These set the register and turn highlighting on, nothing else:
-- n/N still walk the matches when you actually want to go somewhere.
--
--   *   whole word   (\<word\>)
--   g*  substring    (matches inside longer identifiers)
local function mark(pattern)
  if pattern == "" then
    return
  end
  vim.fn.setreg("/", pattern)
  vim.fn.histadd("search", pattern)
  vim.v.hlsearch = 1
end

map("n", "*", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return
  end
  mark([[\<]] .. vim.fn.escape(word, [[\/]]) .. [[\>]])
end, { desc = "Mark word under cursor" })

map("n", "g*", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return
  end
  mark(vim.fn.escape(word, [[\/]]))
end, { desc = "Mark word under cursor (partial)" })

map("x", "*", function()
  -- getregion reads the selection directly, so no register gets clobbered
  -- (yanking into one would stomp on whatever the user had there).
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

  local selection = table.concat(lines, "\n")
  if selection == "" then
    return
  end
  -- \V: everything after it is literal except the backslash, so searching
  -- for a selection full of regex metacharacters just works.
  mark([[\V]] .. vim.fn.escape(selection, [[\/]]):gsub("\n", [[\n]]))
end, { desc = "Mark selection" })

-- Yank straight to the system clipboard.
map({ "n", "v" }, "y", '"+y', { desc = "Yank to clipboard" })
map("n", "Y", '"+y', { desc = "Yank to clipboard" })

-- <leader>s is the search-and-replace group; the rest of it (grug-far,
-- project-wide) lives in plugins/grug-far.lua. This one stays here because
-- it's plain :substitute and needs no plugin.
map("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute word under cursor (this file)" })

map("i", "<C-c>", "<Esc>", { desc = "Escape" })

map("n", "<leader><leader>", "<cmd>source<cr>", { desc = "Source current file" })

-- NOTE: <leader>w (line wrap) and the rest of the <leader>u toggles are
-- registered declaratively in jack/toggles.lua.

-- Move by display line when wrapped, by real line otherwise (and always by
-- real line when a count is given, so 5j still lands where relative numbers
-- say it should).
map("n", "j", "v:count || !&wrap ? 'j' : 'gj'", { expr = true, desc = "Down" })
map("n", "k", "v:count || !&wrap ? 'k' : 'gk'", { expr = true, desc = "Up" })
