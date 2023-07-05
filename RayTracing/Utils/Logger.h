//
//  Logger.h
//  RayTracing
//
//  Created by Willy Tai on 6/15/23.
//

#ifndef Logger_h
#define Logger_h

#import <OSLog/OSLog.h>
#import <simd/simd.h>
#include <stdlib.h>

static os_log_t LOGGER = nil;

#define GEN_CLASS_LOGGER(subsystem, category) \
- (os_log_t)getLogger \
{ \
    if (LOGGER == nil) { \
        LOGGER = os_log_create(subsystem, category); \
    } \
    return LOGGER; \
}

#define LOG_INFO(format, ...)   os_log_info([self getLogger], format, ##__VA_ARGS__)
#define LOG_ERROR(format, ...)  os_log_error([self getLogger], format, ##__VA_ARGS__)
#define LOG_DEBUG(format, ...)  os_log_debug([self getLogger], format, ##__VA_ARGS__)

#define PRINT_FUNC_NAME         LOG_DEBUG("%s called", __PRETTY_FUNCTION__)
#define NOT_IMPLEMENTED_ERROR   LOG_ERROR("Not Implemented: %s @ %s:%d", __PRETTY_FUNCTION__, __FILE__, __LINE__); \
                                assert(false)

void print_float2(simd_float2 float2);
void print_float3(simd_float3 float3);
void print_float4(simd_float4 float4);
void print_matrix4x4(simd_float4x4 mat4x4);

#endif /* Logger_h */
