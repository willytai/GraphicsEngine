//
//  Logger.m
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#include <stdio.h>
#include "Logger.h"


void print_float2(simd_float2 float2) {
    printf("(%.4f, %.4f)\n", ((float*)&float2)[0], ((float*)&float2)[1]);
}

void print_float3(simd_float3 float3) {
    printf("(%.4f, %.4f, %.4f)\n", ((float*)&float3)[0], ((float*)&float3)[1], ((float*)&float3)[2]);
}

void print_float4(simd_float4 float4) {
    printf("(%.4f, %.4f, %.4f, %.4f)\n", ((float*)&float4)[0], ((float*)&float4)[1], ((float*)&float4)[2], ((float*)&float4)[3]);
}

void print_matrix4x4(simd_float4x4 mat4x4) {
    const float* data = (float*)&mat4x4;
    printf("[[%.2f, %.2f, %.2f, %.2f] \n", data[4*0+0], data[4*1+0], data[4*2+0], data[4*3+0]);
    printf(" [%.2f, %.2f, %.2f, %.2f] \n", data[4*0+1], data[4*1+1], data[4*2+1], data[4*3+1]);
    printf(" [%.2f, %.2f, %.2f, %.2f] \n", data[4*0+2], data[4*1+2], data[4*2+2], data[4*3+2]);
    printf(" [%.2f, %.2f, %.2f, %.2f]]\n", data[4*0+3], data[4*1+3], data[4*2+3], data[4*3+3]);
}
