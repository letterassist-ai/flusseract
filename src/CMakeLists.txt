# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(ExternalProject)
include(BuildFunctions)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(LIB flusseract)
project(${LIB}_library LANGUAGES C CXX)

get_filename_component(ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.. ABSOLUTE)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libzstd)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libjpeg)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libpng)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libtiff)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/leptonica)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/tesseract)

file(GLOB C_SRCS   ${CMAKE_CURRENT_SOURCE_DIR}/*.c)
file(GLOB CXX_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)

add_library(${LIB} SHARED ${C_SRCS} ${CXX_SRCS})
add_compile_options(-Wno-unused-result)

if(DEFINED ENV{SWIFT_PLATFORM_TARGET_PREFIX})
  # Apple builds using the Swift toolchain

  # The install location for homebrew packages on Apple environments
  set(APPLEOS_BREW_PREFIX /opt/homebrew)

  # Find the leptonica library
  find_library(LEPTONICA_LIBRARY
    NAMES leptonica
    PATHS /opt/homebrew/lib /usr/local/lib)

  # Find the tesseract library
  find_library(TESSERACT_LIBRARY
    NAMES tesseract
    PATHS /opt/homebrew/lib /usr/local/lib)

  target_include_directories(${LIB} PUBLIC /usr/local/include ${APPLEOS_BREW_PREFIX}/include)
  target_link_libraries(${LIB} ${LEPTONICA_LIBRARY} ${TESSERACT_LIBRARY})

elseif(DEFINED ANDROID_ABI)
  # Android builds using the NDK
else()
  # Multi-platform go build for platforms other than Apple and Android
endif()

if(DEFINED ANDROID_ABI)
  set(SHARED_LIB_NAME lib${LIB}.so)
else()
  # Ensure all symbols are included in the final linked library
  if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    target_link_options(${LIB} PRIVATE "-Wl,-all_load")
    set(SHARED_LIB_NAME lib${LIB}.dylib)
  else()
    target_link_options(${LIB} PRIVATE "-Wl,--whole-archive")
    set(SHARED_LIB_NAME lib${LIB}.so)
  endif()
endif()

target_compile_definitions(${LIB} PUBLIC DART_SHARED_LIB)

set_target_properties(${LIB} PROPERTIES
  PUBLIC_HEADER ${LIB}.h
  OUTPUT_NAME ${LIB}
)

add_custom_target(test
  DEPENDS ${LIB}
  WORKING_DIRECTORY ${ROOT_DIR}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${ROOT_DIR}/${LIB}.framework
  COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/${SHARED_LIB_NAME} ${ROOT_DIR}/${LIB}.framework/${LIB}
  COMMAND flutter test ${ROOT_DIR}/test
  COMMENT "Running ${LIB} plugin tests"
)
