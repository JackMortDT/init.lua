return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {},
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      -- Needed at config time for `get_lsp_capabilities()`, which has to be
      -- set on the '*' base config before any server attaches.
      "saghen/blink.cmp",
    },
    config = function()
      require("jack.lsp").setup()

      -- blink.cmp advertises richer completion capabilities (snippets,
      -- resolve, etc.) than nvim's built-in defaults; every server needs to
      -- see them, so this goes on the '*' base config rather than being
      -- repeated per server.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- Only useful for editing this config itself: makes lua_ls aware of
      -- the Neovim runtime (vim global, runtime Lua modules) so it stops
      -- flagging `vim.*` as undefined. Left alone (via the
      -- .luarc.json/.jsonc check) for any other Lua project, which manages
      -- its own lua_ls settings.
      -- Copied from the config snippet in nvim-lspconfig's own lua_ls docs
      -- (:help lspconfig-lua_ls, or lsp/lua_ls.lua in the plugin), which
      -- replaces what lsp-zero's `nvim_lua_ls()` used to build.
      vim.lsp.config("lua_ls", {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath("config")
              and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
            then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
              version = "LuaJIT",
              path = { "lua/?.lua", "lua/?/init.lua" },
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
      require("mason-lspconfig").setup({
        ensure_installed = { "clojure_lsp" },
        automatic_enable = {
          exclude = { "harper_ls" },
        },
      })
    end,
  },

  { "mason-org/mason-lspconfig.nvim", lazy = true },
}
