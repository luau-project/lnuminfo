--================================================================================--
-- LICENSE (MIT)                                                                  --
--================================================================================--
--                                                                                --
-- The MIT License (MIT)                                                          --
--                                                                                --
-- Copyright (c) 2026 luau-project https://github.com/luau-project/lnuminfo       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --
--================================================================================--

-- Constants
local version = "0.0.1" -- library version
local _RADIX_ = 2 -- default RADIX

-- Start of auxiliary math functions
local ceil = math.ceil
local floor = math.floor
local huge = math.huge
local mlog = math.log
local log = mlog
if ((_VERSION:sub(5) == "5.1") and (mlog(10, 10) ~= 1)) then
    log = function(x, b)
        return ((mlog(x)) / (mlog(b)))
    end
end

local function chi(x, v)
    return (((x == v) and 1) or 0)
end
-- End of auxiliary math functions

-- Start of library implementation
local function emax(b)
    local result = 2
    pcall(function()
        while ((b ^ (result - 1)) ~= huge) do
            result = result + 1
        end
    end)

    return (result - 1)
end

local function emin(b)
    local result = -2
    pcall(function()
        while ((b / (b ^ (result - 1))) ~= huge) do
            result = result - 1
        end
    end)

    return (result + 1)
end

local function epsilon(b)
    local factor = b ^ (-1)
    local step = factor
    while ((1 + step) ~= 1) do
        step = step * factor
    end
    return (step * b)
end

local function p(b, eps)
    return (floor(1 - (log(eps, b))))
end

local function max(b, M, digits)
    return ((b - (b^(1 - digits))) * (b ^ (M - 1)))
end

local function min(b, m)
    return (b ^ (m - 1))
end

local function emax10(b, M)
    return floor(log(M, 10))
end

local function emin10(b, m)
    return ceil(log(m, 10))
end

local function dig(b, digits)
    local bl = log(b, 10)
    return (floor((digits - 1) * bl)) + (chi(bl, (floor(bl))))
end

local function detect(RADIX)
    -- Set b to the provided RADIX,
    -- validating the param.
    -- RADIX must be nil or
    -- a positive integer greater than one.
    local b
    if (RADIX == nil) then
        b = _RADIX_
    else
        local tradix = type(RADIX)
        if (tradix == "number") then
            local temp = floor(RADIX)
            if (temp == RADIX) then
                if (temp > 1) then
                    b = temp
                else
                    error("RADIX must be a positive integer greater than one.", 2)
                end
            else
                error("RADIX must be an integer.", 2)
            end
        else
            error("RADIX must be nil or a number.", 2)
        end
    end

    local m = emin(b)
    local M = emax(b)
    local eps = epsilon(b)
    local digits = p(b, eps)
    local _M = max(b, M, digits)
    local _m = min(b, m)

    return {
        RADIX = b,
        MANT_DIG = digits,
        DIG = dig(b, digits),
        MIN_EXP = m,
        MIN_10_EXP = emin10(b, _m),
        MAX_EXP = M,
        MAX_10_EXP = emax10(b, _M),
        MAX = _M,
        EPSILON = eps,
        MIN = _m
    }
end
-- End of library implementation

local index = {
    detect = detect,
    version = version
}

-- Export module as read-only
return setmetatable({}, {
    __index = index,
    __newindex = function(self, k, v)
        error("lnuminfo is read-only.", 2)
    end,
    __metatable = false
})
