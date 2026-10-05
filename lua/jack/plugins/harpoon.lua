-- Build the <leader>1..4 jump mappings programmatically so the spec and the
-- loop stay in one place.
local keys = {
  { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
  {
    "<leader>e",
    function()
      local harpoon = require("harpoon")
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end,
    desc = "Harpoon quick menu",
  },
}

for i = 1, 4 do
  table.insert(keys, {
    "<leader>" .. i,
    function() require("harpoon"):list():select(i) end,
    desc = "Harpoon to file " .. i,
  })
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = keys,
  config = function()
    require("harpoon"):setup()
  end,
}
