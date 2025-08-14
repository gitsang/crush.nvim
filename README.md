# crush.nvim

A Neovim plugin that opens a terminal with the crush command in a vertical
split.

## 1. Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'gitsang/crush.nvim',
  opts = {
    width = 80,      -- Width of the vertical split
    crush_cmd = "crush"  -- Command to run in the terminal
  },
  cmd = { "Crush" },
  keys = {
    { "<leader>C", "<cmd>Crush<cr>", desc = "Toggle Crush" },
  },
}
```

## 2. Usage

After installation, you can run the `:Crush` command to open a terminal in a
vertical split running the crush command.

### 2.1 Configuration

The plugin can be configured with the following options:

- `width`: Integer for the vertical split width (default: 80)
- `crush_cmd`: String for the command to run (default: "crush")

Example configuration:

```lua
require('crush').setup({
  width = 100,
  crush_cmd = "crush --help"
})
```

Then run `:Crush` to open the terminal.
