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
      "b0o/schemastore.nvim",
      "SmiteshP/nvim-navic",
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

      -- Schema validation and key completion for JSON. Matters here
      -- because of the `*.json.base` filetype rule in jack/filetypes.lua:
      -- those are config files, and without a schema jsonls can only check
      -- that the braces balance.
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- mason-lspconfig's automatic_enable is what replaces lsp-zero's
      -- default_setup: every Mason-installed server gets `vim.lsp.enable()`'d
      -- using nvim-lspconfig's built-in defaults (or the overrides above, for
      -- lua_ls) with no per-server boilerplate needed here.
      require("mason-lspconfig").setup({
        -- lua_ls is here for this config itself: the `vim.lsp.config`
        -- block above tunes it for the Neovim runtime, and without the
        -- server actually installed all of that was dead code.
        ensure_installed = { "clojure_lsp", "jsonls", "lua_ls" },
        automatic_enable = {
          -- metals is driven by nvim-metals (plugins/metals.lua), which
          -- installs the server and attaches the client itself. Letting
          -- lspconfig enable it too starts a second client on the same
          -- buffer.
          exclude = { "harper_ls", "metals" },
        },
      })
    end,
  },

  { "mason-org/mason-lspconfig.nvim", lazy = true },
  { "b0o/schemastore.nvim", lazy = true },
}
