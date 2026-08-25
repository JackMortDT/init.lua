local parsers = { "lua", "clojure", "elixir" }

require('nvim-treesitter').install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  pattern = parsers,
  callback = function()
    vim.treesitter.start()
  end,
})
