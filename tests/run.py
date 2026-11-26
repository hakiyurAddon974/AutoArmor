#!/usr/bin/env python3
"""Run the add-on's deterministic Lua tests using the system Lua 5.4 library."""
import ctypes as c
import pathlib
import sys
root = pathlib.Path(__file__).resolve().parents[1]
addon_dir = root/'AutoArmor' if (root/'AutoArmor'/'AutoArmor.toc').is_file() else root
lib = c.CDLL('liblua5.4.so.0')
lib.luaL_newstate.restype = c.c_void_p
lib.luaL_openlibs.argtypes = [c.c_void_p]
lib.luaL_loadfilex.argtypes = [c.c_void_p, c.c_char_p, c.c_char_p]
lib.luaL_loadstring.argtypes = [c.c_void_p, c.c_char_p]
lib.lua_pcallk.argtypes = [c.c_void_p, c.c_int, c.c_int, c.c_int, c.c_ssize_t, c.c_void_p]
lib.lua_tolstring.argtypes = [c.c_void_p, c.c_int, c.POINTER(c.c_size_t)]
lib.lua_tolstring.restype = c.c_char_p
lib.lua_settop.argtypes = [c.c_void_p, c.c_int]
lib.lua_close.argtypes = [c.c_void_p]
state = lib.luaL_newstate()
lib.luaL_openlibs(state)
def check(code):
    if code:
        print(lib.lua_tolstring(state, -1, None).decode(), file=sys.stderr)
        sys.exit(1)
files = sorted(addon_dir.glob('*.lua'))
for file in files:
    check(lib.luaL_loadfilex(state, str(file).encode(), None))
    lib.lua_settop(state, 0)
print(f'Syntax: {len(files)} Lua files passed', flush=True)
check(lib.luaL_loadstring(state, ('ADDON_PATH = '+repr(str(addon_dir))).encode()))
check(lib.lua_pcallk(state, 0, 0, 0, 0, None))
if '--syntax-only' not in sys.argv:
    check(lib.luaL_loadfilex(state, str(root/'tests'/'regression.lua').encode(), None))
    check(lib.lua_pcallk(state, 0, 0, 0, 0, None))
lib.lua_close(state)
