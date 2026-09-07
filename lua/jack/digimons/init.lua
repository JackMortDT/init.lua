-- Auto-loads every sibling file in this directory as a digimon entry.
--
-- To add a new one: drop a new file here (e.g. gabumon.lua) returning
--   return {
--     name = "Gabumon",
--     catchphrase = "🐺 Gabumon warp digivolve to... MetalGarurumon!",
--     art = { "line 1", "line 2", ... },
--     -- optional: shown under the catchphrase if present
--     stats = { hp = 1000, mp = 500, offense = 100, defense = 50, speed = 50, brains = 50 },
--   }
-- It will show up automatically, no other file needs to change.

local M = {}
M.digimons = {}

local this_file = debug.getinfo(1, "S").source:sub(2)
local dir = vim.fn.fnamemodify(this_file, ":h")

for _, path in ipairs(vim.fn.glob(dir .. "/*.lua", false, true)) do
  local modname = vim.fn.fnamemodify(path, ":t:r")
  if modname ~= "init" then
    local ok, digimon = pcall(require, "jack.digimons." .. modname)
    if ok and type(digimon) == "table" and digimon.art and digimon.catchphrase then
      table.insert(M.digimons, digimon)
    else
      vim.notify(
        "jack.digimons: failed to load '" .. modname .. "': " .. tostring(digimon),
        vim.log.levels.WARN
      )
    end
  end
end

function M.random()
  -- os.time() alone is too coarse (second resolution) and the first
  -- math.random() draw right after seeding is weakly distributed for
  -- small ranges, so it tends to keep picking the same entry. Mix in
  -- hrtime (nanoseconds) and throw away a few warm-up draws.
  math.randomseed(os.time() + (vim.uv or vim.loop).hrtime())
  math.random()
  math.random()
  math.random()
  return M.digimons[math.random(#M.digimons)]
end

return M
