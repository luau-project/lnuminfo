# Install through Makefiles

In order to install `lnuminfo` through the makefiles, you are required to know the directory used by the interpreter to locate Lua modules (directories covered by `LUA_PATH` environment variable). Once you know this directory, pass it as `INSTALL_LMOD` argument to install `lnuminfo` through the makefiles as outlined below.

## Unix

### INSTALL_LMOD

Most distributions provide a `pkg-config` file for Lua, often named `lua5.1.pc` for Lua 5.1 (or `lua5.2.pc` for Lua 5.2) and so on. It is possible to list `pkg-config` files for Lua through the command

```bash
pkg-config --list-all | grep lua
```

Thus, through `make` and `pkg-config` tools, the command

```bash
make -f Makefile.unix "INSTALL_LMOD=$(pkg-config --variable=INSTALL_LMOD lua5.1)" install
```

installs `lnuminfo` for Lua 5.1 (*adjust for other Lua versions*)

### PREFIX

It is also possible to install using the `PREFIX` argument. By default, `PREFIX` is configured to `/usr/local`. However, if you have your Lua installation on a custom location like `/opt/lua`, then you can install through the command

* Lua 5.1:

    ```bash
    make -f Makefile.unix "PREFIX=/opt/lua" "LUA_VERSION=5.1" install
    ```

* Lua 5.2:

    ```bash
    make -f Makefile.unix "PREFIX=/opt/lua" "LUA_VERSION=5.2" install
    ```

* Lua 5.3:

    ```bash
    make -f Makefile.unix "PREFIX=/opt/lua" "LUA_VERSION=5.3" install
    ```

and so on, just adjust the `LUA_VERSION` argument.

## Windows

### MSYS2 or Cygwin

If your Lua installation comes from MSYS2 or Cygwin, then use the [Unix mode](#unix) to install `lnuminfo`.

### MSVC

* Lua 5.1, Lua 5.2 or LuaJIT:

    ```cmd
    nmake /F Makefile.windows "INSTALL_LMOD={luadir}\bin\lua" install
    ```

    where `{luadir}` should be replaced by the installation directory of Lua (assuming that `lua.exe` is stored at `{luadir}\bin`)

* Lua 5.3 or newer:

    ```cmd
    nmake /F Makefile.windows "INSTALL_LMOD={luadir}\share\lua\X.Y" install
    ```

    where `{luadir}` should be replaced by the installation directory of Lua (assuming that `lua.exe` is placed at `{luadir}\bin`) and `X.Y` is 5.3 for Lua 5.3 and so on.

### MinGW and MinGW-w64

* Lua 5.1, Lua 5.2 or LuaJIT:

    ```cmd
    mingw32-make -f Makefile.windows "INSTALL_LMOD={luadir}\bin\lua" install
    ```

    where `{luadir}` should be replaced by the installation directory of Lua (assuming that `lua.exe` is stored at `{luadir}\bin`)

* Lua 5.3 or newer:

    ```cmd
    mingw32-make -f Makefile.windows "INSTALL_LMOD={luadir}\share\lua\X.Y" install
    ```

    where `{luadir}` should be replaced by the installation directory of Lua (assuming that `lua.exe` is placed at `{luadir}\bin`) and `X.Y` is 5.3 for Lua 5.3 and so on.

---

[Back to Home](./README.md)