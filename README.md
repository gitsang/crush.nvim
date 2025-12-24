# crush.nvim

[中文](./README.zh-CN.md)

A Neovim plugin that opens a terminal with the [Crush CLI](https://github.com/charmbracelet/crush) in a vertical split.

![Preview](./resources/Preview.gif)

## 1. Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'gitsang/crush.nvim',
  opts = {
    width = 80, -- Width of the vertical split
    fixed_width = true, -- Whether to fix the width (true = locked, false = adjustable)
    crush_cmd = "crush --yolo", -- Command to run in the terminal
    copy_to_clipboard = false, -- Copy to system clipboard
    actions = {},
  },
  cmd = { "Crush", "CrushFilePos", "CrushActions" },
  keys = {
    { "<leader>CC", "<cmd>Crush<cr>", desc = "Toggle Crush", mode = { "n", "v" } },
    { "<leader>CP", ":'<,'>CrushFilePos<cr>", desc = "Copy file path and line info", mode = { "n", "v" } },
    { "<leader>CA", ":'<,'>CrushActions<cr>", desc = "Run Crush actions", mode = { "n", "v" } },
  },
}
```

## 2. Usage

After installation, you can run the following commands:

### 2.1 Crush Command

Run the `:Crush` command to open a terminal in a vertical split running the crush command.

### 2.2 CrushFilePos Command

The `:CrushFilePos` command copies the relative file path and line/column information to the clipboard in various visual modes, then send it to crush.

### 2.3 CrushActions Command

The `:CrushActions` command allows you to define custom actions that can be executed from a popup selector.

You can find how to define your own actions in [Custom Actions Tutorial](docs/actions.md)
