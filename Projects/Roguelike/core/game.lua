local Map = require("core.map")

local Game = {}

function Game:new()
	local obj = {
		map = Map.create(20, 10),
		player = { x = 2, y = 2, hp = 10 },
	}

	setmetatable(obj, self)
	self.__index = self
	return obj
end

function Game:get_draw_data()
	return {
		map = self.map,
		player = self.player,
	}
end

return Game
