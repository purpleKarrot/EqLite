##
# Copyright (c) 2010-2011 Daniel Pfeifer, All rights reserved.
#
# This file is freely distributable without licensing fees and
# is provided without guarantee or warrantee expressed or implied.
# This file is -not- in the public domain.
##

cmake_minimum_required(VERSION 2.8.4 FATAL_ERROR)
project(EqLite)

find_package(Boost "1.46" COMPONENTS system NO_MODULE)
include("${Boost_USE_FILE}")
include(BoostForwardFile)

function(eq_add_headers)
  cmake_parse_arguments(HDR "" "PREFIX" "" ${ARGN})

  if(HDR_PREFIX MATCHES "^!(.*)!(.*)!$")
    get_filename_component(rootdir "${CMAKE_MATCH_1}" ABSOLUTE)
    set(prefix "${CMAKE_MATCH_2}")
  else()
    set(rootdir "${CMAKE_CURRENT_SOURCE_DIR}")
    set(prefix "${HDR_PREFIX}")
  endif()

  foreach(header ${HDR_UNPARSED_ARGUMENTS})
    get_filename_component(absolute "${header}" ABSOLUTE)
    file(RELATIVE_PATH relative "${rootdir}" "${absolute}")
    boost_forward("${absolute}"
      "${CMAKE_BINARY_DIR}/include/${prefix}/${relative}")

    # install definition
    string(REGEX MATCH "(.*)[/\\]" directory "${relative}")
    install(FILES ${header}
      DESTINATION "include/${prefix}/${directory}"
      COMPONENT develop
      CONFIGURATIONS "Release"
      )
  endforeach(header)
endfunction(eq_add_headers)

function(eq_add_library name)
  add_library(${name} ${ARGN})
  set_target_properties(${name} PROPERTIES
    COMPILE_DEFINITIONS "EQ_DSO_NAME=\"${CMAKE_SHARED_LIBRARY_PREFIX}${name}${CMAKE_SHARED_LIBRARY_SUFFIX}\""
    )
endfunction(eq_add_library)

find_package(BISON  REQUIRED)
find_package(FLEX   REQUIRED) 
find_package(OpenGL REQUIRED) 

include(admin.cmake)
include(base.cmake)
include(client.cmake)
include(fabric.cmake)
include(net.cmake)
include(server.cmake)

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/server
  ${CMAKE_BINARY_DIR}/include
  )

bison_target(PARSER server/loader.y
  ${CMAKE_BINARY_DIR}/parser.cpp 
  COMPILE_FLAGS "-l -p eqLoader_"
  )

flex_target(LEXER server/loader.l
  ${CMAKE_BINARY_DIR}/lexer.cpp
  )

add_flex_bison_dependency(LEXER PARSER)

eq_add_headers(PREFIX "!collage!co!"
  ${base_headers}
  ${net_headers}
  )

eq_add_headers(PREFIX "eq"
  ${admin_headers}
  ${fabric_headers}
  )

eq_add_headers(PREFIX "!client!eq!"
  ${client_headers}
  )

file(GLOB vmmlib_headers vmmlib/*.hpp)
eq_add_headers(${vmmlib_headers})

add_definitions(
  -DEQ_RELEASE=1
  -DEQ_INSTALL_DIR="/usr/"
  -DEQ_BUILD_DIR="/usr/"
  -DEQ_CLIENT_SHARED
  )

eq_add_library(Collage SHARED
  ${base_sources}
  ${net_sources}
  )
boost_link_libraries(Collage
  system
  )
target_link_libraries(Collage
  rt
  )

eq_add_library(Equalizer SHARED
  ${fabric_sources}
  ${client_sources}
  )
target_link_libraries(Equalizer
  ${OPENGL_LIBRARIES} GLEWmx
  Collage
  )

add_library(EqualizerAdmin SHARED
  ${admin_sources}
  )

add_library(EqualizerServer SHARED
  ${BISON_PARSER_OUTPUTS}
  ${FLEX_LEXER_OUTPUTS}
  ${server_sources}
  )
target_link_libraries(EqualizerServer
  Equalizer
  )

add_executable(EqServer
  eqServer.cpp
  )
target_link_libraries(EqServer
  EqualizerServer
  )

install(TARGETS Collage Equalizer EqualizerAdmin EqualizerServer EqServer
  ARCHIVE
    DESTINATION lib
    COMPONENT develop
    CONFIGURATIONS Release
  LIBRARY
    DESTINATION lib
    COMPONENT runtime
    CONFIGURATIONS Release
  RUNTIME
    DESTINATION bin
    COMPONENT runtime
    CONFIGURATIONS Release
  )

install(TARGETS Collage Equalizer EqualizerAdmin EqualizerServer
  ARCHIVE
    DESTINATION lib
    COMPONENT debug
    CONFIGURATIONS Debug
  LIBRARY
    DESTINATION lib
    COMPONENT debug
    CONFIGURATIONS Debug
  RUNTIME
    DESTINATION bin
    COMPONENT debug
    CONFIGURATIONS Debug
  )

install(DIRECTORY configs
  DESTINATION share/Equalizer
  COMPONENT runtime
  CONFIGURATIONS Release
  )

if(BOOST_DEBIAN_PACKAGES)
  add_custom_target(documentation)
endif(BOOST_DEBIAN_PACKAGES)
