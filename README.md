This is some ideas around simplifying build.

See [cmake](CMakeLists.txt) for how it works.

```
# test navie config
cmake -B build -G Ninja

# build native
cmake --build build


# test web config
emcmake cmake -B wbuild -G Ninja

# build web
cmake --build wbuild
```

I am still working on linking all the deps/vars, so you might not get functional builds from all the examples.


The script will attempt to use installed deps, if available, and that is recommended if it's an option. For example, on mac:


```
brew install sdl2 sdl2_image sdl2_mixer raylib
```

pntr_app.c should be in pntr_app repo. It's just a small entrypoint for static-lib.