local toggleterm_manager = require("toggleterm-manager")
local actions = toggleterm_manager.actions

toggleterm_manager.setup {
  titles = {
    prompt = "Pick Term",
    results = "Terminals"
  },
  mappings = {
    i = {
      ["<CR>"] = { action = actions.create_and_name_term, exit_on_action = true },
      ["<C-d>"] = { action = actions.delete_term, exit_on_action = false },
    },
    n = {
      ["<CR>"] = { action = actions.create_and_name_term, exit_on_action = true },
      ["x"] = { action = actions.delete_term, exit_on_action = false },
    },
  },
}
