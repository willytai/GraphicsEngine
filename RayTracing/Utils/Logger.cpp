//
//  Logger.cpp
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#include <iostream>
#include <stdio.h>
#include "Logger.hpp"

namespace log {

void print_float2(simd_float2 float2, const char* varname, const char* del) {
    std::cout << varname << ": (";
    std::cout << ((float*)&float2)[0] << ", "
              << ((float*)&float2)[1] << ")";
    std::cout << del;

}

void print_float3(simd_float3 float3, const char* varname, const char* del) {
    std::cout << varname << ": (";
    std::cout << ((float*)&float3)[0] << ", "
              << ((float*)&float3)[1] << ", "
              << ((float*)&float3)[2] << ")";
    std::cout << del;

}

void print_float4(simd_float4 float4, const char* varname, const char* del) {
    std::cout << varname << ": (";
    std::cout << ((float*)&float4)[0] << ", "
              << ((float*)&float4)[1] << ", "
              << ((float*)&float4)[2] << ", "
              << ((float*)&float4)[3] << ")";
    std::cout << del;

}

void print_matrix4x4(simd_float4x4 mat4x4, const char* varname = "", const char* del = "\n") {
    const float* data = (float*)&mat4x4;
    printf("%s:\n", varname);
    printf("[[%.2f, %.2f, %.2f, %.2f]]\n", data[4*0+0], data[4*1+0], data[4*2+0], data[4*3+0]);
    printf("[[%.2f, %.2f, %.2f, %.2f]]\n", data[4*0+1], data[4*1+1], data[4*2+1], data[4*3+1]);
    printf("[[%.2f, %.2f, %.2f, %.2f]]\n", data[4*0+2], data[4*1+2], data[4*2+2], data[4*3+2]);
    printf("[[%.2f, %.2f, %.2f, %.2f]]\n", data[4*0+3], data[4*1+3], data[4*2+3], data[4*3+3]);
}

}
