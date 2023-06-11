//
//  Logger.hpp
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#ifndef Logger_hpp
#define Logger_hpp

#include <simd/simd.h>
#include <cassert>

#define PRINT_FUNC_NAME NSLog(@"%s called", __PRETTY_FUNCTION__)
#define NS_NOT_IMPLEMENTED_ERROR NSAssert(false, @"Not Implemented: %s @ %s:%d", __PRETTY_FUNCTION__, __FILE__, __LINE__)
#define NOT_IMPLEMENTED_ERROR NS_NOT_IMPLEMENTED_ERROR
#define CPP_NOT_IMPLEMENTED_ERROR printf("Not Implemented: %s @ %s:%d\n", __PRETTY_FUNCTION__, __FILE__, __LINE__); assert(false);

namespace log {

void print_float2(simd_float2 float2, const char* varname = "", const char* del = "\n");
void print_float3(simd_float3 float3, const char* varname = "", const char* del = "\n");
void print_float4(simd_float4 float4, const char* varname = "", const char* del = "\n");
void print_matrix4x4(simd_float4x4 mat4x4, const char* varname = "", const char* del = "\n");

}

#endif /* Logger_hpp */
