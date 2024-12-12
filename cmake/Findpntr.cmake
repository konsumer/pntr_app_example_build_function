# setup different permutations of pntr/pntr_app and dependencies
# this file should be all a user needs to add pntr_app to their project

# this contains the main-override and basic window/input setup, like this is the "frame" of things
set(PNTR_APP_DEFAULT_WINDOW "SDL") 

# this contains the sound lib in most cases, this is tied to window lib, but sometimes not (like CLI)
set(PNTR_APP_DEFAULT_SOUND "SDL")

# download pntr & pntr_app

include(FetchContent)

FetchContent_Declare(fpntr
  URL https://github.com/robloach/pntr/archive/refs/heads/master.zip
)
FetchContent_MakeAvailable(fpntr)

# allow in-tree pntr_app (for demos in that repo)
# TODO: I might even be able to detect this somehow
option(USE_LOCAL_PNTR_APP "Force using the current directory as source of pntr_app" OFF)
if ($USE_LOCAL_PNTR_APP)
  set(fpntr_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}")
else()
  FetchContent_Declare(fpntr_app
    URL https://github.com/robloach/pntr_app/archive/refs/heads/master.zip
  )
  FetchContent_MakeAvailable(fpntr_app)
endif()

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
      elseif ("${a}" STREQUAL "TERMEX")
        set(PNTR_APP_WINDOW "TERMEX")
      elseif ("${a}" STREQUAL "MINIAUDIO")
        set(PNTR_APP_SOUND "MINIAUDIO")
      elseif ("${a}" STREQUAL "NO_SOUND")
        set(PNTR_APP_SOUND "NONE")
      endif()
    endforeach()
  else()
    set(display_args "DEFAULTS")
  endif()
  message("-- pntr_app added to ${target}: ${display_args}")

  # check for sensible defaults, like if you set SDL option, but not PNTR_APP_SOUND (it should be SDL_SOUND)
  # TODO: I probly need more of these
  if(NOT DEFINED PNTR_APP_SOUND)
    if ("${PNTR_APP_WINDOW}" STREQUAL "RAYLIB")
      set(PNTR_APP_SOUND "RAYLIB")
    endif()
    if ("${PNTR_APP_WINDOW}" STREQUAL "SDL")
      set(PNTR_APP_SOUND "SDL")
    endif()
    if ("${PNTR_APP_WINDOW}" STREQUAL "TERMEX")
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

  # TODO: add suffix for differnt options, like pntr_app_raylib_drm_raylib

  message("--   Window: ${PNTR_APP_WINDOW}")
  message("--   Sound: ${PNTR_APP_SOUND}")
  message("--   Lib Name: ${pntr_lib_name}")

  # TODO: download deps that are needed by window/sound and link to target
  # TODO: add defines so C code can see options selected
  # TODO: link target to pntr/pntr_app
endfunction()