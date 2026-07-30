# lnuminfo

> [!IMPORTANT]
> 
> Do **NOT** use this library while it has not been published on LuaRocks. The last few bugs are being fixed.

[![LuaRocks](https://img.shields.io/luarocks/v/luau-project/lnuminfo?label=LuaRocks&color=2c3e67)](https://luarocks.org/modules/luau-project/lnuminfo)
[![Coverage Status](https://codecov.io/gh/luau-project/lnuminfo/branch/main/graph/badge.svg)](https://app.codecov.io/gh/luau-project/lnuminfo/tree/main)

Detect characteristics of floating-point numbers in pure Lua.

## Table of Contents

* [Introduction](#introduction)
    * [Floating-point Model](#floating-point-model)
    * [Floating-point Characteristics](#floating-point-characteristics)
* [Usage](#usage)
* [Use Cases](#use-cases)
* [Installation](#installation)
* [Properties](#properties)
* [Methods](#methods)
* [Tests](#tests)
* [Code Coverage](#code-coverage)
* [Contact](#contact)
* [History](#history)

## Introduction

Usually, the standard build of Lua (&ge; `5.1`) uses `double` as a floating-point type. Since version `5.3`, one can build Lua employing `float` (single precision), `double` (double precision) or `long double` (often, double extended precision on Intel / AMD x86) as the floating-point type for Lua numbers. Nowadays, almost all processors / compilers are compliant to IEEE 754 standard floating-point formats:

1. IEEE 754 standard, 32-bit base-2, known as `binary32` (single precision)
2. IEEE 754 standard, 64-bit base-2, known as `binary64` (double precision)
3. IEEE 754 standard, 80-bit base-2, known as `binary64-extended` (double extended precision)

> [!NOTE]
> 
> On Windows, the Microsoft Visual C/C++ toolchain (MSVC) maps `long double` to double precision (`binary64`) floating-point numbers. On the ARM64 architecture used by Apple Silicon macOS, `long double` is also mapped to `binary64`.

In plain Lua, there is no way to know the low level numerical limits which apply to Lua numbers.

### Floating-point Model

Quoting the C89 standard (American National Standard FIPS PUB 160 X3.159-1989 document)

> A *normalized floating-point* number $x \ \left(f_1 > 0 \ \  if \ \  x \neq 0\right)$ is defined by the following model:
> 
> $$
> x = s \cdot b^e \cdot \sum_{k = 1}^{p} f_k \cdot b^{-k}
> $$

with the following meaning:

* $s$: sign ($\pm 1$)
* $b$: base or radix of exponent representation (an integer > 1)
* $e$: exponent (an integer between a minimum $e_{min}$ and a maximum $e_{max}$)
* $p$: precision (the number of base - $b$ digits in the significand)
* $f_k$: nonnegative integers less than $b$ (the significand digits)

In C, floating-point characteristics are exposed to the developer through macros in the `<float.h>` header by the C89 standard. However, such information is not exposed to Lua, and there are no plans to include it in the language by the Lua team (see [here](https://groups.google.com/g/lua-l/c/vKpvPqiP7tY/m/SRQfthWJCwAJ)).

Thus, the role of `lnuminfo` is to determine dynamically, in pure Lua, a set of [characteristics](#floating-point-characteristics) ($e_{min}$, $e_{max}$, $p$ and so on) of floating-point numbers in use, unveiling critical information for numerical computing and statistics.

### Floating-point Characteristics

| Name | Type | Description |
|---|---|---|
| `DIG` | `integer` | Number of decimal digits, $q$, such that any floating-point number with $q$ decimal digits can be rounded into a floating-point number with $p$ radix $b$ digits and back again without change to the $q$ decimal digits. |
| `EPSILON` | `number` | The difference between 1.0 and the least value greater than 1.0 that is representable in the given floating point type. |
| `MANT_DIG` | `integer` | Number of base - `RADIX` digits in the floating-point significand ( $p$ ). |
| `MAX` | `number` | Maximum representable finite floating-point number. |
| `MAX_10_EXP` | `number` | Maximum negative integer such that 10 raised to that power is in the range of representable finite floating-point numbers. |
| `MAX_EXP` | `integer` | Maximum negative integer such that `RADIX` raised to that power minus 1 is a representable finite floating-point number ( $e_{max}$ ). |
| `MIN` | `number` | Minimum normalized floating-point number. |
| `MIN_10_EXP` | `integer` | Minimum negative integer such that 10 raised to that power is in the range of normalized floating-point numbers. |
| `MIN_EXP` | `integer` | Minimum negative integer such that `RADIX` raised to that power minus 1 is a normalized floating-point number ( $e_{min}$ ). |
| `RADIX` | `integer` | radix of exponent representation ( $b$ ). |

> [!TIP]
> 
> Such descriptions in the table were taken from the C89 standard (American National Standard FIPS PUB 160 X3.159-1989 document).

## Usage

```lua
-- load the module
local lnuminfo = require("lnuminfo")

-- print the library version
print(lnuminfo.version)

-- get a table holding
-- all the characteristics
local info = lnuminfo.detect()

-- print characteristics available
-- in the `info' table
print(info.DIG)
print(info.EPSILON)
print(info.MANT_DIG)
print(info.MAX)
print(info.MAX_10_EXP)
print(info.MAX_EXP)
print(info.MIN)
print(info.MIN_10_EXP)
print(info.MIN_EXP)
print(info.RADIX)
```

## Use Cases

In embedded systems, a device supporting only 32-bit numbers (`binary32`) may be a wise choice to cut manufacturing costs. On the other hand, in scientific computing using powerful hardware, it makes sense to utilize `binary64-extended` or even 128-bit numbers (`binary128`) to improve precision of numerical algorithms.

In pure Lua, there's no straightforward manner to obtain the underlying C type of Lua numbers. By the use of `lnuminfo`, one can:

* calculate numerical limits (e.g.: `MANT_DIG`);
* control precision of algorithms (e.g.: `DIG` and `EPSILON`) in the host machine;
* prevent overflow (e.g.: `MAX`) and underflow (e.g.: `MIN`);
* figure out whether Lua targets `binary32`, `binary64` or `binary64-extended`, under the (very probable) assumption that the system follows IEEE 754 floating-point formats.

## Installation

### LuaRocks

By far, [LuaRocks](https://luarocks.org/) offers the easiest (and **recommended**) manner to install `lnuminfo` on your system:

```bash
luarocks install lnuminfo
```

### Manual

Simply copy the file [lnuminfo.lua](./lnuminfo.lua) to any location covered by `LUA_PATH` environment variable. If you don't know how `LUA_PATH` works, run this Lua script to find suitable locations to store the content of [lnuminfo.lua](./lnuminfo.lua) in a way expected by the Lua interpreter:

```lua
for path in package.path:gmatch('[^;]+') do
    print((path:gsub('%?', 'lnuminfo')))
end
```

### Makefile

**Advanced users**: alternatively, if you feel comfortable enough working with Makefiles, then read [how to install `lnuminfo` through the Makefiles](./Makefile.md).

## Properties

### version

* Description: the version of this library.
* Signature: `lnuminfo.version`
* Return (string): a string containing the library version.

## Methods

### detect

* Description: detect characteristics of floating-point numbers.
* Signature: `lnuminfo.detect([RADIX])`
* Parameters:
    * `RADIX` (nil | integer): if `RADIX` is nil, then 2 is used. Otherwise, `RADIX` is expected to be an integer > 1.
* Return (table): a table containing [characteristics of floating-point](#floating-point-characteristics) numbers.

## Tests

At the moment, it is possible to run tests targeting IEEE 754 `binary32`, IEEE 754 `binary64` or IEEE 754 `binary64-extended`:

* IEEE 754 `binary32`:

    ```bash
    lua test.lua IEEE-754-binary32
    ```

* IEEE 754 `binary64`:

    ```bash
    lua test.lua IEEE-754-binary64
    ```

* IEEE 754 `binary64-extended`:

    ```bash
    lua test.lua IEEE-754-binary64-extended
    ```

## Code Coverage

1. Install `luacov`: in order to collect code coverage data, you must install [LuaCov](https://github.com/lunarmodules/luacov). Again, `luarocks` provides a straightforward manner to setup `luacov` on your machine:

    ```bash
    luarocks install luacov
    ```

2. Choose **one** of the IEEE 754 formats and run tests collecting coverage data adding a `--coverage` flag:

    * IEEE 754 `binary32`:

        ```bash
        lua test.lua --coverage IEEE-754-binary32
        ```

    * IEEE 754 `binary64`:

        ```bash
        lua test.lua --coverage IEEE-754-binary64
        ```

    * IEEE 754 `binary64-extended`:

        ```bash
        lua test.lua --coverage IEEE-754-binary64-extended
        ```

3. Generate the coverage report (the file `luacov.report.out`):

    ```bash
    luacov
    ```

4. Open the generated file `luacov.report.out` in the text editor of your preference to review the coverage report.

> [!IMPORTANT]
> 
> If you are modifying the source code and running code coverage repeatedly, don't forget to delete `luacov.stats.out` and `luacov.report.out` on each iteration.

## Contact

Do you have bug reports, questions or a feature request? Please, [open an issue](https://github.com/luau-project/lnuminfo/issues).

## History

Browse the [changelog](./CHANGELOG.md).