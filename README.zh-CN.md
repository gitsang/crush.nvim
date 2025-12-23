# crush.nvim

[English](./README.md)

一个 Neovim 插件，在垂直分割窗口中打开运行 [Crush CLI](https://github.com/charmbracelet/crush) 的终端。

![Preview](./resources/Preview.gif)

## 1. 安装

使用 [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'gitsang/crush.nvim',
  opts = {
    width = 80, -- 垂直分割窗口的宽度
    fixed_width = true, -- 是否固定宽度（true = 锁定，false = 可调整）
    crush_cmd = "crush --yolo", -- 终端中运行的命令
    copy_to_clipboard = false, -- 复制到系统剪贴板
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

## 2. 使用方法

安装完成后，你可以运行以下命令：

### 2.1 Crush 命令

运行 `:Crush` 命令在垂直分割窗口中打开运行 crush 命令的终端。

### 2.2 CrushFilePos 命令

`:CrushFilePos` 命令在 Visual 模式下将相对文件路径和行/列信息复制到剪贴板，然后发送给 crush。

### 2.3 CrushActions 命令

`:CrushActions` 命令允许你定义可以从弹出选择器中执行的自定义操作。

你可以在 [自定义 Actions 教程](docs/actions.zh-CN.md) 中找到如何定义自己的操作
