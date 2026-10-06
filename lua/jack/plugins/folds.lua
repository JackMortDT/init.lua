-- Folding, made visible.
--
-- Windows that should have no gutter at all. Used for both statuscol's
-- ft_ignore and the 'foldcolumn' autocmd below, so the two can't drift
-- apart.
local UI_FILETYPES = {
  "dashboard",
  "neo-tree",
  "lazy",
  "mason",
  "help",
  "man",
  "qf",
  "grug-far",
  "trouble",
  "undotree",
  "diff",
  "checkhealth",
  "digimon",
}
--
-- The config already had treesitter folding (foldmethod=expr +
-- vim.treesitter.foldexpr), but with foldcolumn=0 there was no way to see
-- where a fold was. ufo takes over the fold ranges -- so the foldmethod
-- lines are gone from the treesitter autocmd -- and statuscol draws the
-- column.
return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "zR", function() require("ufo").openAllFolds() end,  desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
      {
        "zK",
        function()
          -- Peek inside a fold without opening it; falls back to hover
          -- when the cursor isn't on one.
          if not require("ufo").peekFoldedLinesUnderCursor() then
            vim.lsp.buf.hover()
          end
        end,
        desc = "Peek fold",
      },
    },
    opts = {
      -- `treesitter` here is ufo's own provider, which talks to
      -- vim.treesitter directly -- it does not need nvim-treesitter's
      -- legacy `configs` module, so it works with the `main` branch.
      -- `indent` covers filetypes with no parser installed.
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      -- Fold text: the first line, then how many lines are hidden.
      fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
        local suffix = ("  󰁂 %d"):format(end_lnum - lnum)
        local cur_width = 0
        local result = {}

        for _, chunk in ipairs(virt_text) do
          local chunk_text = chunk[1]
          local chunk_width = vim.fn.strdisplaywidth(chunk_text)
          if width > cur_width + chunk_width then
            table.insert(result, chunk)
          else
            chunk_text = truncate(chunk_text, width - cur_width)
            table.insert(result, { chunk_text, chunk[2] })
            break
          end
          cur_width = cur_width + chunk_width
        end

        table.insert(result, { suffix, "MoreMsg" })
        return result
      end,
    },
  },

  {
    "luukvbaal/statuscol.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local builtin = require("statuscol.builtin")

      require("statuscol").setup({
        -- Click handlers come from statuscol's own segments rather than
        -- nvim's default statuscolumn.
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { text = { "%s" }, click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        },
        ft_ignore = UI_FILETYPES,
        bt_ignore = { "terminal", "nofile" },
      })

      -- statuscol's foldfunc segment only renders while 'foldcolumn' is
      -- non-zero, so options.lua has to set it globally. But ft_ignore
      -- only clears 'statuscolumn' -- it leaves 'foldcolumn' alone, and
      -- vim then draws its *own* fold column (nesting-level digits, '-'
      -- for an open fold) in exactly the windows meant to have no gutter.
      -- That showed up as a column of numbers down the side of neo-tree.
      --
      -- Scheduled because neo-tree and the dashboard set their own window
      -- options after FileType fires.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("jack_no_foldcolumn", { clear = true }),
        pattern = UI_FILETYPES,
        callback = function()
          local win = vim.api.nvim_get_current_win()
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(win) then
              vim.wo[win].foldcolumn = "0"
            end
          end)
        end,
      })
    end,
  },
}
