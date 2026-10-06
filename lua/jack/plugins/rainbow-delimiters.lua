-- Nested delimiters get alternating colors. In Clojure this is less
-- decoration than navigation: it's how you tell which paren closes what.
-- Pairs with nvim-paredit.
return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "AlexvZyl/nordic.nvim" },
  config = function()
    local C = require("nordic.colors")

    -- Ordered light-to-dark-ish rotation picked from the nordic palette so
    -- the cycle reads as distinct levels rather than confetti. Red is left
    -- out: it's what rainbow-delimiters uses for unmatched delimiters.
    local levels = {
      { "RainbowDelimiterYellow",  C.yellow.base },
      { "RainbowDelimiterBlue",    C.blue1 },
      { "RainbowDelimiterOrange",  C.orange.base },
      { "RainbowDelimiterGreen",   C.green.base },
      { "RainbowDelimiterViolet",  C.magenta.base },
      { "RainbowDelimiterCyan",    C.cyan.base },
    }
    local order = {}
    for _, level in ipairs(levels) do
      vim.api.nvim_set_hl(0, level[1], { fg = level[2] })
      table.insert(order, level[1])
    end
    vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = C.red.base })

    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = "rainbow-delimiters.strategy.global",
        -- Lisps nest deeply enough that re-colouring the whole buffer on
        -- every keystroke is wasteful; only the local form needs updating.
        clojure = "rainbow-delimiters.strategy.local",
      },
      query = {
        [""] = "rainbow-delimiters",
        lua = "rainbow-blocks",
      },
      highlight = order,
    }
  end,
}
