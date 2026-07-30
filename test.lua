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

-- Constants to mark whether
-- to run tests against
-- IEEE-754-binary32 or
-- IEEE-754-binary64 or
-- IEEE-754-binary64-extended
local IEEE_754_BINARY32 = "IEEE-754-binary32"
local IEEE_754_BINARY64 = "IEEE-754-binary64"
local IEEE_754_BINARY64_EXTENDED = "IEEE-754-binary64-extended"

-- user setting to run luacov
-- at startup or not
local coverage = false

-- user setting to run tests against
-- IEEE_754_BINARY32 or IEEE_754_BINARY64 or IEEE-754-binary64-extended
local testkind

if (type(arg) == "table") then
    local i = 0
    local item
    repeat
        item = arg[i]

        if (type(item) == "string") then
            if ((item == "-c") or (item == "--coverage")) then
                coverage = true
            end

            if (
                (item == IEEE_754_BINARY32) or
                (item == IEEE_754_BINARY64) or
                (item == IEEE_754_BINARY64_EXTENDED)
            ) then
                if ((testkind ~= nil) and (testkind ~= item)) then
                    error(("Test for %s was already provided."):format(testkind), 2)
                end
                testkind = item
            end
        end
        i = i + 1
    until (item == nil)
end

if (testkind == nil) then
    error(
        ("%s or %s was not provided. You must select at least one kind of tests."):format(
            IEEE_754_BINARY32, IEEE_754_BINARY64, IEEE_754_BINARY64_EXTENDED
        ),
        2
    )
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
        ltestlib.assert_equal(
            testnames.n12, "number", type(t[key]),
            ("The key %q was not found in the table returned by lnuminfo.detect()"):format(key)
        )
    end
end)

if (testkind == IEEE_754_BINARY64) then
    testnames.EPSILON = "lnuminfo.detect().EPSILON should be close enough to 2.2204460492503131e-16 for IEEE-754 binary64"
    ltestlib.new_test(testnames.EPSILON, function()
        ltestlib.assert_true(
            testnames.EPSILON,
            math.abs(2.2204460492503131e-16 - lnuminfo.detect().EPSILON) < 1e-16
        )
    end)

    testnames.MAX = "lnuminfo.detect().MAX should be close enough to 1.7976931348623157e+308 for IEEE-754 binary64"
    ltestlib.new_test(testnames.MAX, function()
        ltestlib.assert_true(
            testnames.MAX,
            math.abs(1.7976931348623157e+308 - lnuminfo.detect().MAX) < 1e-16
        )
    end)

    testnames.MIN = "lnuminfo.detect().MIN should be close enough to 2.2250738585072014e-308 for IEEE-754 binary64"
    ltestlib.new_test(testnames.MIN, function()
        ltestlib.assert_true(
            testnames.MIN,
            math.abs(2.2250738585072014e-308 - lnuminfo.detect().MIN) < 1e-308
        )
    end)

    testnames.MAX_EXP = "lnuminfo.detect().MAX_EXP should be equal to 1024 for IEEE-754 binary64"
    ltestlib.new_test(testnames.MAX_EXP, function()
        ltestlib.assert_equal(
            testnames.MAX_EXP,
            1024,
            lnuminfo.detect().MAX_EXP
        )
    end)

    testnames.MIN_EXP = "lnuminfo.detect().MIN_EXP should be equal to -1021 for IEEE-754 binary64"
    ltestlib.new_test(testnames.MIN_EXP, function()
        ltestlib.assert_equal(
            testnames.MIN_EXP,
            -1021,
            lnuminfo.detect().MIN_EXP
        )
    end)

    testnames.MAX_10_EXP = "lnuminfo.detect().MAX_10_EXP should be equal to 308 for IEEE-754 binary64"
    ltestlib.new_test(testnames.MAX_10_EXP, function()
        ltestlib.assert_equal(
            testnames.MAX_10_EXP,
            308,
            lnuminfo.detect().MAX_10_EXP
        )
    end)

    testnames.MIN_10_EXP = "lnuminfo.detect().MIN_10_EXP should be equal to -307 for IEEE-754 binary64"
    ltestlib.new_test(testnames.MIN_10_EXP, function()
        ltestlib.assert_equal(
            testnames.MIN_10_EXP,
            -307,
            lnuminfo.detect().MIN_10_EXP
        )
    end)

    testnames.DIG = "lnuminfo.detect().DIG should be equal to 15 for IEEE-754 binary64"
    ltestlib.new_test(testnames.DIG, function()
        ltestlib.assert_equal(
            testnames.DIG,
            15,
            lnuminfo.detect().DIG
        )
    end)

    testnames.MANT_DIG = "lnuminfo.detect().MANT_DIG should be equal to 53 for IEEE-754 binary64"
    ltestlib.new_test(testnames.MANT_DIG, function()
        ltestlib.assert_equal(
            testnames.MANT_DIG,
            53,
            lnuminfo.detect().MANT_DIG
        )
    end)

