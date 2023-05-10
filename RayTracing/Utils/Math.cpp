//
//  Math.cpp
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#include "Math.hpp"
#include "Logger.hpp"


namespace mathutil {

#pragma mark Types

simd_float3 float3(float x, float y, float z) {
    return simd_make_float3(x, y, z);
}

simd_float4 float4(float x, float y, float z, float w) {
    return simd_make_float4(x, y, z, w);
}

#pragma mark Operations

simd_float4x4 matmul(simd_float4x4 x, simd_float4x4 y) {
    return simd_mul(x, y);
}

#pragma mark Geometries

simd_float4x4 perspective(float fovDeg, float aspect, float nearClip, float farClip) {
    float fovRad = fovDeg / 180.0f * M_PI;
    float ys = 1.0f / tanf(fovRad * 0.5f);
    float xs = ys / aspect;
    float zs = farClip / (nearClip - farClip);

    return (simd_float4x4) {{
        {  xs,  0.0f,           0.0f,   0.0f},
        {0.0f,    ys,           0.0f,   0.0f},
        {0.0f,  0.0f,             zs,  -1.0f},
        {0.0f,  0.0f,  nearClip * zs,   0.0f},
    }};
}

simd_float4x4 view(simd_float3 eye, simd_float3 center, simd_float3 up) {
    /// In our coordinate system, the positive z direction points toward the view pane.
    /// It seems that in the simd coordinate system, positive z points to the opposite direction,
    /// so the z axis is flipped here to calculate x, y, t, and then flipped back to generate the
    /// correct view matrix.
    simd_float3 z = -simd_normalize(center - eye);
    simd_float3 x = simd_normalize(simd_cross(z, up));
    simd_float3 y = simd_cross(x, z);
    simd_float3 t = (simd_float3){ -simd_dot(x, eye), -simd_dot(y, eye), -simd_dot(z, eye) };
    z = -z;

    return (matrix_float4x4) {{
        { x.x, y.x, z.x, 0 },
        { x.y, y.y, z.y, 0 },
        { x.z, y.z, z.z, 0 },
        { t.x, t.y, t.z, 1 }
    }};
}

float length(simd_float3 float3) {
    return simd_length(float3);
}


}
