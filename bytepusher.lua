local bit = require("bit")

-- Bytepusher table
local Bytepusher = {}
local self = {}

-- bytepusher constants
local MEMORY_SIZE = 16777224
local INSTR_PER_FRAME = 65535

-- Create a new Bytepusher metatable
function Bytepusher.new()
    self = {}
    self.mem = {}
    self.pc = 0x0
    self.keyboard = {
        ["1"] = 0x1,
        ["2"] = 0x2,
        ["3"] = 0x3,
        ["4"] = 0xc,
        ["q"] = 0x4,
        ["w"] = 0x5,
        ["e"] = 0x6,
        ["r"] = 0xd,
        ["a"] = 0x7,
        ["s"] = 0x8,
        ["d"] = 0x9,
        ["f"] = 0xe,
        ["z"] = 0xa,
        ["x"] = 0x0,
        ["c"] = 0xb,
        ["v"] = 0xf
    }
    Bytepusher.__index = Bytepusher
    return setmetatable(self, Bytepusher)
end

-- Load a rom file(.bp or .bytepusher file) to memory
function Bytepusher.load(file)
    -- the rom buffer
    local buffer = {}

    -- init memory
    for byte = 1, MEMORY_SIZE, 1 do
        self.mem[byte - 1] = 0
    end

    -- load each byte fom rom into buffer
    while (not file:isEOF()) do
        buffer[#buffer + 1] = file:read(1):byte()

        -- check rom buffer status
        if (not buffer[#buffer]) then
            print("reading ROM failed: (" .. (buffer[#buffer] or "nil") .. ")")
            return
        end
    end

    -- load each byte from rom to memory
    for byte = 1, #buffer, 1 do
        self.mem[byte - 1] = buffer[byte]
    end

    file:close()
end

-- main instruction cycle
function Bytepusher.cycle()
    -- precompute
    local pc = self.pc
    local mem = self.mem

    -- fetch
    pc = bit.bor(bit.lshift(mem[2], 16), bit.lshift(mem[3], 8), mem[4])

    for _ = 0, INSTR_PER_FRAME, 1 do
        -- cycle 24-bit addresses
        local A = bit.bor(bit.lshift(mem[pc + 0], 16), bit.lshift(mem[pc + 1], 8),
            mem[pc + 2])
        local B = bit.bor(bit.lshift(mem[pc + 3], 16), bit.lshift(mem[pc + 4], 8),
            mem[pc + 5])
        local C = bit.bor(bit.lshift(mem[pc + 6], 16), bit.lshift(mem[pc + 7], 8),
            mem[pc + 8])

        -- copy
        mem[B] = mem[A]

        -- jump
        pc = C
    end
end

return Bytepusher
