-- nvim-treesitter `main` branch: no `setup()`, no `ensure_installed`.
-- Parsers are installed imperatively and highlighting/folding is started
-- per filetype by hand.
-- markdown/markdown_inline are here for render-markdown.nvim, which needs
-- both parsers to render anything.
local parsers = { "lua", "clojure", "elixir", "json", "markdown", "markdown_inline" }
local filetypes = { "lua", "clojure", "elixir", "json", "jsonc", "markdown" }

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
        callback = function()
          vim.treesitter.start()
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
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
