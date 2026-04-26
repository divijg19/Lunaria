local M = {}

function M.create(width, height)
	local map = {}

	for y = 1, height do
		map[y] = {}
		for x = 1, width do
			if x == 1 or y == 1 or x == width or y == width or y == height then
				map[y][x] = "#"
			else
				map[y][x] = "."
			end
		end
	end

	return map
end

return M
