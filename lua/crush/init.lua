local M = {}

---@class CrushOptions
---@field width? integer
---@field crush_cmd? string
---@field fixed_width? boolean

---Setup function for crush.nvim
---@param opts? CrushOptions
function M.setup(opts)
	opts = opts or {}
	local width = opts.width or 80
	local crush_cmd = opts.crush_cmd or "crush"
	local fixed_width = opts.fixed_width or false

	-- Create Crush command
	vim.api.nvim_create_user_command("Crush", function()
		-- Create a vertical split
		vim.cmd("vsplit")
		local win = vim.api.nvim_get_current_win()

		-- Set window width and optionally fix it
		vim.api.nvim_win_set_width(win, width)
		if fixed_width then
			vim.api.nvim_set_option_value("winfixwidth", true, { win = win })
		end

		-- Open terminal and run crush command
		vim.cmd("terminal " .. crush_cmd)

		-- Set buffer options to hide from buffer tab
		local buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_set_option_value("buflisted", false, { buf = buf })

		-- Set up terminal key mappings for window navigation
		local term_opts = { buffer = buf, silent = true }
		vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", term_opts)
		vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", term_opts)
		vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", term_opts)
		vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", term_opts)

		-- Set up autocmd to enter terminal mode when entering crush terminal window
		vim.api.nvim_create_autocmd("WinEnter", {
			buffer = buf,
			callback = function()
				if vim.api.nvim_get_current_win() == win then
					vim.cmd("startinsert")
				end
			end,
		})

		-- Enter terminal mode immediately
		vim.cmd("startinsert")
	end, {})

	-- Add autocommand to maintain width on window resize (only if fixed_width is enabled)
	if fixed_width then
		vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
			callback = function()
				-- Get all windows
				local wins = vim.api.nvim_list_wins()

				-- If WinResized event, only check the resized windows
				if vim.v.event and vim.v.event.windows then
					wins = vim.v.event.windows or {}
				end

				for _, winid in ipairs(wins) do
					if vim.api.nvim_win_is_valid(winid) then
						local buf = vim.api.nvim_win_get_buf(winid)
						if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
							-- Check if this is a crush terminal (not listed in buffer list)
							if not vim.api.nvim_get_option_value("buflisted", { buf = buf }) then
								vim.api.nvim_win_set_width(winid, width)
							end
						end
					end
				end
			end,
		})
	end
end

return M
