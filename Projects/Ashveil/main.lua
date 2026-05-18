package.path = "./?.lua;./?/init.lua;" .. package.path

local Game = require("core.game")

local love_input = require("input.love")
local explore_input = require("input.explore")
local combat_input = require("input.combat")

local renderer = require("render.love")

local game = Game:new()

function love.update(dt)
	local key = love_input.get_key()
	if not key then return end

	local action = nil

	if game.state:is("explore") then
		action = explore_input.get_action(key)

	elseif game.state:is("combat") then
		action = combat_input.get_action(key)
	end

	if action then
		game:update(action)
	end
end

function love.draw()
	renderer.draw(game:get_draw_data())
end
