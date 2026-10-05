-- Animated scrolling. These mappings double as lazy-load triggers, which
-- is why they are declared as `keys` rather than set in config.
local DURATION = 200

local function scroll(fn, arg)
  return function()
    require("neoscroll")[fn]({ [arg] = DURATION })
  end
end

local modes = { "n", "v", "x" }

return {
  "karb94/neoscroll.nvim",
  keys = {
    { "<C-u>", scroll("ctrl_u", "duration"), mode = modes, desc = "Scroll half page up" },
    { "<C-d>", scroll("ctrl_d", "duration"), mode = modes, desc = "Scroll half page down" },
    { "<C-b>", scroll("ctrl_b", "duration"), mode = modes, desc = "Scroll page up" },
    { "<C-f>", scroll("ctrl_f", "duration"), mode = modes, desc = "Scroll page down" },
    { "zt",    scroll("zt", "half_win_duration"), mode = modes, desc = "Cursor to top" },
    { "zz",    scroll("zz", "half_win_duration"), mode = modes, desc = "Cursor to center" },
    { "zb",    scroll("zb", "half_win_duration"), mode = modes, desc = "Cursor to bottom" },
  },
  opts = {},
}
