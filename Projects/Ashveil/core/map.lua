local Archetypes = require("world.archetypes")

local M = {}

local WALL = "#"
local FLOOR = "."

-- ========================================
-- Room Utilities
-- ========================================

local function intersects(a, b)
	return not (a.x + a.w < b.x or b.x + b.w < a.x or a.y + a.h < b.y or b.y + b.h < a.y)
end

local function carve_room(map, room)
	for y = room.y, room.y + room.h - 1 do
		for x = room.x, room.x + room.w - 1 do
			map[y][x] = FLOOR
		end
	end
end

local function carve_h_tunnel(map, x1, x2, y)
	local minx = math.min(x1, x2)
	local maxx = math.max(x1, x2)

	for x = minx, maxx do
		map[y][x] = FLOOR
	end
end

local function carve_v_tunnel(map, y1, y2, x)
	local miny = math.min(y1, y2)
	local maxy = math.max(y1, y2)

	for y = miny, maxy do
		map[y][x] = FLOOR
	end
end

local function center(room)
	return math.floor(room.x + room.w / 2), math.floor(room.y + room.h / 2)
end

-- ========================================
-- Archetype Selection
-- ========================================

local ROOM_TYPES = {
	-- silence dominates
	"quiet",
	"quiet",
	"quiet",
	"quiet",
	"quiet",
	"quiet",

	-- connective tissue
	"hall",
	"hall",
	"hall",

	-- uncommon
	"ruin",
	"ruin",

	-- rare
	"crypt",

	-- very rare
	"shrine",

	-- very rare
	"arena",
}

local ROOM_TRANSITIONS = {
	quiet = {
		"quiet",
		"quiet",
		"hall",
		"ruin",
	},

	hall = {
		"quiet",
		"quiet",
		"crypt",
		"arena",
		"shrine",
	},

	ruin = {
		"quiet",
		"hall",
		"crypt",
	},

	crypt = {
		"hall",
		"quiet",
	},

	shrine = {
		"hall",
		"quiet",
	},

	arena = {
		"hall",
		"quiet",
	},
}

local function random_room_type(previous_type)
	if not previous_type then
		return ROOM_TYPES[
			love.math.random(#ROOM_TYPES)
		]
	end

	local choices =
		ROOM_TRANSITIONS[previous_type]

	if not choices then
		return ROOM_TYPES[
			love.math.random(#ROOM_TYPES)
		]
	end

	return choices[
		love.math.random(#choices)
	]
end

-- ========================================
-- Geometry Rules
-- ========================================

local function generate_room_dimensions(room_type)
	-- ====================================
	-- Hall
	-- ====================================

	if room_type == "hall" then
		if love.math.random() < 0.5 then
			return
				love.math.random(14, 20),
				love.math.random(4, 5)
		else
			return
				love.math.random(4, 5),
				love.math.random(14, 20)
		end

	-- ====================================
	-- Arena
	-- ====================================

	elseif room_type == "arena" then
		return
			love.math.random(12, 16),
			love.math.random(12, 16)

	-- ====================================
	-- Crypt
	-- ====================================

	elseif room_type == "crypt" then
		return
			love.math.random(5, 7),
			love.math.random(5, 7)

	-- ====================================
	-- Shrine
	-- ====================================

	elseif room_type == "shrine" then
		return
			love.math.random(9, 11),
			love.math.random(9, 11)

	-- ====================================
	-- Ruin
	-- ====================================

	elseif room_type == "ruin" then
		return
			love.math.random(7, 14),
			love.math.random(7, 14)
	end

	-- ====================================
	-- Quiet
	-- ====================================

	return
		love.math.random(6, 10),
		love.math.random(6, 10)
end

-- ========================================
-- Dungeon Generation
-- ========================================

function M.create(width, height)
	local map = {}

	-- fill walls
	for y = 1, height do
		map[y] = {}

		for x = 1, width do
			map[y][x] = WALL
		end
	end

	local rooms = {}
	local previous_type = nil

	local ROOM_COUNT = 14

	for _ = 1, ROOM_COUNT do
		local room_type = random_room_type(previous_type)

		local rw, rh = generate_room_dimensions(room_type)

		local room = {
			type = room_type,

			w = rw,
			h = rh,
		}

		room.x = love.math.random(2, width - room.w - 1)

		room.y = love.math.random(2, height - room.h - 1)

		-- overlap rejection
		local failed = false

		for _, other in ipairs(rooms) do
			if intersects(room, other) then
				failed = true
				break
			end
		end

		if not failed then
			carve_room(map, room)

			local cx, cy = center(room)

			room.center = {
				x = cx,
				y = cy,
			}

			room.props = {}

			room.archetype = Archetypes[room_type]

			table.insert(rooms, room)
			previous_type = room_type

			-- connect to previous room
			if #rooms > 1 then
				local prev = rooms[#rooms - 1]

				carve_h_tunnel(map, prev.center.x, cx, prev.center.y)

				carve_v_tunnel(map, prev.center.y, cy, cx)
			end
		end
	end

	return map, rooms
end

return M
