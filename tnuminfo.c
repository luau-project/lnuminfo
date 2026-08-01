/*================================================================================**
** LICENSE (MIT)                                                                  **
**================================================================================**
**                                                                                **
** The MIT License (MIT)                                                          **
**                                                                                **
** Copyright (c) 2026 luau-project https://github.com/luau-project/lnuminfo       **
**                                                                                **
** Permission is hereby granted, free of charge, to any person obtaining a copy   **
** of this software and associated documentation files (the "Software"), to deal  **
** in the Software without restriction, including without limitation the rights   **
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      **
** copies of the Software, and to permit persons to whom the Software is          **
** furnished to do so, subject to the following conditions:                       **
**                                                                                **
** The above copyright notice and this permission notice shall be included in all **
** copies or substantial portions of the Software.                                **
**                                                                                **
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     **
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       **
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    **
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         **
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  **
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  **
** SOFTWARE.                                                                      **
**                                                                                **
**================================================================================*/

/* This file has the only
** purpose to test `lnuminfo' */

#include "luaconf.h"
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include <stddef.h>
#include <float.h>

#if defined(LUA_VERSION_NUM)
#if LUA_VERSION_NUM >= 504
#define tnuminfo_floatatt l_floatatt
#define tnuminfo_mathop l_mathop
#elif LUA_VERSION_NUM == 503
#define tnuminfo_floatatt l_mathlim
#define tnuminfo_mathop l_mathop
#elif LUA_VERSION_NUM == 502
#define tnuminfo_floatatt(n) (n)
#define tnuminfo_mathop l_mathop
#else
#define tnuminfo_floatatt(n) (n)
#define tnuminfo_mathop(op) (op)
#endif
#else
#error "LUA_VERSION_NUM expected to be defined"
#endif

struct tagtnuminfo_lua_Integer {
    const char *name;
    lua_Integer value;
};

static struct tagtnuminfo_lua_Integer tnuminfo_int_values[] = {
    { "RADIX", FLT_RADIX },
    { "DIG", tnuminfo_floatatt(DIG) },
    { "MANT_DIG", tnuminfo_floatatt(MANT_DIG) },
    { "MAX_EXP", tnuminfo_floatatt(MAX_EXP) },
    { "MAX_10_EXP", tnuminfo_floatatt(MAX_10_EXP) },
    { "MIN_EXP", tnuminfo_floatatt(MIN_EXP) },
    { "MIN_10_EXP", tnuminfo_floatatt(MIN_10_EXP) },
    { NULL, 0 } /* sentinel */
};

struct tagtnuminfo_lua_Number {
    const char *name;
    lua_Number value;
};

static struct tagtnuminfo_lua_Number tnuminfo_float_values[] = {
    { "EPSILON", tnuminfo_floatatt(EPSILON) },
    { "MAX", tnuminfo_floatatt(MAX) },
    { "MIN", tnuminfo_floatatt(MIN) },
    { NULL, tnuminfo_mathop(0.0) } /* sentinel */
};

static int tnuminfo_detect(lua_State *L) {
    int i;
    struct tagtnuminfo_lua_Integer *int_entry;
    struct tagtnuminfo_lua_Number *num_entry;
    lua_createtable(L, 0, 0);
    i = 0;
    while (tnuminfo_int_values[i].name != NULL) {
        int_entry = tnuminfo_int_values + i;
        lua_pushstring(L, int_entry->name);
        lua_pushinteger(L, int_entry->value);
        lua_settable(L, -3);
        i++;
    }
    i = 0;
    while (tnuminfo_float_values[i].name != NULL) {
        num_entry = tnuminfo_float_values + i;
        lua_pushstring(L, num_entry->name);
        lua_pushnumber(L, num_entry->value);
        lua_settable(L, -3);
        i++;
    }
    return 1;
}

LUA_API int luaopen_tnuminfo(lua_State *L) {
    lua_createtable(L, 0, 0);
    lua_pushstring(L, "detect");
    lua_pushcfunction(L, tnuminfo_detect);
    lua_settable(L, -3);
    return 1;
}