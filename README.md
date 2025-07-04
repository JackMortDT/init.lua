# Neovim Configuration

A modular Neovim configuration setup using Lua.

## Directory Structure

```
nvim/
├── init.lua                 # Main entry point
├── jack/
│   ├── init.lua            # Module initialization
│   ├── keymaps.lua         # Key mappings
│   ├── options.lua         # Neovim options and settings
│   └── plugins.lua         # Plugin management with lazy.nvim
└── README.md               # This file
```

## Features

- **Modular Architecture**: Configuration split into logical modules
- **Plugin Management**: Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for efficient plugin loading
- **Custom Keymaps**: Personalized key bindings for improved workflow
- **Optimized Options**: Tailored Neovim settings for better experience

## Installation

1. Clone or copy this configuration to your Neovim config directory:
   ```bash
   ~/.config/nvim/
   ```

2. Start Neovim and let lazy.nvim automatically install plugins:
   ```bash
   nvim
   ```

## Key Components

- **init.lua**: Entry point that loads the main configuration module
- **jack/**: Main configuration module containing all settings
- **Plugin System**: Lazy-loaded plugins for optimal startup performance
- **Custom Settings**: Personalized options and keymaps

## Requirements

- Neovim >= 0.8
- Git (for plugin management)

---

*Configuration optimized for development workflow and productivity.*