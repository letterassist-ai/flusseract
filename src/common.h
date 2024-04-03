#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

#define BUFFER_SIZE 4096

// Macros to capture and log stdout and stderr to the logger.

#define BEGIN_STREAM_CAPTURE(stream_fd, pipe_fd, stream) \
  fflush(stream); \
  int stream_fd = dup(fileno(stream)); \
  int pipe_fd[2]; \
  pipe(pipe_fd); \
  dup2(pipe_fd[1], fileno(stream));

#define END_STREAM_CAPTURE(stream_fd, pipe_fd, stream, buffer, size) \
  fflush(stream); \
  dup2(stream_fd, fileno(stream)); \
  close(pipe_fd[1]); \
  { \
    ssize_t n = read(pipe_fd[0], buffer, size); \
    if (n > 0) { \
      buffer[n] = '\0'; \
    } else { \
      buffer[0] = '\0'; \
    } \
  } \
  close(pipe_fd[0]); \
  close(stream_fd);

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

#endif // COMMON_H