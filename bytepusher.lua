local bit = require("bit") or require("bit32")

-- Bytepusher object definition
local Bytepusher = {}
Bytepusher.__index = Bytepusher

-- Create a new Bytepusher object
function Bytepusher.new()
    return setmetatable({
        mem = {},
        pc = 0x00
    }, Bytepusher)
end

-- Load a rom file to memory (.bytepusher/.bp file ext)
function Bytepusher:load(file)
    -- the rom buffer
    local buffer = {}

    -- load each byte fom rom into buffer
    while (not file:isEOF()) do
        buffer[#buffer + 1] = file:read(1):byte()

        -- check rom buffer status
        if (not buffer[#buffer]) then
            print("reading ROM failed: ("..(buffer[#buffer] or "nil")..")")
            return
        end
    end

    -- init memory
    for byte = 0, (0x1000008 - 1) do
        self.mem[byte] = 0x0000
    end

    -- load each byte from rom to memory
    for byte = 1, #buffer do
        self.mem[byte - 1] = buffer[byte]
    end

    file:close()
end

-- main instruction cycle
function Bytepusher:cycle()
    local pc = self.pc
    local mem = self.mem

    pc = bit.bor(bit.lshift(mem[2], 16), bit.lshift(mem[3], 8), mem[4])
    print(string.format("PC: 0x%x", pc))

    for _ = 0, (0xffff - 1) do
        local A = bit.bor(bit.lshift(mem[pc + 0], 16), bit.lshift(mem[pc + 1], 8), mem[pc + 2])
        local B = bit.bor(bit.lshift(mem[pc + 3], 16), bit.lshift(mem[pc + 4], 8), mem[pc + 5])
        local C = bit.bor(bit.lshift(mem[pc + 6], 16), bit.lshift(mem[pc + 7], 8), mem[pc + 8])

        mem[B] = mem[A]
        pc = mem[C]
    end
end

setmetatable(Bytepusher, {__call = Bytepusher.new})
return Bytepusher