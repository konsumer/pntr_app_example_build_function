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