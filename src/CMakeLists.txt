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

# External libraries and builds
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libzstd)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libjpeg)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libpng)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libtiff)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libleptonica)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/libtesseract)

# Source files
file(GLOB C_SRCS   ${CMAKE_CURRENT_SOURCE_DIR}/*.c)
file(GLOB CXX_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)

# Flusseract library build
add_library(${LIB} SHARED ${C_SRCS} ${CXX_SRCS})
add_compile_options(-Wno-unused-result)

# # Tesseract library build
if(DEFINED ANDROID_ABI)
  # Android builds using the NDK
  set(TARGET_TYPE "android-${ANDROID_ABI}")
  message(STATUS "Building for Android using NDK toolchain - ${TARGET_TYPE}")
  
elseif(DEFINED ENV{PLATFORM_NAME})
  # Apple builds using the Swift toolchain
  set(TARGET_TYPE "$ENV{PLATFORM_NAME}")
  message(STATUS "Building for Apple Darwin using the Swift toolchain - ${TARGET_TYPE}")
  
else()

  if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(LIB_SEARCH_PATHS "/usr/local/lib;/opt/homebrew/lib")
    set(INCLUDE_PATHS "/usr/local/include;/opt/homebrew/include")
  else()
    set(LIB_SEARCH_PATHS "/usr/local/lib")
    set(INCLUDE_PATHS "/usr/local/include")
  endif()

  # Find the leptonica library
  find_library(LEPTONICA_LIBRARY
    NAMES leptonica
    PATHS ${LIB_SEARCH_PATHS})
  # Find the tesseract library
  find_library(TESSERACT_LIBRARY
    NAMES tesseract
    PATHS ${LIB_SEARCH_PATHS})

  target_link_libraries(${LIB} ${LEPTONICA_LIBRARY} ${TESSERACT_LIBRARY})
  target_include_directories(${LIB} PUBLIC ${INCLUDE_PATHS})
endif()

if(DEFINED TARGET_TYPE)
  
  # Android NDK does not have liblzma. So skip 
  # it as other libraries will be built without 
  # it and so we do not need to link it.
  if(NOT DEFINED ANDROID_ABI)  
    find_package(LibLZMA)
    if(NOT LIBLZMA_FOUND)
      message(FATAL_ERROR "liblzma not found")
    endif()
    message(STATUS "LIBLZMA_FOUND: ${LIBLZMA_FOUND} - ${LIBLZMA_LIBRARIES}")
  endif()

  find_package(ZLIB)
  if(NOT ZLIB_FOUND)
    message(FATAL_ERROR "zlib not found")
  endif()
  message(STATUS "ZLIB_FOUND: ${ZLIB_FOUND} - ${ZLIB_LIBRARIES}")

  # Library dependencies
  add_static_library_dependency(libzstd ${TARGET_TYPE})
  add_static_library_dependency(libjpeg ${TARGET_TYPE})
  add_static_library_dependency(libpng ${TARGET_TYPE})
  add_static_library_dependency(libtiff ${TARGET_TYPE})
  add_static_library_dependency(libleptonica ${TARGET_TYPE})
  add_static_library_dependency(libtesseract ${TARGET_TYPE})

  target_link_libraries(${LIB} 
    ${LIBLZMA_LIBRARIES}
    ${ZLIB_LIBRARIES}
    libzstd
    libjpeg
    libpng
    libtiff
    libleptonica
    libtesseract
  )

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
