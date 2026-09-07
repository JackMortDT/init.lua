-- Loads the Digimon sprites from ~/.config/digimons, which is shared with the
-- fastfetch wrapper and lives in the dotfiles repo rather than in here. They
-- used to exist twice, as Lua tables here and as raw text there, kept in sync
-- by hand.
--
-- The directory is entirely optional: on a machine without the dotfiles repo
-- this returns an empty list and every consumer is expected to cope. See
-- the format description in that directory's README.
local M = {}

-- Same base the fastfetch wrapper uses, so both sides agree on where the
-- sprites are even when XDG_CONFIG_HOME is set.
local config_home = vim.env.XDG_CONFIG_HOME
if config_home == nil or config_home == "" then
  config_home = vim.fn.expand("~/.config")
end
M.dir = config_home .. "/digimons"

-- Header lines are `key: value` until the first blank line; everything after
-- it is art, taken verbatim. No trimming: the sprites are padded to a
-- rectangle and losing the trailing spaces would skew the drawing.
local function parse(path)
  local d = { art = {} }
  local in_art = false

  local ok, err = pcall(function()
    for line in io.lines(path) do
      if in_art then
        table.insert(d.art, line)
      elseif line == "" then
        in_art = true
      else
        local key, value = line:match("^(%w+):%s*(.*)$")
        if key == "stats" then
          d.stats = {}
          for k, v in value:gmatch("(%w+)=(%d+)") do
            d.stats[k] = tonumber(v)
          end
        elseif key then
          d[key] = value
        end
      end
    end
  end)

  if not ok then
    return nil, err
  end
  if not d.name or #d.art == 0 then
    return nil, "no name or no art"
  end
  return d
end

M.digimons = {}

if vim.fn.isdirectory(M.dir) == 1 then
  for _, path in ipairs(vim.fn.glob(M.dir .. "/*.digimon", false, true)) do
    local digimon, err = parse(path)
    if digimon then
      table.insert(M.digimons, digimon)
    else
      vim.notify(
        "jack.digimons: skipping '" .. vim.fn.fnamemodify(path, ":t") .. "': " .. tostring(err),
        vim.log.levels.WARN
      )
    end
  end
end

-- Returns nil when there are none, rather than erroring the way
-- math.random(0) would. Callers have to handle that.
function M.random()
  if #M.digimons == 0 then
    return nil
  end
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
