local bit = require("bit") or require("bit32")
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

function love.update()
    Core:cycle()
end

function love.draw()
    local zz = bit.lshift(Core.mem[5], 16)
    local r, g, b
    love.graphics.clear(0, 0, 0, 255)

    for y = 0, 256 - 1 do
        for x = 0, 256 - 1 do
            local px_data = Core.mem[bit.bor(zz, bit.lshift(y, 8), x)]

            b = (px_data % 6) * 0x33
            px_data = px_data / 6

            g = (px_data % 6) * 0x33
            px_data = px_data / 6

            r = (px_data % 6) * 0x33

            love.graphics.setColor(r, g, b, 255)
            love.graphics.rectangle("fill", x, y, 1, 1)
        end
    end
end