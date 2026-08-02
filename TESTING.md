# Testing

## Test Platforms

At the moment, through [CI](./.github/workflows/ci.yml), the code is tested on:

* Linux (x86_64 and ARM64) with GCC provided by Ubuntu
* macOS (ARM64 on Apple Silicon) with Apple Clang
* Windows (x86_64 and ARM64):
    * with MSVC provided by Microsoft;
    * with MinGW-w64, except `long double` as detailed at [Known Issues](./README.md#known-issues), provided by `GCC`.

## Mental Model of the Testing Process

At first, we need to have a high-level understanding of the testing process:

1. Begin choosing a C floating-point type to test `lnuminfo` (e.g.: `float`, `double` or `long double`);
2. Obtain the source code for Lua 5.1 or newer (including LuaJIT);
3. If testing for Lua 5.3 or newer **AND** the selected C type is `float` or `long double`, then patch `luaconf.h` to turn a `lua_Number` into the chosen floating-point type on step (1.);
4. Build the source code of Lua / LuaJIT;
5. Build [tnuminfo.c](./tnuminfo.c) as a native Lua C module;
6. Run the tests ([test.lua](./test.lua)), optionally capturing statistics of code coverage.

> [!NOTE]
> 
> [tnuminfo.c](./tnuminfo.c) is a Lua module written in C that bridges all the constants (see [here](./README.md#floating-point-characteristics)) provided by the underlying C compiler to Lua code. This way, in the [test.lua](./test.lua) file, these C constants are equality-compared to the ones calculated by [lnuminfo.lua](./lnuminfo.lua).

> [!TIP]
> 
> Check the `.patch` files in the folder [./.github/workflows/](./.github/workflows/) for the patches we apply on Lua source code split by version, and by C type.

## Test

After finishing the setup of a patched Lua version, and the [tnuminfo.c](./tnuminfo.c) is built, just run the command

```bash
lua test.lua
```

to run the test suite.

## Code Coverage

1. Additionally, to run code coverage on tests, `lnuminfo` needs [LuaCov](https://github.com/lunarmodules/luacov). Even though [LuaRocks](https://luarocks.org/) is not strictly required, it provides the easiest manner to install `luacov`:

    ```bash
    luarocks install luacov
    ```

> [!IMPORTANT]
> 
> It is a good practice to setup an isolated testing environment (e.g.: a virtual machine) to run tests for `lnuminfo` without messing around with your system. Moreover, to properly test `lnuminfo` avoiding noises from the environment, it is recommended to install the whole stack (`luarocks` + `luacov`) using the same patched Lua version in use by `lnuminfo`.

2. So, after `luacov` has been installed for the patched Lua version, and the [tnuminfo.c](./tnuminfo.c) is built, run the command

    ```bash
    lua test.lua --coverage
    ```

    to collect statistics of code coverage. These statistics are written to the file `luacov.stats.out` on a successful run;

3. Generate the coverage report running the command

    ```bash
    luacov
    ```

    The report can be seen on file `luacov.stats.out` after `luacov` finished the work.

## Conclusion

The process to setup the environment and all the necessary tools can be see on [CI](./.github/workflows/ci.yml).