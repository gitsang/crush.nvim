local M = {}

---Get current file path (relative)
---@return string file_path
local function get_current_file()
	local buf = vim.api.nvim_get_current_buf()
	local file_path = vim.api.nvim_buf_get_name(buf)
	return vim.fn.fnamemodify(file_path, ":.")
end

---Get visual position string from current buffer and selection
---@return string position_string
local function get_visual_pos()
	local result = ""

	-- Check if we have a range (from visual selection)
	local visual_mode = vim.fn.visualmode()
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local start_col = vim.fn.col("'<")
	local end_col = vim.fn.col("'>")

	if visual_mode == "V" then
		-- VISUAL LINE mode
		if start_line == end_line then
			result = string.format("L%d", start_line)
		else
			result = string.format("L%d-L%d", start_line, end_line)
		end
	elseif visual_mode == "v" then
		-- VISUAL mode (character-wise)
		if start_line == end_line then
			-- Single line in VISUAL mode
			result = string.format("L%d:C%d-C%d", start_line, start_col, end_col)
		else
			-- Multiple lines in VISUAL mode
			result = string.format("L%d-L%d:C%d-C%d", start_line, end_line, start_col, end_col)
		end
	elseif visual_mode == "\22" then
		-- BLOCK mode
		if start_line == end_line and start_col == end_col then
			-- Single character in BLOCK mode
			result = string.format("L%dC%d", start_line, start_col)
		else
			-- Multiple characters in BLOCK mode
			result = string.format("L%dC%d-L%dC%d", start_line, start_col, end_line, end_col)
		end
	else
		-- Not in visual mode, just copy current line
		local current_line = vim.fn.line(".")
		result = string.format("L%d", current_line)
	end

	return result
end

---Find crush terminal buffer
---@return integer|nil bufnr
local function find_crush_terminal()
	local bufs = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufs) do
		if vim.api.nvim_buf_is_valid(buf) then
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
			local buflisted = vim.api.nvim_get_option_value("buflisted", { buf = buf })
			if buftype == "terminal" and not buflisted then
				return buf
			end
		end
	end
	return nil
end

---Send text to crush terminal
---@param text string text to send
local function send_to_terminal(text)
	local buf = find_crush_terminal()
	if not buf then
		return false
	end

	-- Find the window containing this buffer
	local wins = vim.api.nvim_list_wins()
	for _, win in ipairs(wins) do
		if vim.api.nvim_win_is_valid(win) then
			if vim.api.nvim_win_get_buf(win) == buf then
				-- Focus the terminal window
				vim.api.nvim_set_current_win(win)
				-- Send text to terminal
				vim.api.nvim_chan_send(vim.bo[buf].channel, text)
				return true
			end
		end
	end
	return false
end

---Copy visual position to system clipboard and send to crush terminal
---@param opts? table command options with range information
local function copy_visual_pos(opts)
	local current_file = get_current_file()
	local visual_pos = get_visual_pos()
	local result = current_file .. ":" .. visual_pos

	-- Copy to system clipboard
	vim.fn.setreg("+", result)
	vim.fn.setreg('"', result)

	-- Show notification
	vim.notify("Copied: " .. result, vim.log.levels.INFO)

	-- Return data for terminal sending
	return current_file, visual_pos
end

---Open crush terminal in vertical split
---@param width integer terminal width
---@param crush_cmd string command to run
---@param fixed_width boolean whether to fix window width
local function open_crush_terminal(width, crush_cmd, fixed_width)
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
end

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
	vim.api.nvim_create_user_command("CrushFilePos", function(cmd_opts)
		local current_file, visual_pos = copy_visual_pos(cmd_opts)

		-- Check if crush terminal exists
		if find_crush_terminal() then
			-- Send to existing terminal: @file, enter, :pos
			send_to_terminal("@" .. current_file .. "\r:") -- I don't known why need `:` tailing
			send_to_terminal(":" .. visual_pos .. " ")
		else
			-- Open crush terminal first, then send
			open_crush_terminal(width, crush_cmd, fixed_width)
			-- Wait a bit for terminal to be ready, then send
			vim.defer_fn(function()
				send_to_terminal("@" .. current_file .. "\r:") -- I don't known why need `:` tailing
				send_to_terminal(":" .. visual_pos .. " ")
			end, 3000)
		end
	end, { range = true })

	-- Create Crush command
	vim.api.nvim_create_user_command("Crush", function()
		open_crush_terminal(width, crush_cmd, fixed_width)
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
