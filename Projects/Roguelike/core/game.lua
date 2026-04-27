local Map = require("core.map")

local Game = {}

function Game:new()
    local obj = {
        map = Map.create(20, 10),
        player = { x = 2, y = 2, hp = 10 }
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Game:update(action)
    if action == "up" then
        self.player.y = self.player.y - 1
    elseif action == "down" then
        self.player.y = self.player.y + 1
    elseif action == "left" then
        self.player.x = self.player.x - 1
    elseif action == "right" then
        self.player.x = self.player.x + 1
    end
end

function Game:get_draw_data()
    return {
        map = self.map,
        player = self.player
    }
end

return Game
