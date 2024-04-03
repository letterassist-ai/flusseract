#include <stdarg.h>

#include "logger.h"

/// Log levels as defined by the dart logging package (level.dart).

/// Key for highly detailed tracing ([value] = 300).
#define LOG_LEVEL_FINEST 1
/// Key for fairly detailed tracing ([value] = 400).
#define LOG_LEVEL_FINER 2
/// Key for tracing information ([value] = 500).
#define LOG_LEVEL_FINE 3
/// Key for static configuration messages ([value] = 700).
#define LOG_LEVEL_CONFIG 4
/// Key for informational messages ([value] = 800).
#define LOG_LEVEL_INFO 5
/// Key for potential problems ([value] = 900).
#define LOG_LEVEL_WARNING 6
/// Key for serious failures ([value] = 1000).
#define LOG_LEVEL_SEVERE 7
/// Key for extra debugging loudness ([value] = 1200).
#define LOG_LEVEL_SHOUT 8

logger_t *_logger;

void setLogger(logger_t *logger) {
    _logger = logger;
}

void logFormattedMessage(const int level, const char *format, va_list args) {
    char buffer[BUFFER_SIZE];
    vsnprintf(buffer, BUFFER_SIZE, format, args);

    if (_logger == NULL) {
        if (level > LOG_LEVEL_WARNING) {
            fprintf(stderr, "%s\n", buffer);
        } else {
            fprintf(stdout, "%s\n", buffer);
        }

    } else {
        _logger->log(_logger->context, level, buffer);
    }
}

void logMessage(const int level, const char *format, ...) {
    va_list args;
    va_start(args, format);
    logFormattedMessage(level, format, args);
    va_end(args);
}

void logTrace(const char *format, ...) {
    va_list args;
    va_start(args, format);
    logFormattedMessage(LOG_LEVEL_FINEST, format, args);
    va_end(args);
}

void logDebug(const char *format, ...) {
    va_list args;
    va_start(args, format);
    logFormattedMessage(LOG_LEVEL_FINE, format, args);
    va_end(args);
}

void logInfo(const char *format, ...) {
    va_list args;
    va_start(args, format);
    logFormattedMessage(LOG_LEVEL_INFO, format, args);
    va_end(args);
}

void logWarn(const char *format, ...) {
    va_list args;
    va_start(args, format);
    logFormattedMessage(LOG_LEVEL_WARNING, format, args);
    va_end(args);
}

void logError(const char *format, ...) {
    va_list args;
    va_start(args, format);
    logFormattedMessage(LOG_LEVEL_SEVERE, format, args);
    va_end(args);
}
