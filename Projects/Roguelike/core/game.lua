local Map = require("core.map")

local Game = {}

function Game:new()
	local obj = {
		map = Map.create(20, 10),
		player = { x = 2, y = 2, hp = 10 },

		enemies = {
			{ x = 5, y = 5, hp = 3 },
			{ x = 10, y = 6, hp = 3 },
		},
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
	if not action then
		return
	end

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

	-- wall check
	if not (self.map[ny] and self.map[ny][nx] ~= "#") then
		return
	end

	-- enemy check (combat)
	local enemy = self:get_enemy_at(nx, ny)
	if enemy then
		enemy.hp = enemy.hp - 1
		return
	end

	-- move
	self.player.x = nx
	self.player.y = ny
end

function Game:world_turn()
	for i, e in ipairs(self.enemies) do
		if e.hp <= 0 then
			table.remove(self.enemies, i)
		else
			self:enemy_act(e)
		end
	end
end

function Game:get_enemy_at(x, y)
	for _, e in ipairs(self.enemies) do
		if e.x == x and e.y == y then
			return e
		end
	end
	return nil
end

function Game:enemy_act(e)
	local dirs = {
		{ 0, -1 },
		{ 0, 1 },
		{ -1, 0 },
		{ 1, 0 },
	}

	local d = dirs[math.random(#dirs)]
	local nx = e.x + d[1]
	local ny = e.y + d[2]

	-- wall check
	if not (self.map[ny] and self.map[ny][nx] ~= "#") then
		return
	end

	-- player collision (combat)
	if nx == self.player.x and ny == self.player.y then
		self.player.hp = self.player.hp - 1
		return
	end

	-- avoid stacking enemies (optional but good)
	if self:get_enemy_at(nx, ny) then
		return
	end

	e.x = nx
	e.y = ny
end

function Game:get_draw_data()
	return {
		map = self.map,
		player = self.player,
		enemies = self.enemies,
	}
end

return Game
