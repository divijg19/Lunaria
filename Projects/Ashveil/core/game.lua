local Map = require("core.map")
local State = require("core.state")

local movement = require("systems.movement")
local combat_system = require("systems.combat")
local ai = require("systems.ai")

local Game = {}

function Game:new()
	local obj = {
		map = Map.create(20, 10),

		player = {
			x = 2,
			y = 2,
			hp = 10,
		},

		enemies = {
			{ x = 5, y = 5, hp = 3 },
			{ x = 10, y = 6, hp = 3 },
		},

		state = State:new("explore"),

		combat = nil,

		log = "Welcome to Ashveil.",

		is_game_over = false,
	}

	setmetatable(obj, self)
	self.__index = self

	return obj
end

function Game:update(action)
	if self.is_game_over then
		return
	end

	self.log = ""

	if self.state:is("explore") then
		self:update_explore(action)

	elseif self.state:is("combat") then
		self:update_combat(action)
	end

	if self.player.hp <= 0 then
		self.is_game_over = true
		self.log = "You died in the Veil."
	end
end

-- =========================
-- EXPLORE
-- =========================

function Game:update_explore(action)
	self:player_turn(action)
	self:world_turn()
end

function Game:player_turn(action)
	if not action then
		return
	end

	local nx, ny = movement.player(self, action)

	if not nx then
		return
	end

	local enemy = self:get_enemy_at(nx, ny)

	if enemy then
		self:start_combat(enemy)
		return
	end

	self.player.x = nx
	self.player.y = ny
end

function Game:world_turn()
	for i = #self.enemies, 1, -1 do
		local e = self.enemies[i]

		if e.hp <= 0 then
			table.remove(self.enemies, i)

		else
			local before_hp = self.player.hp

			ai.enemy_turn(self, e)

			if self.player.hp < before_hp then
				self.log = "Enemy hit you."
			end
		end
	end
end

-- =========================
-- COMBAT
-- =========================

function Game:start_combat(enemy)
	self.state:set("combat")

	self.combat = {
		enemy = enemy,

		player_hp = self.player.hp,
		enemy_hp = enemy.hp,
	}

	self.log = "A Veilbeast approaches."
end

function Game:update_combat(action)
	if not action then
		return
	end

	local c = self.combat

	if action == "attack" then
		c.enemy_hp = c.enemy_hp - 1

		self.log = "You strike the Veilbeast."

		if c.enemy_hp <= 0 then
			self:exit_combat(true)
			return
		end

		c.player_hp = c.player_hp - 1

		if c.player_hp <= 0 then
			self.player.hp = 0
			self.is_game_over = true
			self.log = "You were slain."
			return
		end

	elseif action == "guard" then
		self.log = "You brace for impact."

	elseif action == "skill" then
		self.log = "No skills learned yet."

	elseif action == "flee" then
		self:exit_combat(false)
		self.log = "You fled the encounter."
	end
end

function Game:exit_combat(player_won)
	local c = self.combat

	if player_won then
		c.enemy.hp = 0
	end

	self.player.hp = c.player_hp

	self.combat = nil

	self.state:set("explore")
end

-- =========================
-- HELPERS
-- =========================

function Game:get_enemy_at(x, y)
	for _, e in ipairs(self.enemies) do
		if e.x == x and e.y == y then
			return e
		end
	end

	return nil
end

-- =========================
-- DRAW STATE
-- =========================

function Game:get_draw_data()
	return {
		map = self.map,

		player = self.player,
		enemies = self.enemies,

		combat = self.combat,

		log = self.log,

		state = self.state,

		is_game_over = self.is_game_over,
	}
end

return Game
