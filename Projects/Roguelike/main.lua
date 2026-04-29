package.path = "./?.lua;./?/init.lua;" .. package.path

local Game = require("core.game")
local input = require("input.love")
local renderer = require("render.love")

local game = Game:new()

function love.update(dt)
	local action = input.get_action()
	game:update(action)
end

function love.draw()
	renderer.draw(game:get_draw_data())
end
