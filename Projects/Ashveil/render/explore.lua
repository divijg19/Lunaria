local M = {}

local TILE_SIZE = 32

function M.draw(state)
	for y, row in ipairs(state.map) do
		for x, tile in ipairs(row) do
			local px = (x - 1) * TILE_SIZE
			local py = (y - 1) * TILE_SIZE

			-- walls
			if tile == "#" then
				love.graphics.rectangle(
					"fill",
					px,
					py,
					TILE_SIZE,
					TILE_SIZE
				)
			end

			-- enemies
			for _, e in ipairs(state.enemies or {}) do
				if e.x == x and e.y == y then
					love.graphics.print(
						"E",
						px + 10,
						py + 5
					)
				end
			end

			-- player
			if state.player.x == x and state.player.y == y then
				love.graphics.print(
					"@",
					px + 10,
					py + 5
				)
			end
		end
	end

	-- UI
	love.graphics.print(
		"HP: " .. state.player.hp ..
		" | Enemies: " .. #(state.enemies or {}),
		10,
		340
	)

	love.graphics.print(
		state.log or "",
		10,
		360
	)
end

return M
