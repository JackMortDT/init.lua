-- Entry point. Order matters: options (incl. mapleader) must land before any
-- keymap is defined, and lazy must come last so plugin specs see the final
-- leader key and can safely override core mappings.
require("jack.options")
require("jack.keymaps")
require("jack.toggles")
require("jack.buffers").setup()
require("jack.digimons.partner").setup()
require("jack.autocmds")
require("jack.filetypes")
require("jack.lazy")
