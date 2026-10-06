-- nvim-treesitter `main` branch: no `setup()`, no `ensure_installed`.
-- Parsers are installed imperatively and highlighting/folding is started
-- per filetype by hand.
-- markdown/markdown_inline are here for render-markdown.nvim, which needs
-- both parsers to render anything.
local parsers = { "lua", "clojure", "elixir", "json", "markdown", "markdown_inline", "scala" }
local filetypes = { "lua", "clojure", "elixir", "json", "jsonc", "markdown", "scala" }

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(parsers)

      -- jsonc has no parser of its own; the json one handles it fine.
      vim.treesitter.language.register("json", "jsonc")

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("jack_treesitter", { clear = true }),
        pattern = filetypes,
        callback = function(args)
          -- Set by bigfile.nvim; parsing a multi-MiB file freezes nvim.
          if vim.b[args.buf].jack_bigfile then
            return
          end
          vim.treesitter.start()
          -- Folding is nvim-ufo's now (see plugins/folds.lua); setting
          -- foldmethod/foldexpr here would fight it for the window.
        end,
      })
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}
