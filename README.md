# lnuminfo

[![LuaRocks](https://img.shields.io/luarocks/v/luau-project/lnuminfo?label=LuaRocks&color=2c3e67)](https://luarocks.org/modules/luau-project/lnuminfo)
[![Coverage Status](https://codecov.io/gh/luau-project/lnuminfo/branch/main/graph/badge.svg)](https://app.codecov.io/gh/luau-project/lnuminfo/tree/main)

Detect characteristics of floating-point numbers in pure Lua.

## Quick Install

By far, [LuaRocks](https://luarocks.org/) offers the easiest and recommended method to install `lnuminfo` on your system:

```bash
luarocks install lnuminfo
```

## Usage

```lua
-- load the module
local lnuminfo = require("lnuminfo")

-- print the library version
print("lnuminfo version:", lnuminfo.version)

-- get a table holding
-- all the characteristics
local info = lnuminfo.detect()

-- print characteristics available
-- in the `info' table
print("DIG:",        info.DIG)
print("EPSILON:",    info.EPSILON)
print("MANT_DIG:",   info.MANT_DIG)
print("MAX:",        info.MAX)
print("MAX_10_EXP:", info.MAX_10_EXP)
print("MAX_EXP:",    info.MAX_EXP)
print("MIN:",        info.MIN)
print("MIN_10_EXP:", info.MIN_10_EXP)
print("MIN_EXP:",    info.MIN_EXP)
print("RADIX:",      info.RADIX)
```

## Floating-point Characteristics

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

## Table of Contents

* [Introduction](#introduction)
* [Use Cases](#use-cases)
* [Alternative Installation Methods](#alternative-installation-methods)
* [Properties](#properties)
    * [version](#version)
* [Methods](#methods)
    * [detect](#detect)
* [Tests](#tests)
* [Known Issues](#known-issues)
* [Contact](#contact)
* [History](#history)

## Introduction

Usually, the standard build of Lua (&ge; `5.1`) uses `double` as a floating-point type. Since version `5.3`, with minimal to pratically no effort, one can build Lua employing `float`, `double` or `long double` as the floating-point type for Lua numbers. Nowadays, although not mandatory by the C standard, default C compiler settings in different platforms will usually map these C types to common IEEE 754 standard floating-point formats:

1. IEEE 754 standard, 32-bit base-2, known as `binary32` (single precision)
2. IEEE 754 standard, 64-bit base-2, known as `binary64` (double precision)
3. IEEE 754 standard, 80-bit base-2, known as `binary64-extended` (double extended precision)
4. IEEE 754 standard, 128-bit base-2, known as `binary128` (quadruple precision)

Often, `float` is mapped to `binary32`, `double` to `binary64` and `long double` to `binary64-extended` in recent Intel / AMD `X86` or `x86_64` platforms.

> [!NOTE]
> 
> By the C standard, the C type `long double` is not required to have a higher precision than `double`:
> 
> * On Windows, the Microsoft Visual C/C++ toolchain (MSVC) maps `long double` to double precision (`binary64`) floating-point numbers. If you use MinGW / MinGW-w64 toolchains building Lua numbers for `long double`, please check the [known issues](#known-issues);
> * On the ARM64 architecture used by Apple Silicon macOS, `long double` is also mapped to `binary64`.

In C, [floating-point characteristics](#floating-point-characteristics) are exposed to the developer through macros in the `<float.h>` header by the C89 standard. However, such information is not exposed to Lua, and there are no plans to include it in the language by the Lua team (see [here](https://groups.google.com/g/lua-l/c/vKpvPqiP7tY/m/SRQfthWJCwAJ)).

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

Thus, the role of `lnuminfo` is to determine dynamically, in pure Lua, a set of [characteristics](#floating-point-characteristics) ($e_{min}$, $e_{max}$, $p$ and so on) of floating-point numbers in use, unveiling critical information for numerical computing and statistics.

## Use Cases

In embedded systems, a device supporting only 32-bit numbers may be a wise choice to cut manufacturing costs. On the other hand, in scientific computing using powerful hardware, it makes sense to utilize `long double` to improve precision of numerical algorithms.

By the use of `lnuminfo`, one can:

* calculate numerical limits (e.g.: `MANT_DIG`);
* control precision of algorithms (e.g.: `DIG` and `EPSILON`) in the host machine;
* prevent overflow (e.g.: `MAX`) and underflow (e.g.: `MIN`).

## Alternative Installation Methods

The recommended method to install `lnuminfo` through `luarocks` is detailed in the [Quick Install](#quick-install). If you are not inclined to use `luarocks`, you can [Copy Files Manually](#copy-files-manually) or use [Makefiles](#makefiles) instead.

### Copy Files Manually

Simply copy the file [lnuminfo.lua](./lnuminfo.lua) to any location covered by `LUA_PATH` environment variable. If you don't know how `LUA_PATH` works, run this Lua script to find suitable locations to store the content of [lnuminfo.lua](./lnuminfo.lua) in a way expected by the Lua interpreter:

```lua
for path in package.path:gmatch('[^;]+') do
    print((path:gsub('%?', 'lnuminfo')))
end
```

### Makefiles

*Advanced users only*: alternatively, if you feel comfortable enough working with Makefiles, then read [how to install `lnuminfo` through the Makefiles](./Makefile.md).

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

The process to run tests in order to assert that `lnuminfo` works correctly is a bit delicate and requires non-trivial knowledge. For such reason, the details to run the test suite are located in the [TESTING](./TESTING.md) page.

## Known Issues

> [!IMPORTANT]
> 
> In almost all scenarios, including the case that no changes were made to the Lua source code, it will not affect you. The issue described on this section only affects custom builds of Lua such that the `lua_Number` type was changed to a `long double` on a MinGW / MinGW-w64 powered compilers.

On Windows, the Microsoft C Runtime (CRT) maps `long double` to 64-bit `binary64`. For the MSVC toolchain, it is not a problem at all. On the other hand, for MinGW / MinGW-w64, it causes some incompatibilities with `GCC`.

In `GCC`, without fine tunning compiler options, `long double` on X86 follows the 80-bit `binary64-extended` format. As explained earlier, the underlying Microsoft C Runtime (CRT) assumes that `long double` follows 64-bit `binary64`.

So, if you edit Lua source code to allow a `lua_Number` to be a `long double`, then everytime Lua calls a mathematical function for `long double` (e.g.: `powl`, `logl`), like this library does, the caller code (e.g.: `GCC`) thinks to be exchanging a 80-bit `binary64-extended` number with the underlying CRT, but it is in fact receiving a 64-bit `binary64`. This is also true for other functions like `printf`.

In short, there is no way (*I guess*) for a Lua build through MinGW / MinGW-w64 setting the type `lua_Number` to a `long double` to work correctly. Sooner or later, you are going to face all sort of unintended behaviors.

**References**:

* [https://stackoverflow.com/questions/77806794/are-long-doubles-broken-using-mingw-w64](https://stackoverflow.com/questions/77806794/are-long-doubles-broken-using-mingw-w64)
* [https://dev.to/martinlicht/the-long-double-trouble-with-mingw-and-windows-55kc](https://dev.to/martinlicht/the-long-double-trouble-with-mingw-and-windows-55kc)

## Contact

Do you have bug reports, questions or a feature request? Please, [open an issue](https://github.com/luau-project/lnuminfo/issues).

## History

Browse the [changelog](./CHANGELOG.md).