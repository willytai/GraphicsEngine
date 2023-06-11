//
//  Cube.cpp
//  RayTracing
//
//  Created by Willy Tai on 6/4/23.
//

#include "Cube.hpp"
#include "../../Utils/Math.hpp"


Ref<Cube> Cube::Create(float x, float y, float z) {
    return CreateRef<Cube>(x, y, z);
}

Cube::Cube(float x, float y, float z) {
    _x = x;
    _y = y;
    _z = z;

    _positions = {
        mathutil::float3(-0.5f, -0.5f,  0.5f),
        mathutil::float3( 0.5f, -0.5f,  0.5f),
        mathutil::float3( 0.5f,  0.5f,  0.5f),
        mathutil::float3(-0.5f,  0.5f,  0.5f),

        mathutil::float3( 0.5f, -0.5f,  0.5f),
        mathutil::float3( 0.5f, -0.5f, -0.5f),
        mathutil::float3( 0.5f,  0.5f, -0.5f),
        mathutil::float3( 0.5f,  0.5f,  0.5f),

        mathutil::float3( 0.5f, -0.5f, -0.5f),
        mathutil::float3(-0.5f, -0.5f, -0.5f),
        mathutil::float3(-0.5f,  0.5f, -0.5f),
        mathutil::float3( 0.5f,  0.5f, -0.5f),

        mathutil::float3(-0.5f, -0.5f, -0.5f),
        mathutil::float3(-0.5f, -0.5f,  0.5f),
        mathutil::float3(-0.5f,  0.5f,  0.5f),
        mathutil::float3(-0.5f,  0.5f, -0.5f),

        mathutil::float3(-0.5f,  0.5f,  0.5f),
        mathutil::float3( 0.5f,  0.5f,  0.5f),
        mathutil::float3( 0.5f,  0.5f, -0.5f),
        mathutil::float3(-0.5f,  0.5f, -0.5f),

        mathutil::float3(-0.5f, -0.5f,  0.5f),
        mathutil::float3( 0.5f, -0.5f,  0.5f),
        mathutil::float3( 0.5f, -0.5f, -0.5f),
        mathutil::float3(-0.5f, -0.5f, -0.5f),
    };

    _normals = {
        mathutil::float3( 0.0f,  0.0f,  1.0f),
        mathutil::float3( 0.0f,  0.0f,  1.0f),
        mathutil::float3( 0.0f,  0.0f,  1.0f),
        mathutil::float3( 0.0f,  0.0f,  1.0f),

        mathutil::float3( 1.0f,  0.0f,  0.0f),
        mathutil::float3( 1.0f,  0.0f,  0.0f),
        mathutil::float3( 1.0f,  0.0f,  0.0f),
        mathutil::float3( 1.0f,  0.0f,  0.0f),

        mathutil::float3( 0.0f,  0.0f, -1.0f),
        mathutil::float3( 0.0f,  0.0f, -1.0f),
        mathutil::float3( 0.0f,  0.0f, -1.0f),
        mathutil::float3( 0.0f,  0.0f, -1.0f),

        mathutil::float3(-1.0f,  0.0f,  0.0f),
        mathutil::float3(-1.0f,  0.0f,  0.0f),
        mathutil::float3(-1.0f,  0.0f,  0.0f),
        mathutil::float3(-1.0f,  0.0f,  0.0f),

        mathutil::float3( 0.0f,  1.0f,  0.0f),
        mathutil::float3( 0.0f,  1.0f,  0.0f),
        mathutil::float3( 0.0f,  1.0f,  0.0f),
        mathutil::float3( 0.0f,  1.0f,  0.0f),

        mathutil::float3( 0.0f, -1.0f,  0.0f),
        mathutil::float3( 0.0f, -1.0f,  0.0f),
        mathutil::float3( 0.0f, -1.0f,  0.0f),
        mathutil::float3( 0.0f, -1.0f,  0.0f),
    };

    _indices = {
        0,1,2,    0,2,3,
        4,5,6,    4,6,7,
        8,9,10,   8,10,11,
        12,13,14, 12,14,15,
        16,17,18, 16,18,19,
        20,21,22, 20,22,23,
    };

    // TODO use a model matrix instead of just hard-coding the positions
    // adjust positions by x, y, z
    simd_float3 multipiler = mathutil::float3(x, y, z);
    for (simd_float3& position : _positions) {
        position = position * multipiler;
    }
}
