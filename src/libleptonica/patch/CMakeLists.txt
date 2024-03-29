
#### flusseract - BEGIN PATCH to find libtiff private dependencies
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
#### flusseract - END PATCH to find libtiff private dependencies
