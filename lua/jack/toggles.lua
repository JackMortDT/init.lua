-- Toggle registry.
--
-- Every on/off switch in the config is declared once here with its state
-- accessor, its keymap and its statusline icon, instead of being spread
-- across a keymap, a module-level boolean and a hardcoded lualine
-- component. lualine renders whatever is registered, so adding a toggle is
-- one table entry and nothing else.
--
-- Inspired by lvim-tech's "control center", minus the UI.
local M = {}

---@class Toggle
---@field name string        stable id, used by get/set/toggle
---@field desc string        human label, shown in notifications and which-key
---@field icon string|nil    statusline icon; omit to keep it off the statusline
---@field keys string|table|nil  keymap(s) under <leader>u
---@field get fun():boolean
---@field set fun(value:boolean)

---@type Toggle[]
M.items = {}

local by_name = {}

---@param item Toggle
function M.register(item)
  table.insert(M.items, item)
  by_name[item.name] = item

  local keys = item.keys
  if type(keys) == "string" then
    keys = { keys }
  end
  for _, lhs in ipairs(keys or {}) do
    vim.keymap.set("n", lhs, function()
      M.toggle(item.name)
    end, { desc = "Toggle " .. item.desc })
  end
end

---@param name string
function M.get(name)
  local item = by_name[name]
  return item ~= nil and item.get() or false
end

---@param name string
---@param value boolean
function M.set(name, value)
  local item = assert(by_name[name], "unknown toggle: " .. name)
  item.set(value)
  require("jack.utils").refresh_statusline()
end

---@param name string
function M.toggle(name)
  local item = assert(by_name[name], "unknown toggle: " .. name)
  local value = not item.get()
  item.set(value)
  vim.notify(item.desc .. " " .. (value and "on" or "off"))
  require("jack.utils").refresh_statusline()
end

-- Builds the lualine components for every toggle that declared an icon.
-- `on`/`off` are lualine color specs.
function M.lualine_components(on, off)
  local components = {}
  for _, item in ipairs(M.items) do
    if item.icon then
      table.insert(components, {
        function()
          return item.icon
        end,
        color = function()
          return item.get() and on or off
        end,
        padding = { left = 0, right = 1 },
      })
    end
  end
  if components[1] then
    components[1].separator = { " ", "" }
  end
  return components
end

--------------------------------------------------------------------------
-- Registrations
--------------------------------------------------------------------------

-- Plugin-backed toggles require their plugin inside the closure, so a
-- lazy-loaded plugin only gets pulled in when the toggle is actually used.

M.register({
  name = "diagnostics",
  desc = "inline diagnostics",
  icon = "",
  keys = "<leader>ud",
  get = function()
    return require("jack.lsp").virtual_diagnostics
  end,
  set = function(value)
    require("jack.lsp").set_virtual_diagnostics(value)
  end,
})

M.register({
  name = "diagnostics_all",
  desc = "diagnostics on every line",
  icon = "󰍉",
  keys = "<leader>uD",
  get = function()
    return require("jack.lsp").diagnostics_all_lines
  end,
  set = function(value)
    require("jack.lsp").set_diagnostics_all_lines(value)
  end,
})

M.register({
  name = "format",
  desc = "format on save",
  icon = "󰉼",
  keys = "<leader>uf",
  get = function()
    return vim.g.jack_format_on_save == true
  end,
  set = function(value)
    vim.g.jack_format_on_save = value
  end,
})

M.register({
  name = "wrap",
  desc = "line wrap",
  icon = "󰖶",
  -- <leader>w kept as an alias: it predates the <leader>u toggle group and
  -- is in muscle memory.
  keys = { "<leader>uw", "<leader>w" },
  get = function()
    return vim.wo.wrap
  end,
  set = function(value)
    vim.wo.wrap = value
    vim.wo.linebreak = value
    vim.wo.breakindent = value
  end,
})

-- No statusline icon: search highlighting changes too often for a
-- persistent indicator to mean anything.
M.register({
  name = "hlsearch",
  desc = "search highlight",
  keys = "<leader>uh",
  get = function()
    return vim.v.hlsearch == 1
  end,
  set = function(value)
    if value then
      vim.v.hlsearch = 1
    else
      vim.cmd("nohlsearch")
    end
  end,
})

M.register({
  name = "spell",
  desc = "spell check",
  keys = "<leader>us",
  get = function()
    return vim.wo.spell
  end,
  set = function(value)
    vim.wo.spell = value
  end,
})

return M
