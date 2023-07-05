//
//  Math.cpp
//  RayTracing
//
//  Created by Willy Tai on 5/9/23.
//

#include "Math.hpp"

#define EPSILON 1e-6


namespace mathutil {

#pragma mark Types

simd_float2 float2() {
    return float2(0.0f, 0.0f);
}

simd_float3 float3() {
    return float3(0.0f, 0.0f, 0.0f);
}

simd_float4 float4() {
    return float4(0.0f, 0.0f, 0.0f, 0.0f);
}

simd_float4x4 float4x4() {
    return matrix_identity_float4x4;
}

simd_float2 float2(float x, float y) {
    return simd_make_float2(x, y);
}

simd_float3 float3(float x, float y, float z) {
    return simd_make_float3(x, y, z);
}

simd_float4 float4(float x, float y, float z, float w) {
    return simd_make_float4(x, y, z, w);
}

simd_float4 float4(simd_float3 vec3, float w) {
    return simd_make_float4(vec3, w);
}

simd_quatf quat(float pitch, float yaw, float roll) {
    return simd_quaternion(pitch, yaw, roll, 1.0f);
}

#pragma mark Operations

simd_float4x4 matmul(simd_float4x4 x, simd_float4x4 y) {
    return simd_mul(x, y);
}

simd_float3 rotate(simd_quatf q, simd_float3 v) {
    return simd_act(q, v);
}

#pragma mark Geometries

simd_float4x4 perspective(float fovDeg, float aspect, float nearClip, float farClip) {
    float fovRad = fovDeg / 180.0f * M_PI;
    float ys = 1.0f / tanf(fovRad * 0.5f);
    float xs = ys / aspect;
    float zs = -farClip / (farClip - nearClip);

    // matrices are column majored
    return simd_matrix_from_rows(
        (simd_float4){  xs,  0.0f,           0.0f,   0.0f},
        (simd_float4){0.0f,    ys,           0.0f,   0.0f},
        (simd_float4){0.0f,  0.0f,             zs,  -1.0f},
        (simd_float4){0.0f,  0.0f,  nearClip * zs,   0.0f}
    );
}

simd_float4x4 view(simd_float3 eye, simd_float3 center, simd_float3 up) {
    // find the three axis of the camera space in world space
    // everything is in right-handed coordinate system
    simd_float3 z = simd_normalize(eye - center);
    simd_float3 x = simd_normalize(simd_cross(up, z));
    simd_float3 y = simd_cross(z, x);
    // translation component
    simd_float3 t = (simd_float3){ -simd_dot(x, eye), -simd_dot(y, eye), -simd_dot(z, eye) };

    // matrices are column majored
    return simd_matrix_from_rows(
        (simd_float4){x.x, y.x, z.x, 0.0},
        (simd_float4){x.y, y.y, z.y, 0.0},
        (simd_float4){x.z, y.z, z.z, 0.0},
        (simd_float4){t.x, t.y, t.z, 1.0}
    );
}

float length(simd_float3 float3) {
    return simd_length(float3);
}

simd_float3 normalize(simd_float3 float3) {
    return simd_normalize(float3);
}

#pragma mark Other Utils

bool fequal(float x, float y) {
    return std::fabs(x - y) < EPSILON;
}


}
