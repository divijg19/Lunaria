local explore = require("render.explore")
local combat = require("render.combat")

local M = {}

function M.draw(state)
	if state.state:is("explore") then
		explore.draw(state)

	elseif state.state:is("combat") then
		combat.draw(state)
	end
end

return M
