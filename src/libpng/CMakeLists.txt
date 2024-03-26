# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

include(ExternalProject)

# iOS device arm64 architecture
externalproject_add(libpng-iphoneos-arm64
  URL                        https://phoenixnap.dl.sourceforge.net/project/libpng/libpng16/1.6.43/libpng-1.6.43.tar.gz
  URL_HASH                   SHA256=e804e465d4b109b5ad285a8fb71f0dd3f74f0068f91ce3cdfde618180c174925
  DOWNLOAD_EXTRACT_TIMESTAMP true
  SOURCE_DIR                 ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR                 ${CMAKE_CURRENT_BINARY_DIR}/iphoneos-arm64/build
  INSTALL_DIR                ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos-arm64

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    iphoneos arm64 <SOURCE_DIR> <INSTALL_DIR>
)

# iOS simulator x86_64 architecture
externalproject_add(libpng-iphonesimulator-x86_64
  URL                        https://phoenixnap.dl.sourceforge.net/project/libpng/libpng16/1.6.43/libpng-1.6.43.tar.gz
  URL_HASH                   SHA256=e804e465d4b109b5ad285a8fb71f0dd3f74f0068f91ce3cdfde618180c174925
  DOWNLOAD_EXTRACT_TIMESTAMP true
  SOURCE_DIR                 ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR                 ${CMAKE_CURRENT_BINARY_DIR}/iphonesimulator-x86_64/build
  INSTALL_DIR                ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphonesimulator-x86_64

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    iphonesimulator x86_64 <SOURCE_DIR> <INSTALL_DIR>
)

# macOSX arm64 architecture
externalproject_add(libpng-macosx-arm64
  URL                        https://phoenixnap.dl.sourceforge.net/project/libpng/libpng16/1.6.43/libpng-1.6.43.tar.gz
  URL_HASH                   SHA256=e804e465d4b109b5ad285a8fb71f0dd3f74f0068f91ce3cdfde618180c174925
  DOWNLOAD_EXTRACT_TIMESTAMP true
  SOURCE_DIR                 ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR                 ${CMAKE_CURRENT_BINARY_DIR}/macosx-arm64/build
  INSTALL_DIR                ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-arm64

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    macosx arm64 <SOURCE_DIR> <INSTALL_DIR>
)

# macOSX x86_64 architecture
externalproject_add(libpng-macosx-x86_64
  URL                        https://phoenixnap.dl.sourceforge.net/project/libpng/libpng16/1.6.43/libpng-1.6.43.tar.gz
  URL_HASH                   SHA256=e804e465d4b109b5ad285a8fb71f0dd3f74f0068f91ce3cdfde618180c174925
  DOWNLOAD_EXTRACT_TIMESTAMP true
  SOURCE_DIR                 ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR                 ${CMAKE_CURRENT_BINARY_DIR}/macosx-x86_64/build
  INSTALL_DIR                ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-x86_64

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    macosx x86_64 <SOURCE_DIR> <INSTALL_DIR>
)

# Combined targets

add_custom_target(libpng-iphoneos
  COMMENT "Building library module for iOS devices and simulators"
  COMMAND make libpng-iphoneos-arm64 libpng-iphonesimulator-x86_64
)

add_custom_target(libpng-macosx
  COMMENT "Building single multi-arch library module for macOSX"
  COMMAND make libpng-macosx-arm64 libpng-macosx-x86_64
)
