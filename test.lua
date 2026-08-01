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

-- user setting to run luacov
-- at startup or not
local coverage = false

if (type(arg) == "table") then
    local i = 0
    local item
    repeat
        item = arg[i]

        if (type(item) == "string") then
            if ((item == "-c") or (item == "--coverage")) then
                coverage = true
            end
        end
        i = i + 1
    until (item == nil)
end

if (coverage) then
    local luacov_ok, runner = pcall(require, "luacov.runner")
    if (luacov_ok) then
        runner.init()
    else
        error("Unable to load `luacov.runner'. Please, install LuaCov to collect coverage data.", 2)
    end
end

local ltestlib = require("ltestlib")

local testnames = {}
local lnuminfo

testnames.n1 = "lnuminfo module should not be nil"
ltestlib.new_test(testnames.n1, function()
    lnuminfo = require("lnuminfo")
    ltestlib.assert_not_equal(testnames.n1, nil, lnuminfo)
end)

testnames.n2 = "lnuminfo module should be a table"
ltestlib.new_test(testnames.n2, function()
    ltestlib.assert_equal(testnames.n2, "table", type(lnuminfo))
end)

testnames.n3 = "lnuminfo module should be read-only"
ltestlib.new_test(testnames.n3, function()
    local values = {
        1, 0.5, -1, -4.3, {}, false, true, function() end, coroutine.wrap(function() end), "str"
    }
    for i, value in ipairs(values) do
        ltestlib.assert_throws(testnames.n3, function() lnuminfo[value] = 1 end)
    end
end)

testnames.n4 = "lnuminfo.version should return a string following the pattern [0-9]+%.[0-9]+%.[0-9]+"
ltestlib.new_test(testnames.n4, function()
    local v = lnuminfo.version
    local m = v:match("^[0-9]+%.[0-9]+%.[0-9]+$")
    ltestlib.assert_equal(testnames.n4, v, m)
end)

testnames.n5 = "lnuminfo.detect should be a function"
ltestlib.new_test(testnames.n5, function()
    ltestlib.assert_equal(testnames.n5, "function", type(lnuminfo.detect))
end)

testnames.n6 = "lnuminfo.detect() should return a table"
ltestlib.new_test(testnames.n6, function()
    local t = lnuminfo.detect()
    ltestlib.assert_equal(testnames.n6, "table", type(lnuminfo.detect()))
end)

testnames.n7 = "lnuminfo.detect() with nil as argument should return RADIX as 2"
ltestlib.new_test(testnames.n7, function()
    local t = lnuminfo.detect()
    ltestlib.assert_equal(testnames.n7, 2, t.RADIX)
end)

testnames.n8 = "lnuminfo.detect() with 16 as argument should return RADIX as 16"
ltestlib.new_test(testnames.n8, function()
    local t = lnuminfo.detect(16)
    ltestlib.assert_equal(testnames.n8, 16, t.RADIX)
end)

testnames.n9 = "lnuminfo.detect() with non-number argument should throw exception"
ltestlib.new_test(testnames.n9, function()
    local values = {
        {}, false, true, function() end, coroutine.wrap(function() end), "str"
    }
    for i, value in ipairs(values) do
        ltestlib.assert_throws(testnames.n9, function() lnuminfo.detect(value) end)
    end
end)

testnames.n10 = "lnuminfo.detect() with non-integer argument should throw exception"
ltestlib.new_test(testnames.n10, function()
    local values = {
        1.5, 2.5, 5.5, -3.3, -9.1, math.pi
    }
    for i, value in ipairs(values) do
        ltestlib.assert_throws(testnames.n10, function() lnuminfo.detect(value) end)
    end
end)

testnames.n11 = "lnuminfo.detect() with integer argument smaller than 2 should throw exception"
ltestlib.new_test(testnames.n11, function()
    local values = {
        -3, -2, -1, 0, 1
    }
    for i, value in ipairs(values) do
        ltestlib.assert_throws(testnames.n11, function() lnuminfo.detect(value) end)
    end
end)

testnames.n12 = "lnuminfo.detect() should return a table containing the fields: RADIX, MANT_DIG, DIG, MIN_EXP, MIN_10_EXP, MAX_EXP, MAX_10_EXP, MAX, EPSILON and MIN"
ltestlib.new_test(testnames.n12, function()
    local t = lnuminfo.detect()
    local fields = {
        "RADIX", "MANT_DIG", "DIG", "MIN_EXP", "MIN_10_EXP", "MAX_EXP", "MAX_10_EXP", "MAX", "EPSILON", "MIN"
    }
    for i, key in ipairs(fields) do
        local value = t[key]
        ltestlib.assert_equal(
            testnames.n12, "number", type(value),
            ("The key %q was not found in the table returned by lnuminfo.detect()"):format(key)
        )
        ltestlib.logfmt(
            testnames.n12, "%s key has value %s", key, value
        )
    end
end)

local tnuminfo_ok, tnuminfo = pcall(require, "tnuminfo")
local tnuminfo_type = type(tnuminfo)
if (tnuminfo_ok and (tnuminfo_type == "table")) then
    for _, key in ipairs({"RADIX", "MANT_DIG", "DIG", "MIN_EXP", "MIN_10_EXP", "MAX_EXP", "MAX_10_EXP", "MAX", "EPSILON", "MIN"}) do
        testnames[key] = ("lnuminfo.detect().%s should match tnuminfo.detect().%s"):format(key, key)
        ltestlib.new_test(testnames[key], function()
            ltestlib.assert_equal(
                testnames[key],
                tnuminfo.detect()[key],
                lnuminfo.detect()[key]
            )
        end)
    end
else
    testnames.n13 = "tnuminfo should be nil if failed to require on Lua versions 5.4 or older"
    ltestlib.new_test(testnames.n13, function()
        local major, minor = _VERSION:sub(5):match("^(%d+)%.(%d+)$")
        major, minor = tonumber(major), tonumber(minor)
        ltestlib.assert_equal(testnames.n13, "number", type(major))
        ltestlib.assert_equal(testnames.n13, "number", type(minor))
        if ((major >= 5) and (minor <= 4)) then
            ltestlib.assert_equal(
                testnames.n13, "nil", tnuminfo_type
            )
        end
    end)

    testnames.n14 = "tnuminfo should be a string if failed to require on Lua versions 5.5 or newer"
    ltestlib.new_test(testnames.n14, function()
        local major, minor = _VERSION:sub(5):match("^(%d+)%.(%d+)$")
        major, minor = tonumber(major), tonumber(minor)
        ltestlib.assert_equal(testnames.n14, "number", type(major))
        ltestlib.assert_equal(testnames.n14, "number", type(minor))
        if ((major >= 5) and (minor >= 5)) then
            ltestlib.assert_equal(
                testnames.n14, "string", tnuminfo_type
            )
        end
    end)
end

-- Execute the tests
ltestlib.execute()

-- Collect statistics
-- and print the
-- summary review
ltestlib.summary()

-- Finish the tests
ltestlib.finish()
