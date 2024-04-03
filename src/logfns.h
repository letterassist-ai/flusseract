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

#endif // LOGFNS_H
