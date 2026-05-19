local M = {}

local WALL = "#"
local FLOOR = "."

-- ========================================
-- Room Utilities
-- ========================================

local function intersects(a, b)
	return not (
		a.x + a.w < b.x or
		b.x + b.w < a.x or
		a.y + a.h < b.y or
		b.y + b.h < a.y
	)
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
	return
		math.floor(room.x + room.w / 2),
		math.floor(room.y + room.h / 2)
end

-- ========================================
-- Generation
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

	local ROOM_COUNT = 10
	local ROOM_MIN = 5
	local ROOM_MAX = 9

	for _ = 1, ROOM_COUNT do
		local room = {
			w = love.math.random(ROOM_MIN, ROOM_MAX),
			h = love.math.random(ROOM_MIN, ROOM_MAX),
		}

		room.x =
			love.math.random(
				2,
				width - room.w - 1
			)

		room.y =
			love.math.random(
				2,
				height - room.h - 1
			)

		-- reject overlapping rooms
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

			table.insert(rooms, {
				x = cx,
				y = cy,
				w = room.w,
				h = room.h,
			})

			-- connect to previous room
			if #rooms > 1 then
				local prev = rooms[#rooms - 1]

				carve_h_tunnel(
					map,
					prev.x,
					cx,
					prev.y
				)

				carve_v_tunnel(
					map,
					prev.y,
					cy,
					cx
				)
			end
		end
	end

	return map, rooms
end

return M
