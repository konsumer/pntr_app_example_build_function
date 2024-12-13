# setup different permutations of pntr/pntr_app and dependencies
# this file should be all a user needs to add pntr_app to their project

# this contains the main-override and basic window/input setup, like this is the "frame" of things
set(PNTR_APP_DEFAULT_WINDOW "SDL") 

# this contains the sound lib in most cases, this is tied to window lib, but sometimes not (like CLI)
set(PNTR_APP_DEFAULT_SOUND "SDL")

# global-option to allow in-tree pntr_app (for demos in that repo)
option(USE_LOCAL_PNTR_APP "Force using the current directory as source of pntr_app" OFF)

include(FetchContent)

# this will allow you to easily add pntr/pntr_app to your application
function(add_pntr target)
  # pull out all the arguments and turn it into PNTR_APP_WINDOW/PNTR_APP_SOUND
  if (${ARGC} GREATER 1)
    list(SUBLIST ARGV 1 -1 pntr_args)
    string(TOUPPER "${pntr_args}" pntr_args)
    list(JOIN pntr_args ", " display_args)
    foreach(a IN LISTS pntr_args)
      if ("${a}" STREQUAL "RAYLIB")
        set(PNTR_APP_WINDOW "RAYLIB")
      elseif ("${a}" STREQUAL "RAYLIB_SOUND")
        set(PNTR_APP_SOUND "RAYLIB")
      elseif ("${a}" STREQUAL "RAYLIB_OLDPI")
        set(PNTR_APP_WINDOW "RAYLIB")
        # TODO: add define for raylib build
      elseif ("${a}" STREQUAL "RAYLIB_DRM")
        set(PNTR_APP_WINDOW "RAYLIB")
        # TODO: add define for raylib build
      elseif ("${a}" STREQUAL "SDL")
        set(PNTR_APP_WINDOW "SDL")
      elseif ("${a}" STREQUAL "SDL")
        set(PNTR_APP_SOUND "SDL")
      elseif ("${a}" STREQUAL "RETRO")
        set(PNTR_APP_WINDOW "RETRO")
        set(PNTR_APP_SOUND "RETRO")
      elseif ("${a}" STREQUAL "CLI")
        set(PNTR_APP_WINDOW "CLI")
      elseif ("${a}" STREQUAL "TERMBOX")
        set(PNTR_APP_WINDOW "TERMBOX")
      elseif ("${a}" STREQUAL "MINIAUDIO")
        set(PNTR_APP_SOUND "MINIAUDIO")
      elseif ("${a}" STREQUAL "NO_SOUND")
        set(PNTR_APP_SOUND "NONE")
      elseif ("${a}" STREQUAL "NO_WINDOW")
        set(PNTR_APP_WINDOW "NONE")
      endif()
    endforeach()
  else()
    set(display_args "DEFAULTS")
  endif()
  message("-- pntr_app added to ${target}: ${display_args}")

  # check for sensible defaults, like if you set SDL option, but not PNTR_APP_SOUND (it should be SDL_SOUND)
  if(NOT DEFINED PNTR_APP_SOUND)
    if ("${PNTR_APP_WINDOW}" STREQUAL "RAYLIB")
      set(PNTR_APP_SOUND "RAYLIB")
    endif()
    if ("${PNTR_APP_WINDOW}" STREQUAL "SDL")
      set(PNTR_APP_SOUND "SDL")
    endif()
    if ("${PNTR_APP_WINDOW}" STREQUAL "TERMBOX")
      set(PNTR_APP_SOUND "NONE")
    endif()
    if ("${PNTR_APP_WINDOW}" STREQUAL "CLI")
      set(PNTR_APP_SOUND "NONE")
    endif()
  endif()
  
  if(NOT DEFINED PNTR_APP_WINDOW)
    if ("${PNTR_APP_SOUND}" STREQUAL "RAYLIB")
      set(PNTR_APP_WINDOW "RAYLIB")
    endif()
    if ("${PNTR_APP_SOUND}" STREQUAL "SDL")
      set(PNTR_APP_WINDOW "SDL")
    endif()
  endif()
  
  # set defaults
  if (NOT DEFINED PNTR_APP_WINDOW)
    if (EMSCRIPTEN)
      set(PNTR_APP_WINDOW "EMSCRIPTEN")
    else()
      set(PNTR_APP_WINDOW "${PNTR_APP_DEFAULT_WINDOW}")
    endif()
  endif()
  if (NOT DEFINED PNTR_APP_SOUND)
    if (EMSCRIPTEN)
      set(PNTR_APP_SOUND "EMSCRIPTEN")
    else()
      set(PNTR_APP_SOUND "${PNTR_APP_DEFAULT_SOUND}")
    endif()
  endif()

  # TODO: here I could check warn about unsupported/bad combos

  set(pntr_lib_name "pntr_app_${PNTR_APP_WINDOW}_${PNTR_APP_SOUND}")
  string(TOLOWER "${pntr_lib_name}" pntr_lib_name)

  # TODO: add suffix for different options, like pntr_app_raylib_drm_raylib

  message("--   PNTR_APP_WINDOW: ${PNTR_APP_WINDOW}")
  message("--   PNTR_APP_SOUND: ${PNTR_APP_SOUND}")
  message("--   Lib Name: ${pntr_lib_name}")
  message("--   Downloading dependencies.")

  # download deps that are needed by window/sound

  FetchContent_Declare(fpntr
    URL https://github.com/robloach/pntr/archive/refs/heads/master.zip
  )
  FetchContent_MakeAvailable(fpntr)

  if ($USE_LOCAL_PNTR_APP)
    set(fpntr_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}")
  else()
    FetchContent_Declare(fpntr_app
      URL https://github.com/robloach/pntr_app/archive/refs/heads/master.zip
    )
    FetchContent_MakeAvailable(fpntr_app)
  endif()

  # create a static library for all of pntr_app/pntr
  # add_library(${pntr_lib_name} STATIC "${fpntr_SOURCE_DIR}/pntr_app.c")
  if (NOT TARGET "${pntr_lib_name}")
    add_library("${pntr_lib_name}" STATIC "${CMAKE_CURRENT_LIST_DIR}/pntr_app.c")
  endif()
  target_link_libraries("${target}" "${pntr_lib_name}")

  # TODO: add defines so user's C code can see options selected

  if ("${PNTR_APP_SOUND}" STREQUAL "RAYLIB" OR "${PNTR_APP_WINDOW}" STREQUAL "RAYLIB")
    set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(BUILD_GAMES    OFF CACHE BOOL "" FORCE)
    # TODO: handle options like DRM, etc
    FetchContent_Declare(
      raylib
      URL https://github.com/raysan5/raylib/archive/refs/tags/5.5.tar.gz
    )
    FetchContent_MakeAvailable(raylib)
    target_link_libraries(${pntr_lib_name} raylib)
  endif()

  if ("${PNTR_APP_SOUND}" STREQUAL "SDL" OR "${PNTR_APP_WINDOW}" STREQUAL "SDL")
    # TODO: set tons of SDL options here
    FetchContent_Declare(
      sdl
      URL https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.30.10.tar.gz
    )
    FetchContent_MakeAvailable(sdl)
    # TODO: link to SDL here
  endif()

  if ("${PNTR_APP_WINDOW}" STREQUAL "TERMBOX")
    # TODO: actually link lib here
  endif()

  if ("${PNTR_APP_WINDOW}" STREQUAL "CLI")
    # TODO: actually link lib here
  endif()

  if ("${PNTR_APP_SOUND}" STREQUAL "MINIAUDIO")
    # TODO: actually link lib here
  endif()

  if ("${PNTR_APP_WINDOW}" STREQUAL "NONE")
    # TODO: set var here
  endif()

  if ("${PNTR_APP_SOUND}" STREQUAL "NONE")
    # TODO: set var here
  endif()

endfunction()