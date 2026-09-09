local parsers = { "lua", "clojure", "elixir", "json" }
local filetypes = { "lua", "clojure", "elixir", "json", "jsonc" }

require('nvim-treesitter').install(parsers)

vim.treesitter.language.register("json", "jsonc")

vim.api.nvim_create_autocmd('FileType', {
  pattern = filetypes,
  callback = function()
    vim.treesitter.start()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})
