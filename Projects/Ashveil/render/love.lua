local explore = require("render.explore")
local combat = require("render.combat")
local transition = require("render.transition")

local M = {}

function M.draw(state)
	if state.state:is("explore") then
		explore.draw(state)

	elseif state.state:is("combat") then
		combat.draw(state)

	elseif state.state:is("transition") then
		explore.draw(state)
		transition.draw(state)
	end
end

return M
