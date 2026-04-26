local Game = require("core.game")
local renderer = require("render.terminal")

local game = Game:new()

while true do
	renderer.draw(game:get_draw_data())

	-- pause so it doesn't spam
	os.execute("sleep 0.2")
end
