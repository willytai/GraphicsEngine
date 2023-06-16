//
//  Logger.h
//  RayTracing
//
//  Created by Willy Tai on 6/15/23.
//

#ifndef Logger_h
#define Logger_h

#import <OSLog/OSLog.h>

#define LOG_INFO(logger, format, ...)  os_log_info(logger, format, ##__VA_ARGS__)
#define LOG_ERROR(logger, format, ...) os_log_error(logger, format, ##__VA_ARGS__)
#define LOG_DEBUG(logger, format, ...) os_log_debug(logger, format, ##__VA_ARGS__)


#endif /* Logger_h */
