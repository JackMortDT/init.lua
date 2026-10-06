-- Jump anywhere on screen by typing the characters you're aiming at and
-- then the label that appears next to the match.
--
-- `s` is deliberately not remapped to flash's jump: it's a useful vim
-- command and paredit/surround users reach for it. Jump lives on <leader>j
-- instead; search (/ and ?) gets labels for free.
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>j", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash jump" },
    { "<leader>J", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter select" },
    { "r",         mode = "o",               function() require("flash").remote() end,     desc = "Remote flash" },
  },
  opts = {
    -- Labels on / and ? results, so n/N becomes "pick the one I want".
    search = { enabled = true },
    char = {
      -- f/t/F/T get flash labels for repeats, but keep `;`/`,` working the
      -- way they always have.
      enabled = true,
      jump_labels = true,
    },
    modes = {
      -- No labels while typing a normal search; they only appear once the
      -- pattern stops changing. Less visual churn.
      search = { enabled = true },
    },
  },
}
