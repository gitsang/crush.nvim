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

	-- Create CrushFile command
	vim.api.nvim_create_user_command("CrushFile", function(opts)
		local buf = vim.api.nvim_get_current_buf()
		local file_path = vim.api.nvim_buf_get_name(buf)

		-- Get relative path from current working directory
		local relative_path = vim.fn.fnamemodify(file_path, ":.")

		local result = ""

		-- Check if we have a range (from visual selection)
		if opts.range == 2 then
			-- We have a range, get the visual mode that created it
			local visual_mode = vim.fn.visualmode()
			local start_line = opts.line1
			local end_line = opts.line2
			local start_col = vim.fn.col("'<")
			local end_col = vim.fn.col("'>")

			if visual_mode == "V" then
				-- VISUAL LINE mode
				if start_line == end_line then
					result = string.format("%s:L%d", relative_path, start_line)
				else
					result = string.format("%s:L%d-L%d", relative_path, start_line, end_line)
				end
			elseif visual_mode == "v" then
				-- VISUAL mode (character-wise)
				if start_line == end_line then
					-- Single line in VISUAL mode
					result = string.format("%s:L%d:C%d-C%d", relative_path, start_line, start_col, end_col)
				else
					-- Multiple lines in VISUAL mode
					result =
						string.format("%s:L%d-L%d:C%d-C%d", relative_path, start_line, end_line, start_col, end_col)
				end
			elseif visual_mode == "\22" then
				-- BLOCK mode
				if start_line == end_line and start_col == end_col then
					-- Single character in BLOCK mode
					result = string.format("%s:L%dC%d", relative_path, start_line, start_col)
				else
					-- Multiple characters in BLOCK mode
					result = string.format("%s:L%dC%d-L%dC%d", relative_path, start_line, start_col, end_line, end_col)
				end
			end
		else
			-- Not in visual mode, just copy current file and line
			local current_line = vim.fn.line(".")
			result = string.format("%s:L%d", relative_path, current_line)
		end

		-- Copy to system clipboard
		vim.fn.setreg("+", result)
		vim.fn.setreg('"', result)

		-- Show notification
		vim.notify("Copied: " .. result, vim.log.levels.INFO)
	end, { range = true })

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
