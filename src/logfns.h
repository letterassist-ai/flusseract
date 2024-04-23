#ifndef LOGFNS_H
#define LOGFNS_H

#ifdef __cplusplus
extern "C" {
#endif

void logMessage(const int, const char *, ...);
void logTrace(const char *, ...);
void logDebug(const char *, ...);
void logInfo(const char *, ...);
void logWarn(const char *, ...);
void logError(const char *, ...);

#ifdef __cplusplus
}
#endif /* extern "C" */

// Macros to log stdout and stderr to the flutter application logger.

#define CAPTURE_STD_STREAMS() \
  BEGIN_STREAM_CAPTURE(stdout_fd, stdout_pipe_fd, stdout); \
  BEGIN_STREAM_CAPTURE(stderr_fd, stderr_pipe_fd, stderr);

#define LOG_STD_STREAMS() \
  char stdout_buffer[BUFFER_SIZE]; \
  END_STREAM_CAPTURE(stdout_fd, stdout_pipe_fd, stdout, stdout_buffer, BUFFER_SIZE); \
  char stderr_buffer[BUFFER_SIZE]; \
  END_STREAM_CAPTURE(stderr_fd, stderr_pipe_fd, stderr, stderr_buffer, BUFFER_SIZE); \
  if (stdout_buffer[0] != 0) { \
    FOR_EACH_LINE_IN_STRING_DO(stdout_buffer, logInfo); \
  } \
  if (stderr_buffer[0] != 0) { \
    FOR_EACH_LINE_IN_STRING_DO(stderr_buffer, logError); \
  }

#define FOR_EACH_LINE_IN_STRING_DO(str, fn) \
  char* pch = strtok(str, "\n"); \
  while (pch != NULL) { \
    fn(pch); \
    pch = strtok(NULL, "\n"); \
  }

#endif // LOGFNS_H
