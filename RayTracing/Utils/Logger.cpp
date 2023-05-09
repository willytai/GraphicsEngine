//
//  Logger.cpp
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#include "Logger.hpp"
#include <iostream>

namespace log {

using std::cout;
using std::endl;

void print_float3(simd_float3 float3, const char* varname) {
    std::cout << varname << ": (";
    std::cout << ((float*)&float3)[0] << ", "
              << ((float*)&float3)[1] << ", "
              << ((float*)&float3)[2];
    std::cout << ")\n";

}

void print_float4(simd_float4 float4, const char* varname) {
    std::cout << varname << ": (";
    std::cout << ((float*)&float4)[0] << ", "
              << ((float*)&float4)[1] << ", "
              << ((float*)&float4)[2] << ", "
              << ((float*)&float4)[3];
    std::cout << ")\n";

}

}
