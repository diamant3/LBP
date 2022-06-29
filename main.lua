local BP = require("bytepusher")

-- bytepusher object handler
local Core

function love.load(arg)
    local file = love.filesystem.newFile(arg[1])
    local status, result = file:open("r")

    if (status) then
        -- start bytepusher interpreter
        Core = BP()
        Core:load(file)
    else
        print("Result: "..result)
        file:close()
    end
end

function love.update(dt)
    Core:cycle()
end

function love.draw()
    love.graphics.clear(0, 0, 0, 255)
    love.graphics.print("OK!", 20, 30)
end