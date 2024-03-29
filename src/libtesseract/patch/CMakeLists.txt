
#### flusseract - BEGIN PATCH to find libtiff private dependencies
find_package(ZLIB)
find_package(JPEG)

find_package(liblzma)
if(liblzma_FOUND)
  set(pkgs_private "${pkgs_private} liblzma")
else()
  if(STRICT_CONF)
    message(
      FATAL_ERROR
        "Could not find liblzma libs."
    )
  endif(STRICT_CONF)
endif(liblzma_FOUND)
find_package(ZSTD)
if(ZSTD_FOUND)
  set(pkgs_private "${pkgs_private} zstd")
else()
  if(STRICT_CONF)
    message(
      FATAL_ERROR
        "Could not find ZSTD libs."
    )
  endif(STRICT_CONF)
endif(ZSTD_FOUND)
find_package(CMath)
if(CMath_FOUND)
  set(pkgs_private "${pkgs_private} cmath")
else()
  if(STRICT_CONF)
    message(
      FATAL_ERROR
        "Could not find CMath libs."
    )
  endif(STRICT_CONF)
endif(CMath_FOUND)

# when cross-compiling force the result to 0 as test can't be run
set(LEPT_TIFF_RESULT "0" CACHE STRING "0" FORCE)

#### flusseract - END PATCH to find libtiff private dependencies
