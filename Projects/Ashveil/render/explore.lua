local M = {}

local TILE_WIDTH = 64
local TILE_HEIGHT = 32

local function get_screen_center()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	-- slightly below center feels better
	return w / 2, h / 3
end

-- ========================================
-- Helpers
-- ========================================

local function iso_to_screen(x, y)
	local sx = (x - y) * (TILE_WIDTH / 2)
	local sy = (x + y) * (TILE_HEIGHT / 2)

	return sx, sy
end

local function world_to_camera(state, x, y)
	local sx, sy = iso_to_screen(x, y)

	local cam_sx, cam_sy =
		iso_to_screen(
			state.camera.x,
			state.camera.y
		)

	local cx, cy = get_screen_center()

	return
		sx - cam_sx + cx,
		sy - cam_sy + cy
end

local function draw_floor(state, x, y)
	local sx, sy = world_to_camera(state, x, y)

	love.graphics.polygon(
		"line",
		sx, sy,
		sx + TILE_WIDTH / 2, sy + TILE_HEIGHT / 2,
		sx, sy + TILE_HEIGHT,
		sx - TILE_WIDTH / 2, sy + TILE_HEIGHT / 2
	)
end

local function draw_wall(state, x, y)
	local sx, sy = world_to_camera(state, x, y)

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
	-- update camera
	state.camera:center_on(
		state.player.x,
		state.player.y
	)

	local queue = {}

	-- map
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

	-- props
	for _, p in ipairs(state.props or {}) do
		table.insert(queue, {
			type = "prop",

			x = p.x,
			y = p.y,

			prop = p,

			depth = p.x + p.y + 0.25
		})
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

	-- render
	for _, item in ipairs(queue) do
		if item.type == "floor" then
			draw_floor(state, item.x, item.y)

		elseif item.type == "wall" then
			draw_wall(state, item.x, item.y)

		elseif item.type == "prop" then
			local sx, sy =
				world_to_camera(
					state,
					item.x,
					item.y
				)

			if item.prop.type == "pillar" then
				love.graphics.rectangle(
					"fill",

					sx - 6,
					sy - 18,

					12,
					24
				)
			end

		elseif item.type == "enemy" then
			local sx, sy =
				world_to_camera(
					state,
					item.x,
					item.y
				)

			love.graphics.print(
				"E",
				sx - 4,
				sy
			)

		elseif item.type == "player" then
			local sx, sy =
				world_to_camera(
					state,
					item.x,
					item.y
				)

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
