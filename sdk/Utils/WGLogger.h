//
//  WGLogger.h
//  WordGames
//
//  Created by Dmitry B on 17.01.16.
//
//

#import "WGAdConstants.h"

#define _AODLOGGER(s,...) NSLog( @"%@ \n<%@:%d>", [NSString stringWithFormat:(s), ##__VA_ARGS__], [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__)

#define AODLOG_INFO(s,...) NSLog( @"<%@>: %@", ADS_DESCR, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#if DEBUG

#if DEBUG_INFO
#define AODLOG(...) _AODLOGGER(__VA_ARGS__)
#else
#define AODLOG(...)
#endif

#if DEBUG_ERROR
#define AODLOG_ERROR(...) _AODLOGGER(__VA_ARGS__)
#else
#define AODLOG_ERROR(...)
#endif

#if DEBUG_FULL_BANNER
#define AODLOG_FULL_BANNER(...) _AODLOGGER(__VA_ARGS__)
#else
#define AODLOG_FULL_BANNER(...)
#endif

#if DEBUG_SMALL_BANNER
#define AODLOG_BANNER(...) _AODLOGGER(__VA_ARGS__)
#else
#define AODLOG_BANNER(...)
#endif

#if DEBUG_VIDEO
#define AODLOG_VIDEO(...) _AODLOGGER(__VA_ARGS__)
#else
#define AODLOG_VIDEO(...)
#endif

#if DEBUG_DEBUG
#define AODLOG_DEBUG(...) _AODLOGGER(__VA_ARGS__)
#else
#define AODLOG_DEBUG(...)
#endif

#else

#define AODLOG(...)
#define AODLOG_ERROR(...)
#define AODLOG_FULL_BANNER(...)
#define AODLOG_BANNER(...)
#define AODLOG_VIDEO(...)
#define AODLOG_DEBUG(...)

#endif
