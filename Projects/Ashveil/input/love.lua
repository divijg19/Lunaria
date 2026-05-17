local M = {}

local last_key = nil

function love.keypressed(key)
	last_key = key
end

function M.get_action()
	local map = {
		w = "up",
		s = "down",
		a = "left",
		d = "right",
	}

	local action = map[last_key]
	last_key = nil
	return action
end

return M
