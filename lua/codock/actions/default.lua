local M = {}

---Default actions for Codock
---@return CodockAction[]
function M.get_default_actions()
	return {
		require("codock.actions.analyze_and_fix_diagnostics").get_action(),
	}
end

return M