elseif (testkind == IEEE_754_BINARY32) then

    testnames.EPSILON = "lnuminfo.detect().EPSILON should be close enough to 1.1920920e-7 for IEEE-754 binary32"
    ltestlib.new_test(testnames.EPSILON, function()
        ltestlib.assert_true(
            testnames.EPSILON,
            math.abs(1.1920920e-7 - lnuminfo.detect().EPSILON) < 1e-7
        )
    end)

    testnames.MAX = "lnuminfo.detect().MAX should be close enough to 3.40282347e38 for IEEE-754 binary32"
    ltestlib.new_test(testnames.MAX, function()
        ltestlib.assert_true(
            testnames.MAX,
            math.abs(3.40282347e38 - lnuminfo.detect().MAX) < 1e-7
        )
    end)

    testnames.MIN = "lnuminfo.detect().MIN should be close enough to 1.17549435e-38 for IEEE-754 binary32"
    ltestlib.new_test(testnames.MIN, function()
        ltestlib.assert_true(
            testnames.MIN,
            math.abs(1.17549435e-38 - lnuminfo.detect().MIN) < 1e-38
        )
    end)

    testnames.MAX_EXP = "lnuminfo.detect().MAX_EXP should be equal to 128 for IEEE-754 binary32"
    ltestlib.new_test(testnames.MAX_EXP, function()
        ltestlib.assert_equal(
            testnames.MAX_EXP,
            128,
            lnuminfo.detect().MAX_EXP
        )
    end)

    testnames.MIN_EXP = "lnuminfo.detect().MIN_EXP should be equal to -125 for IEEE-754 binary32"
    ltestlib.new_test(testnames.MIN_EXP, function()
        ltestlib.assert_equal(
            testnames.MIN_EXP,
            -125,
            lnuminfo.detect().MIN_EXP
        )
    end)

    testnames.MAX_10_EXP = "lnuminfo.detect().MAX_10_EXP should be equal to 38 for IEEE-754 binary32"
    ltestlib.new_test(testnames.MAX_10_EXP, function()
        ltestlib.assert_equal(
            testnames.MAX_10_EXP,
            38,
            lnuminfo.detect().MAX_10_EXP
        )
    end)

    testnames.MIN_10_EXP = "lnuminfo.detect().MIN_10_EXP should be equal to -37 for IEEE-754 binary32"
    ltestlib.new_test(testnames.MIN_10_EXP, function()
        ltestlib.assert_equal(
            testnames.MIN_10_EXP,
            -37,
            lnuminfo.detect().MIN_10_EXP
        )
    end)

    testnames.DIG = "lnuminfo.detect().DIG should be equal to 6 for IEEE-754 binary32"
    ltestlib.new_test(testnames.DIG, function()
        ltestlib.assert_equal(
            testnames.DIG,
            6,
            lnuminfo.detect().DIG
        )
    end)

    testnames.MANT_DIG = "lnuminfo.detect().MANT_DIG should be equal to 24 for IEEE-754 binary32"
    ltestlib.new_test(testnames.MANT_DIG, function()
        ltestlib.assert_equal(
            testnames.MANT_DIG,
            24,
            lnuminfo.detect().MANT_DIG
        )
    end)

