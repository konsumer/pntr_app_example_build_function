# this is an example project cmake
# normal user-project cmake stuff

cmake_minimum_required(VERSION 3.22)
project(myproject)
set(CMAKE_C_STANDARD 23)

if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
  set(CMAKE_POLICY_DEFAULT_CMP0135 NEW)
endif()

if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
  set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
endif()

# everyone wants to make an "uninstall" target
set_property(GLOBAL PROPERTY ALLOW_DUPLICATE_CUSTOM_TARGETS ON)

# enable colors for ninja
set(CMAKE_COLOR_DIAGNOSTICS ON)

# find cmake stuff in current dir/cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

# set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_BUILD_TYPE Release)

####

# this laods the helper
find_package(pntr REQUIRED)

# setup an example app
add_executable(${PROJECT_NAME} main.c)

# I like to put the output in webroot, and I use mjs, no shell
# this is sort of specific to user app, though, not a pntr_app thing
if (EMSCRITPEN)
  set_target_properties(${PROJECT_NAME}
    PROPERTIES
    SUFFIX ".mjs"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/docs"
  )
endif()

# use default (SDL/emscripten) window/sound
add_pntr(${PROJECT_NAME})

# other examples

# these are behind EMSCRIPTEN check, since they don't really make sense on non-native
# TODO: needs testing. would be cool to support RAYLIB/SDL web builds (if you wanted that for some reason)

# these are case-insensitive

if (NOT EMSCRIPTEN)
  # this will use sdl window/nosound
  # disabled because I have issues building on mac
  # add_executable(${PROJECT_NAME}_sdl main.c)
  # add_pntr(${PROJECT_NAME}_sdl SDL)

  # this will use raylib window/nosound
  add_executable(${PROJECT_NAME}_raylib main.c)
  add_pntr(${PROJECT_NAME}_raylib RAYLIB)

  # this will use libretro for window/sound
  add_library(${PROJECT_NAME}-libretro SHARED main.c)
  set_target_properties(${PROJECT_NAME}-libretro PROPERTIES PREFIX "") 
  add_pntr(${PROJECT_NAME}-libretro RETRO)

  # this will use raylib window/sound, but set drm option for raylib
  add_executable(${PROJECT_NAME}_raylib_drm main.c)
  add_pntr(${PROJECT_NAME}_raylib_drm RAYLIB_DRM)

  # this will use termbox for window, miniaudio for sound
  add_executable(${PROJECT_NAME}_cli_minisound main.c)
  add_pntr(${PROJECT_NAME}_cli_minisound TERMBOX MINIAUDIO)

  # this will use termbox default of no sound
  add_executable(${PROJECT_NAME}_cli main.c)
  add_pntr(${PROJECT_NAME}_cli TERMBOX)

  # this will build "ugly" CLI, with default of no sound
  add_executable(${PROJECT_NAME}_cli_ugly main.c)
  add_pntr(${PROJECT_NAME}_cli_ugly CLI)
endif()


