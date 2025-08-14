local M = {}

---@class CrushOptions
---@field width? integer
---@field crush_cmd? string

---Setup function for crush.nvim
---@param opts? CrushOptions
function M.setup(opts)
  opts = opts or {}
  local width = opts.width or 80
  local crush_cmd = opts.crush_cmd or "crush"

  vim.api.nvim_create_user_command("Crush", function()
    -- Create a vertical split with specified width
    vim.cmd("vsplit")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(win, width)

    -- Open terminal and run crush command
    vim.cmd("terminal " .. crush_cmd)
  end, {})
end

return M