elseif (testkind == IEEE_754_BINARY64_EXTENDED) then

    testnames.EPSILON = "lnuminfo.detect().EPSILON should be close enough to 1.0842021724855044340e-19 for IEEE-754 binary64-extended"
    ltestlib.new_test(testnames.EPSILON, function()
        ltestlib.assert_true(
            testnames.EPSILON,
            math.abs(1.0842021724855044340e-19 - lnuminfo.detect().EPSILON) < 1e-19
        )
    end)

    testnames.MAX = "lnuminfo.detect().MAX should be close enough to 1.1897314953572317650e+4932 for IEEE-754 binary64-extended"
    ltestlib.new_test(testnames.MAX, function()
        ltestlib.assert_true(
            testnames.MAX,
            math.abs(1.1897314953572317650e+4932 - lnuminfo.detect().MAX) < 1e-19
        )
    end)

    testnames.MIN = "lnuminfo.detect().MIN should be close enough to 3.3621031431120935063e-4932 for IEEE-754 binary64-extended"
    ltestlib.new_test(testnames.MIN, function()
        ltestlib.assert_true(
            testnames.MIN,
            math.abs(3.3621031431120935063e-4932 - lnuminfo.detect().MIN) < 1e-4932
        )
    end)

    testnames.MAX_EXP = "lnuminfo.detect().MAX_EXP should be equal to 16384 for IEEE-754 binary64-extended"
    ltestlib.new_test(testnames.MAX_EXP, function()
        ltestlib.assert_equal(
            testnames.MAX_EXP,
            16384,
            lnuminfo.detect().MAX_EXP
        )
    end)

    testnames.MIN_EXP = "lnuminfo.detect().MIN_EXP should be equal to -16381 for IEEE-754 binary64-extended"
    ltestlib.new_test(testnames.MIN_EXP, function()
        ltestlib.assert_equal(
            testnames.MIN_EXP,
            -16381,
            lnuminfo.detect().MIN_EXP
        )
    end)

    testnames.MAX_10_EXP = "lnuminfo.detect().MAX_10_EXP should be equal to 4932 for IEEE-754 binary64-extended"
    ltestlib.new_test(testnames.MAX_10_EXP, function()
        ltestlib.assert_equal(
            testnames.MAX_10_EXP,
            4932,
            lnuminfo.detect().MAX_10_EXP)
    end)

    testnames.MIN_10_EXP = "lnuminfo.detect().MIN_10_EXP should be equal to -4931 for IEEE-754 binary64-extended"
    ltestlib.new_test(testnames.MIN_10_EXP, function()
        ltestlib.assert_equal(
            testnames.MIN_10_EXP,
            -4931,
            lnuminfo.detect().MIN_10_EXP
        )
    end)

    testnames.DIG = "lnuminfo.detect().DIG should be equal to 18 for IEEE-754 binary64-extended"
    ltestlib.new_test(testnames.DIG, function()
        ltestlib.assert_equal(
            testnames.DIG,
            18,
            lnuminfo.detect().DIG
        )
    end)

    testnames.MANT_DIG = "lnuminfo.detect().MANT_DIG should be equal to 64 for IEEE-754 binary64-extended"
    ltestlib.new_test(testnames.MANT_DIG, function()
        ltestlib.assert_equal(
            testnames.MANT_DIG,
            64,
            lnuminfo.detect().MANT_DIG
        )
    end)

else
    error("Unknown test kind.", 2)
end

-- Execute the tests
ltestlib.execute()

-- Collect statistics
-- and print the
-- summary review
ltestlib.summary()

-- Finish the tests
ltestlib.finish()
