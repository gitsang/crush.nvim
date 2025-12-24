local M = {}

---Default actions for Crush
---@return CrushAction[]
function M.get_default_actions()
	return {
		require("crush.actions.analyze_and_fix_diagnostics").get_action(),
	}
end

return M
