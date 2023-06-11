//
//  Coordinates.cpp
//  RayTracing
//
//  Created by Willy Tai on 6/10/23.
//

#include "Coordinates.hpp"

simd_float3 WORLD_SPACE_UP        = mathutil::float3( 0.0f,  1.0f,  0.0f);
simd_float3 WORLD_SPACE_DOWN      = mathutil::float3( 0.0f, -1.0f,  0.0f);
simd_float3 WORLD_SPACE_LEFT      = mathutil::float3(-1.0f,  0.0f,  0.0f);
simd_float3 WORLD_SPACE_RIGHT     = mathutil::float3( 1.0f,  0.0f,  0.0f);
simd_float3 WORLD_SPACE_FORWARD   = mathutil::float3( 0.0f,  0.0f, -1.0f);
simd_float3 WORLD_SPACE_BACKWARD  = mathutil::float3( 0.0f,  0.0f,  1.0f);
simd_float3 WORLD_SPACE_ORIGIN    = mathutil::float3( 0.0f,  0.0f,  0.0f);
