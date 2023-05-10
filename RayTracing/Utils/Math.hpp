//
//  Math.hpp
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#ifndef Math_hpp
#define Math_hpp

#include <simd/simd.h>

namespace mathutil {

/// types
simd_float3 float3(float x, float y, float z);
simd_float4 float4(float x, float y, float z, float w);

/// operations
simd_float4x4 matmul(simd_float4x4 x, simd_float4x4 y);

/// gometries
simd_float4x4 perspective(float fovDeg, float aspect, float nearClip, float farClip);
simd_float4x4 view(simd_float3 eye, simd_float3 center, simd_float3 up);
float length(simd_float3 float3);

}

#endif /* Math_hpp */
