-- Disables the expensive per-buffer machinery when a file is large enough
-- that treesitter + colorizer + gitsigns + indent guides would lock nvim up.
--
-- Two of bigfile's built-in features are dead against this config: its
-- `treesitter` feature drives `nvim-treesitter.configs`, which no longer
-- exists on the plugin's `main` branch, and `indent_blankline` calls the
-- ibl v2 API. Both fail silently through a pcall. So those two are replaced
-- with custom features below, along with ones bigfile doesn't ship at all.
return {
  "LunarVim/bigfile.nvim",
  -- Not lazy: it registers a BufReadPre hook and has to be in place before
  -- the first file is read, which is exactly the event that would load it.
  lazy = false,
  opts = {
    filesize = 2, -- MiB
    features = {
      "lsp",
      "matchparen",
      "syntax",
      "vimopts",
      {
        -- The FileType autocmd in plugins/treesitter.lua checks this flag
        -- before calling vim.treesitter.start().
        name = "treesitter_main",
        disable = function(buf)
          vim.b[buf].jack_bigfile = true
        end,
      },
      {
        name = "ibl_v3",
        disable = function(buf)
          pcall(function()
            require("ibl").setup_buffer(buf, { enabled = false })
          end)
        end,
      },
      {
        name = "colorizer",
        disable = function(buf)
          pcall(function()
            require("colorizer").detach_from_buffer(buf)
          end)
        end,
      },
      {
        name = "gitsigns",
        disable = function(buf)
          pcall(function()
            require("gitsigns").detach(buf)
          end)
        end,
      },
      {
        -- Rainbow walks every delimiter in the buffer. On a few hundred
        -- thousand lines of JSON that is the single most expensive thing
        -- left running.
        name = "rainbow_delimiters",
        disable = function(buf)
          pcall(function()
            require("rainbow-delimiters").disable(buf)
          end)
        end,
      },
      {
        -- ufo computes fold ranges for the whole buffer up front.
        name = "ufo",
        disable = function(buf)
          pcall(function()
            require("ufo").detach(buf)
            require("ufo").disableFold(buf)
          end)
        end,
      },
    },
  },
}
