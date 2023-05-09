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

simd_float4x4 matmul(simd_float4x4 x, simd_float4x4 y);

simd_float4x4 perspective(float fovDeg, float aspect, float nearClip, float farClip);
simd_float4x4 view(simd_float3 eye, simd_float3 center, simd_float3 up);

}

#endif /* Math_hpp */
