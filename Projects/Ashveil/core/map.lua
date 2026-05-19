local M = {}

local WALL = "#"
local FLOOR = "."

local function carve_room(map, x, y, w, h)
	for ry = y, y + h - 1 do
		for rx = x, x + w - 1 do
			map[ry][rx] = FLOOR
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

function M.create(width, height)
	local map = {}

	-- fill with walls
	for y = 1, height do
		map[y] = {}

		for x = 1, width do
			map[y][x] = WALL
		end
	end

	local rooms = {}

	local ROOM_COUNT = 6
	local ROOM_MIN = 4
	local ROOM_MAX = 8

	for _ = 1, ROOM_COUNT do
		local rw = love.math.random(ROOM_MIN, ROOM_MAX)
		local rh = love.math.random(ROOM_MIN, ROOM_MAX)

		local rx =
			love.math.random(
				2,
				width - rw - 1
			)

		local ry =
			love.math.random(
				2,
				height - rh - 1
			)

		carve_room(map, rx, ry, rw, rh)

		local center_x = math.floor(rx + rw / 2)
		local center_y = math.floor(ry + rh / 2)

		table.insert(rooms, {
			x = center_x,
			y = center_y
		})

		-- connect to previous room
		if #rooms > 1 then
			local prev = rooms[#rooms - 1]

			carve_h_tunnel(
				map,
				prev.x,
				center_x,
				prev.y
			)

			carve_v_tunnel(
				map,
				prev.y,
				center_y,
				center_x
			)
		end
	end

	return map, rooms
end

return M
