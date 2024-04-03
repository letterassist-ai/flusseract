#include "common.h"

#ifndef LOGGER_H
#define LOGGER_H

#ifdef __cplusplus
extern "C" {
#endif

// Client interface for logging 
// messages from C/C++ code

typedef void (*log_t)(const int64_t, const int, const char *s);

typedef struct {
  int64_t context;
  log_t log;
} logger_t;

// Set the logger to be used by the library
FFI_PLUGIN_EXPORT void setLogger(logger_t *);

#ifdef __cplusplus
}
#endif /* extern "C" */

#endif // LOGGER_H
