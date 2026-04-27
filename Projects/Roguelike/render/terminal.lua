local M = {}

function M.draw(state)
    -- clear screen (ANSI, more reliable than os.execute)
    io.write("\27[2J\27[H")

    for y, row in ipairs(state.map) do
        for x, tile in ipairs(row) do
            if x == state.player.x and y == state.player.y then
                io.write("@")
            else
                io.write(tile)
            end
        end
        print()
    end

    print("HP:", state.player.hp)
end

return M
