##
# Copyright (c) 2010-2011 Daniel Pfeifer, All rights reserved.
#
# This file is freely distributable without licensing fees and
# is provided without guarantee or warrantee expressed or implied.
# This file is -not- in the public domain.
##

include(CMakeParseArguments)

function(purple_add_library name)
  cmake_parse_arguments(LIB
    "FORWARD"
    "HEADERS_PREFIX"
    "HEADERS;SOURCES;LINK_LIBRARIES;PRECOMPILE_HEADERS"
    ${ARGN}
    )

  set(defines_dir ${CMAKE_BINARY_DIR}/Equalizer/include/${LIB_HEADERS_PREFIX})
  set(defines_file definesLinux.h)

  if(name STREQUAL "co_base")
    set(lib_name "base")
    configure_file("${defines_dir}${defines_file}"
      "${EQ_SOURCE_DIR}/collage/base/${defines_file}" COPYONLY)
    list(APPEND LIB_HEADERS ${defines_file})
  elseif(name STREQUAL "co")
    set(lib_name "net")
  elseif(name STREQUAL "eq_fabric")
    set(lib_name "fabric")
  elseif(name STREQUAL "eq_client")
    set(lib_name "client")
    configure_file("${defines_dir}version.h"
      "${EQ_SOURCE_DIR}/client/version.h" COPYONLY)
    configure_file("${defines_dir}${defines_file}"
      "${EQ_SOURCE_DIR}/client/${defines_file}" COPYONLY)
    file(WRITE "${EQ_SOURCE_DIR}/client/GL/glew.h"
      "#include <GL/glew.h>\n"
      )
    file(WRITE "${EQ_SOURCE_DIR}/client/GL/glxew.h"
      "#include <GL/glxew.h>\n"
      )
    list(APPEND LIB_HEADERS
      ${defines_file}
      version.h
      GL/glew.h
      GL/glxew.h
      )
  elseif(name STREQUAL "EqualizerAdmin")
    set(lib_name "admin")
  elseif(name STREQUAL "EqualizerServer")
    set(lib_name "server")
  else()
    message(FATAL_ERROR "Equalizer has a new library: ${name}")
  endif()

  set(listfile "${EQ_SOURCE_DIR}/${lib_name}.cmake")

  file(WRITE "${listfile}"
    "#copyright\n\n"
    )

  if(lib_name STREQUAL "base" OR lib_name STREQUAL "client")
  endif(lib_name STREQUAL "base" OR lib_name STREQUAL "client")

  if(LIB_HEADERS)
    list(SORT LIB_HEADERS)
    set(headers)
    foreach(file ${LIB_HEADERS})
      get_filename_component(absolute "${file}" ABSOLUTE)
      file(RELATIVE_PATH file "${upstream_dir}/libs" "${absolute}")
      set(headers "${headers}\n  ${file}")
    endforeach(file)
    file(APPEND "${listfile}"
      "set(${lib_name}_headers${headers}\n  )\n"
      )
  endif(LIB_HEADERS)

  if(LIB_SOURCES)
    list(SORT LIB_SOURCES)
    set(sources)
    foreach(file ${LIB_SOURCES})
      get_filename_component(absolute "${file}" ABSOLUTE)
      if(EXISTS "${absolute}")
        file(RELATIVE_PATH file "${upstream_dir}/libs" "${absolute}")
        set(sources "${sources}\n  ${file}")
      endif(EXISTS "${absolute}")
    endforeach(file)
    file(APPEND "${listfile}"
      "set(${lib_name}_sources${sources}\n  )\n"
      )
  endif(LIB_SOURCES)

  add_custom_target(lib_${name}_shared)
endfunction(purple_add_library)
