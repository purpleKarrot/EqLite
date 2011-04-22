##
# Copyright (c) 2010-2011 Daniel Pfeifer, All rights reserved.
#
# This file is freely distributable without licensing fees and
# is provided without guarantee or warrantee expressed or implied.
# This file is -not- in the public domain.
##

cmake_minimum_required(VERSION 2.8.4 FATAL_ERROR)
project(EqLite)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake)

set(EQ_SOURCE_DIR ${CMAKE_BINARY_DIR}/eq_source)
set(EQ_BINARY_DIR ${CMAKE_BINARY_DIR}/eq_binary)

set(upstream_dir "${CMAKE_SOURCE_DIR}/../Equalizer")
get_filename_component(upstream_dir "${upstream_dir}" ABSOLUTE)

file(COPY "${upstream_dir}/libs/"
  DESTINATION "${EQ_SOURCE_DIR}"
  FILES_MATCHING REGEX "[.](cpp|h|ipp|l|y)$"
  )

file(COPY eq_source/
  DESTINATION "${EQ_SOURCE_DIR}"
  )

set(EQUALIZER_BUILD_TESTS OFF CACHE INTERNAL "" FORCE)

add_subdirectory("${upstream_dir}" ${CMAKE_BINARY_DIR}/Equalizer
  EXCLUDE_FROM_ALL
  )

file(COPY "${CMAKE_BINARY_DIR}/Equalizer/include/vmmlib/"
  DESTINATION "${EQ_SOURCE_DIR}/vmmlib"
  FILES_MATCHING REGEX "[.]hpp$"
  )

file(COPY "${upstream_dir}/examples/configs/"
  DESTINATION "${EQ_SOURCE_DIR}/configs"
  FILES_MATCHING REGEX "[.]eqc$"
  )

file(READ "${upstream_dir}/tools/server/eqServer.cpp" server_src)
string(REPLACE "../../libs/" "" server_src "${server_src}")
file(WRITE "${EQ_SOURCE_DIR}/eqServer.cpp" "${server_src}")

set(CPACK_SOURCE_INSTALLED_DIRECTORIES "${EQ_SOURCE_DIR};/")
add_subdirectory("${EQ_SOURCE_DIR}" "${EQ_BINARY_DIR}")
