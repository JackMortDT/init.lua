require('mason').setup({})

-- blink.cmp advertises richer completion capabilities (snippets, resolve,
-- etc.) than nvim's built-in defaults; every server needs to see them, so
-- this goes on the '*' base config rather than being repeated per server.
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- Only useful for editing this config itself: makes lua_ls aware of the
-- Neovim runtime (vim global, runtime Lua modules) so it stops flagging
-- `vim.*` as undefined. Left alone (via the .luarc.json/.jsonc check) for
-- any other Lua project, which manages its own lua_ls settings.
-- Copied from the config snippet in nvim-lspconfig's own lua_ls docs
-- (:help lspconfig-lua_ls, or lsp/lua_ls.lua in the plugin), which replaces
-- what lsp-zero's `nvim_lua_ls()` used to build.
vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath('config')
        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT',
        path = { 'lua/?.lua', 'lua/?/init.lua' },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
        },
      },
    })
  end,
  settings = { Lua = {} },
})

-- mason-lspconfig's automatic_enable is what replaces lsp-zero's
-- default_setup: every Mason-installed server gets `vim.lsp.enable()`'d
-- using nvim-lspconfig's built-in defaults (or the overrides above, for
-- lua_ls) with no per-server boilerplate needed here.
require('mason-lspconfig').setup({
  ensure_installed = { 'clojure_lsp' },
  automatic_enable = {
    exclude = { 'harper_ls' },
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr, remap = false }
    local telescope_opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "gd", function() require('telescope.builtin').lsp_definitions() end, telescope_opts)
    vim.keymap.set("n", "gs", function() require('telescope.builtin').diagnostics() end, telescope_opts)
    vim.keymap.set("n", "gr", function() require('telescope.builtin').lsp_references() end, telescope_opts)
    vim.keymap.set("n", "ga", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "gf", function() vim.lsp.buf.format({ async = true }) end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  end,
})
