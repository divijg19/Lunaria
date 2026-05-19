local M = {}

local TILE_WIDTH = 64
local TILE_HEIGHT = 32

local ORIGIN_X = 400
local ORIGIN_Y = 120

-- ========================================
-- Helpers
-- ========================================

local function iso_to_screen(x, y)
	local sx = (x - y) * (TILE_WIDTH / 2)
	local sy = (x + y) * (TILE_HEIGHT / 2)

	return sx + ORIGIN_X, sy + ORIGIN_Y
end

local function draw_floor(x, y)
	local sx, sy = iso_to_screen(x, y)

	love.graphics.polygon(
		"line",
		sx, sy,
		sx + TILE_WIDTH / 2, sy + TILE_HEIGHT / 2,
		sx, sy + TILE_HEIGHT,
		sx - TILE_WIDTH / 2, sy + TILE_HEIGHT / 2
	)
end

local function draw_wall(x, y)
	local sx, sy = iso_to_screen(x, y)

	love.graphics.polygon(
		"fill",
		sx, sy,
		sx + TILE_WIDTH / 2, sy + TILE_HEIGHT / 2,
		sx, sy + TILE_HEIGHT,
		sx - TILE_WIDTH / 2, sy + TILE_HEIGHT / 2
	)
end

-- ========================================
-- Main Draw
-- ========================================

function M.draw(state)
	local queue = {}

	-- map tiles
	for y, row in ipairs(state.map) do
		for x, tile in ipairs(row) do
			table.insert(queue, {
				type = tile == "#" and "wall" or "floor",
				x = x,
				y = y,
				depth = x + y
			})
		end
	end

	-- enemies
	for _, e in ipairs(state.enemies or {}) do
		table.insert(queue, {
			type = "enemy",
			x = e.x,
			y = e.y,
			depth = e.x + e.y + 0.5
		})
	end

	-- player
	table.insert(queue, {
		type = "player",
		x = state.player.x,
		y = state.player.y,
		depth = state.player.x + state.player.y + 0.5
	})

	-- depth sort
	table.sort(queue, function(a, b)
		return a.depth < b.depth
	end)

	-- render sorted
	for _, item in ipairs(queue) do
		if item.type == "floor" then
			draw_floor(item.x, item.y)

		elseif item.type == "wall" then
			draw_wall(item.x, item.y)

		elseif item.type == "enemy" then
			local sx, sy = iso_to_screen(item.x, item.y)

			love.graphics.print(
				"E",
				sx - 4,
				sy
			)

		elseif item.type == "player" then
			local sx, sy = iso_to_screen(item.x, item.y)

			love.graphics.print(
				"@",
				sx - 4,
				sy
			)
		end
	end

	-- UI
	love.graphics.print(
		"HP: " .. state.player.hp ..
		" | Enemies: " .. #(state.enemies or {}),
		10,
		10
	)

	love.graphics.print(
		state.log or "",
		10,
		30
	)

	if state.is_game_over then
		love.graphics.print(
			"YOU DIED IN THE VEIL",
			10,
			60
		)
	end
end

return M
