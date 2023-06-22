//
//  Logger.h
//  RayTracing
//
//  Created by Willy Tai on 6/15/23.
//

#ifndef Logger_h
#define Logger_h

#import <OSLog/OSLog.h>

static os_log_t LOGGER = nil;

#define GEN_CLASS_LOGGER(subsystem, category) \
- (os_log_t)getLogger \
{ \
    if (LOGGER == nil) { \
        LOGGER = os_log_create(subsystem, category); \
    } \
    return LOGGER; \
}

#define LOG_INFO(format, ...)  os_log_info([self getLogger], format, ##__VA_ARGS__)
#define LOG_ERROR(format, ...) os_log_error([self getLogger], format, ##__VA_ARGS__)
#define LOG_DEBUG(format, ...) os_log_debug([self getLogger], format, ##__VA_ARGS__)


#endif /* Logger_h */
