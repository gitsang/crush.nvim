# Custom Actions Tutorial

[中文](./actions.zh-CN.md)

This tutorial teaches you how to configure custom actions for `crush.nvim`.

## 1. CrushAction Basic Structure

Each action contain the following fields:

```lua
{
    name = "Action name",
    description = "Optional description",
    prompts = "String or function"
}
```

### 1.1 Field Descriptions

- `name` (required): Display name of the action
- `description` (optional): Additional description information
- `prompts` (required): Can be a string or function
  - String: Text directly sent to crush terminal
  - Function: Returns the string to send, supports dynamic content generation

## 2. Example 1: Simple String Prompts

The simplest action uses a static string:

```lua
require("crush").setup({
    actions = {
        {
            name = "Explain this code",
            description = "Ask AI to explain selected code",
            prompts = "Please explain this code in detail."
        },
        {
            name = "Refactor this code",
            prompts = "Please refactor this code to improve readability and performance."
        }
    }
})
```

## 3. Example 2: Function Prompts (Reference analyze_and_fix_diagnostics)

When you need to dynamically generate content, use a function as `prompts`. Here's an example from `lua/crush/actions/analyze_and_fix_diagnostics.lua`:

```lua
{
    name = "Analyze and fix diagnostics",
    description = "Show and analyze diagnostics in the selected range",
    prompts = function()
        local current_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
        local start_line = vim.fn.line("'<")
        local end_line = vim.fn.line("'>")

        -- If not in visual mode, use current line
        if vim.fn.visualmode() == "" then
            start_line = vim.fn.line(".")
            end_line = start_line
        end

        -- Get diagnostic information
        local diagnostics = vim.diagnostic.get(0)
        local result = string.format("%s:L%d-L%d\n\n", current_file, start_line, end_line)

        for _, diag in ipairs(diagnostics) do
            if diag.lnum >= start_line - 1 and diag.lnum <= end_line - 1 then
                result = result .. string.format("L%d: [%s] %s\n",
                    diag.lnum + 1,
                    diag.source or "unknown",
                    diag.message
                )
            end
        end

        return result
    end,
}
```

## 4. Using Actions

After configuring actions:

1. Use `:CrushActions` command to open the selector
2. Select the desired action
3. The action's prompts will be automatically sent to the crush terminal

## 5. Default Actions

The plugin provides default actions (see `lua/crush/actions/default.lua`). Custom actions will be displayed together with default actions.

## 6. Notes

1. The `prompts` function should return a string
2. The function is called immediately when the action is selected
3. If accessing visual mode related information (like `'<`, `'>`), ensure the command is called from visual mode
4. Keep prompts concise and effective, avoid generating overly long text
5. You can use `vim.notify()` in the function to display debug information
