local config = {}

config.project = {
    label = " Recent Projects",
    limit = 10,
}
config.mru = {
    enable = false
}

config.shortcut = {
    {
        desc = " 󰱼  File ",
        action = "Telescope find_files find_command=rg,--hidden,--files",
        group = "@string",
        key = "fF",
    },
    {
        desc = "   Update ",
        action = "Lazy sync",
        group = "@string",
        key = "u",
    },
    {
        desc = " 󰓅  Profile ",
        action = "Lazy profile",
        group = "@string",
        key = "p",
    },
    {
        desc = " 󰅙  Quit ",
        action = "q!",
        group = "DiagnosticError",
        key = "q",
    },
}

config.week_header = { enable = true }
config.footer = { "", "󰛨  Dala what you must" }
config.packages = { enable = true }

require("dashboard").setup({
    theme = "hyper",
    config = config,
})
