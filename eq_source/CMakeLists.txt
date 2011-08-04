##
# Copyright (c) 2010-2011 Daniel Pfeifer, All rights reserved.
#
# This file is freely distributable without licensing fees and
# is provided without guarantee or warrantee expressed or implied.
# This file is -not- in the public domain.
##

cmake_minimum_required(VERSION 2.8.4 FATAL_ERROR)
project(EqLite)

find_package(Boost "1.47" COMPONENTS system NO_MODULE)
include("${Boost_USE_FILE}")

find_package(BISON  REQUIRED)
find_package(FLEX   REQUIRED) 
find_package(OpenGL REQUIRED) 
find_package(OpenMP REQUIRED)

list(APPEND CMAKE_CXX_FLAGS ${OpenMP_CXX_FLAGS})

include(admin.cmake)
include(base.cmake)
include(client.cmake)
include(fabric.cmake)
include(net.cmake)
include(server.cmake)

include_directories(
  ${EqLite_SOURCE_DIR}
  ${EqLite_SOURCE_DIR}/eq/server
  ${EqLite_BINARY_DIR}
  )

bison_target(PARSER eq/server/loader.y
  ${CMAKE_BINARY_DIR}/parser.cpp 
  COMPILE_FLAGS "-l -p eqLoader_"
  )

flex_target(LEXER eq/server/loader.l
  ${CMAKE_BINARY_DIR}/lexer.cpp
  )

add_flex_bison_dependency(LEXER PARSER)

add_definitions(
  -DEQ_RELEASE=1
  -DEQ_INSTALL_DIR="/usr/"
  -DEQ_BUILD_DIR="/usr/"
  -DEQ_CLIENT_SHARED
  -DEQUALIZER_SHARED
  -DEQUALIZER_DSO_NAME="${CMAKE_SHARED_LIBRARY_PREFIX}Equalizer${CMAKE_SHARED_LIBRARY_SUFFIX}"
  -DCOLLAGE_DSO_NAME="${CMAKE_SHARED_LIBRARY_PREFIX}Collage${CMAKE_SHARED_LIBRARY_SUFFIX}"
  )

add_library(Collage SHARED
  ${base_sources}
  ${net_sources}
  )
boost_link_libraries(Collage
  system
  )
target_link_libraries(Collage
  rt
  )

add_library(Equalizer SHARED
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
install(TARGETS EqServer
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

set(eq_libraries Collage Equalizer EqualizerAdmin EqualizerServer)
set_property(TARGET ${eq_libraries} PROPERTY DEBUG_POSTFIX "_d")

install(TARGETS ${eq_libraries} EXPORT Release
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

install(TARGETS ${eq_libraries} EXPORT Debug
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

install(EXPORT Release
  DESTINATION share/Equalizer
  FILE Equalizer.cmake
  CONFIGURATIONS Release
  COMPONENT develop
  )

install(EXPORT Debug
  DESTINATION share/Equalizer
  FILE Equalizer.cmake
  CONFIGURATIONS Debug
  COMPONENT develop
  )

install(FILES EqualizerConfig.cmake EqualizerConfigVersion.cmake
  DESTINATION share/Equalizer
  CONFIGURATIONS Release
  COMPONENT develop
  )

install(DIRECTORY co eq vmmlib
  DESTINATION include
  CONFIGURATIONS Release
  COMPONENT develop
  FILES_MATCHING REGEX "[.](hpp|ipp|h)$"
  )

install(DIRECTORY configs
  DESTINATION share/Equalizer
  COMPONENT runtime
  CONFIGURATIONS Release
  )

if(BOOST_DEBIAN_PACKAGES)
  add_custom_target(documentation)
endif(BOOST_DEBIAN_PACKAGES)
