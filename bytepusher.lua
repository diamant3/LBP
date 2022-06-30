local bit = require("bit") or require("bit32")

-- Bytepusher object definition
local Bytepusher = {}
Bytepusher.__index = Bytepusher

-- Create a new Bytepusher object
function Bytepusher.new()
    return setmetatable({
        mem = {},
        pc = 0x0
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
        self.mem[byte] = 0x0
    end

    -- load each byte from rom to memory
    for byte = 1, #buffer do
        self.mem[byte - 1] = buffer[byte]
    end

    file:close()
end

-- main instruction cycle
function Bytepusher:cycle()
    self.pc = bit.bor(bit.lshift(self.mem[2], 16), bit.lshift(self.mem[3], 8), self.mem[4])
    -- print(string.format("PC: 0x%x", self.pc))

    for _ = 1, 0x10000 do
        local A = bit.bor(bit.lshift(self.mem[self.pc + 0], 16), bit.lshift(self.mem[self.pc + 1], 8), self.mem[self.pc + 2])
        local B = bit.bor(bit.lshift(self.mem[self.pc + 3], 16), bit.lshift(self.mem[self.pc + 4], 8), self.mem[self.pc + 5])
        local C = bit.bor(bit.lshift(self.mem[self.pc + 6], 16), bit.lshift(self.mem[self.pc + 7], 8), self.mem[self.pc + 8])

        self.mem[B] = self.mem[A]
        self.pc = C
    end
end

setmetatable(Bytepusher, {__call = Bytepusher.new})
return Bytepusher