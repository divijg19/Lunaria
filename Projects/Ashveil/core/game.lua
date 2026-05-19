local Map = require("core.map")
local State = require("core.state")
local Camera = require("core.camera")

local movement = require("systems.movement")
local combat_system = require("systems.combat")
local ai = require("systems.ai")

local Game = {}

function Game:new()
	local map, rooms = Map.create(40, 40)

	local spawn = rooms[1].center

	local obj = {
		map = map,
		rooms = rooms,

		player = {
			x = spawn.x,
			y = spawn.y,
			hp = 10,
		},

		enemies = {},

		props = {},

		state = State:new("explore"),

		camera = Camera:new(),

		combat = nil,

		transition = nil,

		log = "Welcome to Ashveil.",

		is_game_over = false,
	}

	-- place enemies in random rooms
	for i = 2, #rooms do
		local room = rooms[i]

		table.insert(obj.enemies, {
			x = room.center.x,
			y = room.center.y,
			hp = 3,
		})
	end

	-- ========================================
	-- Environmental Prop Placement
	-- ========================================

	for i = 2, #rooms do
		local room = rooms[i]

		local prop_count = 0

		-- archetype density rules
		if room.type == "quiet" then
			prop_count = 0

		elseif room.type == "hall" then
			prop_count = 0

		elseif room.type == "shrine" then
			prop_count = 4

		elseif room.type == "crypt" then
			prop_count =
				love.math.random(6, 10)

		elseif room.type == "ruin" then
			prop_count =
				love.math.random(3, 7)

		elseif room.type == "arena" then
			prop_count =
				love.math.random(0, 1)
		end

		-- ====================================
		-- Shrine Layout
		-- ====================================

		if room.type == "shrine" then
			local cx = room.center.x
			local cy = room.center.y

			local positions = {
				{cx - 2, cy - 2},
				{cx + 2, cy - 2},
				{cx - 2, cy + 2},
				{cx + 2, cy + 2},
			}

			for _, pos in ipairs(positions) do
				table.insert(obj.props, {
					x = pos[1],
					y = pos[2],

					type = "pillar",
				})
			end

		-- ====================================
		-- Arena Layout
		-- ====================================

		elseif room.type == "arena" then
			for _ = 1, prop_count do
				local edge = love.math.random(4)

				local px, py

				if edge == 1 then
					px =
						love.math.random(
							room.x,
							room.x + room.w - 1
						)

					py = room.y

				elseif edge == 2 then
					px =
						love.math.random(
							room.x,
							room.x + room.w - 1
						)

					py = room.y + room.h - 1

				elseif edge == 3 then
					px = room.x

					py =
						love.math.random(
							room.y,
							room.y + room.h - 1
						)

				else
					px = room.x + room.w - 1

					py =
						love.math.random(
							room.y,
							room.y + room.h - 1
						)
				end

				table.insert(obj.props, {
					x = px,
					y = py,

					type = "pillar",
				})
			end

		-- ====================================
		-- Generic Layouts
		-- ====================================

		else
			for _ = 1, prop_count do
				local px
				local py

				-- fragmented ruin placement
				if room.type == "ruin" then
					if love.math.random() < 0.5 then
						px =
							love.math.random(
								room.x,
								room.x + math.floor(room.w / 2)
							)
					else
						px =
							love.math.random(
								room.x + math.floor(room.w / 2),
								room.x + room.w - 1
							)
					end

					if love.math.random() < 0.5 then
						py =
							love.math.random(
								room.y,
								room.y + math.floor(room.h / 2)
							)
					else
						py =
							love.math.random(
								room.y + math.floor(room.h / 2),
								room.y + room.h - 1
							)
					end

				else
					px =
						love.math.random(
							room.x + 1,
							room.x + room.w - 2
						)

					py =
						love.math.random(
							room.y + 1,
							room.y + room.h - 2
						)
				end

				table.insert(obj.props, {
					x = px,
					y = py,

					type = "pillar",
				})
			end
		end
	end

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
	elseif self.state:is("transition") then
		self:update_transition()
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
	self.state:set("transition")

	self.transition = {
		timer = 0,
		duration = 0.6,

		alpha = 0,

		enemy = enemy,
	}

	self.log = "A Veil stirs..."
end

function Game:update_transition()
	local t = self.transition

	if not t then
		return
	end

	t.timer = t.timer + (1 / 60)

	t.alpha = math.min(t.timer / t.duration, 1)

	if t.timer >= t.duration then
		self.transition = nil

		self.state:set("combat")

		self.combat = {
			enemy = t.enemy,

			player_hp = self.player.hp,
			enemy_hp = t.enemy.hp,
		}

		self.log = "The battle begins."
	end
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
		rooms = self.rooms,

		player = self.player,
		enemies = self.enemies,
		props = self.props,

		camera = self.camera,

		combat = self.combat,

		transition = self.transition,

		log = self.log,

		state = self.state,

		is_game_over = self.is_game_over,
	}
end

return Game
