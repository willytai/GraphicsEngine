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

// types
simd_float2     float2();
simd_float3     float3();
simd_float4     float4();
simd_float4x4   float4x4();

simd_float2     float2(float x, float y);
simd_float3     float3(float x, float y, float z);
simd_float4     float4(float x, float y, float z, float w);
simd_float4     float4(simd_float3 vec3, float w);
simd_quatf      quat(float pitch, float yaw, float roll);

// operations
simd_float4x4   matmul(simd_float4x4 x, simd_float4x4 y);
simd_float3     rotate(simd_quatf q, simd_float3 v);


//
// gometries
//

/// Generates a perspective projection matrix that takes in positions in camera space
/// and projects them to clip space. The camera space is a right-handed coordinate system,
/// and the clip space is a left-handed coordinate system.
///
///
/// World/Camera space:
///
///         y   
///         |__x
///        /    
///       z     
///
/// Clip space:
///
///       y
///       |  z
///       | /  
///       |/____x
///
///                     (-1,  1, -1)            ( 1,  1, -1)
///                           +-----------------------+
///                          /|                      /|
///                         / |                     / |
///                        /  |                    /  |
///                       /   |                   /   |
///                      /    |                  /    |
///                     /     |                 /     |
///                    /      |                /      |
///      (-1,  1,  1) +-------|---------------+ ( 1,  1,  1)
///                   |       |               |       |
///                   |       +---------------|-------+
///                   |      / (-1, -1, -1)   |      / ( 1, -1, -1)
///                   |     /                 |     /
///                   |    /                  |    /
///                   |   /                   |   /
///                   |  /                    |  /
///                   | /                     | /
///                   |/                      |/
///                   +-----------------------+
///             (-1, -1,  1)            ( 1, -1,  1)
///
///
/// - Parameters:
///   - fovDeg: field of view, in degrees 
///   - aspect: aspect ratio (width / height)
///   - nearClip: nearest clip value
///   - farClip: farthest clip value
simd_float4x4 perspective(float fovDeg, float aspect, float nearClip, float farClip);

/// Generates a view matrix that takes in positions in world space and projects them to
/// camera space. It is essentially the transform of the camera.
/// Both world space and camera space are right-handed coordinate systems, so everything
/// is calculated in the right-handed coordinate system.
///
/// - Parameters:
///   - eye: position of the camera (eye), in world coordinate
///   - center: where the camera (eye) is looking at
///   - up: the upward direction of the camera (eye), usually (0, 1, 0) if we don't tilt
simd_float4x4 view(simd_float3 eye, simd_float3 center, simd_float3 up);

/// length of vectors
float length(simd_float3 float3);

/// normalization
simd_float3 normalize(simd_float3 float3);

/// other utilities
bool fequal(float x, float y);

}

#endif /* Math_hpp */
