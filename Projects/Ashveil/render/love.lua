local M = {}

local tile = 32

function M.draw(state)
	for y, row in ipairs(state.map) do
		for x, t in ipairs(row) do
			local px = (x - 1) * tile
			local py = (y - 1) * tile

			-- walls
			if t == "#" then
				love.graphics.rectangle("fill", px, py, tile, tile)
			end

			-- enemies
			for _, e in ipairs(state.enemies or {}) do
				if e.x == x and e.y == y then
					love.graphics.print("E", px + 10, py + 5)
				end
			end

			-- player
			if state.player.x == x and state.player.y == y then
				love.graphics.print("@", px + 10, py + 5)
			end
		end
	end

	-- UI
	love.graphics.print("HP: " .. state.player.hp .. " | Enemies: " .. #(state.enemies or {}), 10, 340)

	love.graphics.print(state.log or "", 10, 360)

	if state.is_game_over then
		love.graphics.print("GAME OVER", 10, 390)
	end
end

return M
