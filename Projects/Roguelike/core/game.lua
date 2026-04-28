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

function Game:update(action)
	self:player_turn(action)
	self:world_turn()
end

function Game:player_turn(action)
	local dx, dy = 0, 0

	if action == "up" then
		dy = -1
	elseif action == "down" then
		dy = 1
	elseif action == "left" then
		dx = -1
	elseif action == "right" then
		dx = 1
	end

	local nx = self.player.x + dx
	local ny = self.player.y + dy

	if self.map[ny] and self.map[ny][nx] ~= "#" then
		self.player.x = nx
		self.player.y = ny
	end
end

function Game:world_turn()
	-- placeholder for enemies, systems, etc.
end

function Game:get_draw_data()
	return {
		map = self.map,
		player = self.player,
	}
end

return Game
