local bit = require("bit")
local BP = require("bytepusher")

-- bytepusher metatable handler
local core = {}

-- constants
local INTENSITY = 0x33
local OPAQUE = 0xFF

function love.load(arg)
    local file = love.filesystem.newFile(arg[1])
    local status, result = file:open("r")

    if (status) then
        -- start bytepusher interpreter
        core = BP:new()
        core.load(file)
    else
        print("Result: " .. result)
        file:close()
    end
end

function love.update(dt)
    core:cycle()
end

function love.draw()
    local r, g, b = 0, 0, 0
    local zz = bit.lshift(core.mem[5], 16)

    -- set bg to black
    love.graphics.clear(0, 0, 0, OPAQUE)

    for yy = 0, 255 do
        for xx = 0, 255 do
            local _yy = bit.lshift(yy, 8)
            local c = core.mem[bit.bor(zz, _yy, xx)]

            -- Multi pixel color (web safe palette)
            if (c <= 216) then
                b = (c % 6) * INTENSITY
                c = c / 6
                g = (c % 6) * INTENSITY
                c = c / 6
                r = (c % 6) * INTENSITY

                r = r / OPAQUE
                g = g / OPAQUE
                b = b / OPAQUE

                love.graphics.setColor(r, g, b, OPAQUE)
            elseif (c >= 217 and c <= 255) then
                -- black pixel color
                love.graphics.setColor(0, 0, 0, OPAQUE)
            else
                -- White pixel color
                love.graphics.setColor(OPAQUE, OPAQUE, OPAQUE, OPAQUE)
            end

            -- draw pixel
            love.graphics.rectangle("fill", xx, yy, 1, 1)
        end
    end
end

function love.keypressed(key)
    poll(key)
end

function love.keyreleased(key)
    poll(key)
end

function poll(key)
    local key_data = bit.bor(bit.lshift(core.mem[0], 8), core.mem[1])

    if (core.keyboard[key]) then
        key_data = bit.bxor(key_data , bit.lshift(1, core.keyboard[key]))
    end

    core.mem[0] = bit.rshift(key_data, 8)
    core.mem[1] = bit.band(key_data, 0xFF)
end