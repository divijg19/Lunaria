local M = {}

function M.player(game, action)
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

	local nx = game.player.x + dx
	local ny = game.player.y + dy

	-- wall check
	if not (game.map[ny] and game.map[ny][nx] ~= "#") then
		return
	end

	return nx, ny
end

function M.enemy(game, e)
	local dirs = {
		{ 0, -1 },
		{ 0, 1 },
		{ -1, 0 },
		{ 1, 0 },
	}

	local d = dirs[math.random(#dirs)]
	local nx = e.x + d[1]
	local ny = e.y + d[2]

	if not (game.map[ny] and game.map[ny][nx] ~= "#") then
		return
	end

	return nx, ny
end

return M
