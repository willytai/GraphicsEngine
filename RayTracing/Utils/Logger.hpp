//
//  Logger.hpp
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#ifndef Logger_hpp
#define Logger_hpp

#include <simd/simd.h>

namespace log {

void print_float3(simd_float3 float3, const char* varname = "");
void print_float4(simd_float4 float4, const char* varname = "");

}

#endif /* Logger_hpp */