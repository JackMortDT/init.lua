-- Core autocommands. Plugin-specific ones live with their plugin spec.
local function augroup(name)
  return vim.api.nvim_create_augroup("jack_" .. name, { clear = true })
end

-- Briefly highlight whatever was just yanked.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- Reopen a file where you left it, unless the mark points past the end of
-- the file (happens after the file shrank outside of nvim).
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_location"),
  callback = function(args)
    if vim.bo[args.buf].filetype == "gitcommit" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- `q` closes throwaway windows instead of starting a macro recording.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help",
    "man",
    "qf",
    "checkhealth",
    "lspinfo",
    "notify",
    "startuptime",
    "query",
  },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true, desc = "Close window" })
  end,
})

-- Make `gf` work on Lua module names, so `require("jack.utils")` jumps to
-- lua/jack/utils/init.lua. Handy when the thing you edit most is this
-- config. Lifted from LunarVim, which credits sam4llis/nvim-lua-gf.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("lua_gf"),
  pattern = "lua",
  callback = function()
    ---@diagnostic disable-next-line: assign-type-mismatch
    vim.opt_local.include = [[\v<((do|load)file|require|reload)[^''"]*[''"]\zs[^''"]+]]
    vim.opt_local.includeexpr = "substitute(v:fname,'\\.','/','g')"
    vim.opt_local.suffixesadd:prepend(".lua")
    vim.opt_local.suffixesadd:prepend("init.lua")

    for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
      vim.opt_local.path:append(path .. "/lua")
    end
  end,
})

-- Strip trailing whitespace on save, keeping the cursor put. Skips markdown,
-- where two trailing spaces are a meaningful line break.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trim_whitespace"),
  callback = function(args)
    if vim.bo[args.buf].filetype == "markdown" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Create missing parent directories rather than failing the write.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_mkdir"),
  callback = function(args)
    if args.match:match("^%w%w+://") then
      return
    end
    local file = vim.uv.fs_realpath(args.match) or args.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Rebalance splits when the terminal (or tmux pane) is resized.
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})
