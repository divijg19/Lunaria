-- ensure Lua can resolve modules from project root
package.path = "./?.lua;./?/init.lua;" .. package.path

local Game = require("core.game")
local renderer = require("render.terminal")
local input = require("input.terminal")

local game = Game:new()

while true do
    renderer.draw(game:get_draw_data())

    local action = input.get_action()
    if action then
        game:update(action)
    end
end
