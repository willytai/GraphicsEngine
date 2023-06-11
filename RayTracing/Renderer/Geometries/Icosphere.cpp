//
//  Icosphere.cpp
//  RayTracing
//
//  Created by Willy Tai on 5/26/23.
//

#include "Icosphere.hpp"
#include "../../Utils/Logger.hpp"
#include "../../Utils/Math.hpp"


Ref<Icosphere> Icosphere::Create(float radius, int subdivisions) {
    return CreateRef<Icosphere>(radius, subdivisions);
}

Icosphere::Icosphere(float radius, int subdivisions) {
    _radius = radius;
    _subdivisions = subdivisions;

    // * subdivision 0
    //     - base case:
    //        12 vertices
    //        60 indices (20 faces/triangles)
    _positions.resize(12);
    _indices.resize(60);
    //     - top/bottom vertex
    _positions[0]  = {0.0f,  1.0f, 0.0f};
    _positions[11] = {0.0f, -1.0f, 0.0f};
    //     - first and second row
    //     - angle of first row starts at -M_PI / 2.0f + 3 * H_ANGLE_RAD
    //     - angle of second row starts at M_PI / 2.0f
    int rowupid = 1, rowdownid = 6;
    float rowuprad = -M_PI / 2.0f + 3 * H_ANGLE_RAD;
    float rowdownrad = M_PI / 2.0f;
    for (int i = 0; i < 5; ++i) {
        _positions[rowupid] = mathutil::float3(
            cosf(V_ANGLE_RAD) * cosf(rowuprad),
            sinf(V_ANGLE_RAD),
            cosf(V_ANGLE_RAD) * sinf(rowuprad)
        );
        _positions[rowdownid] = mathutil::float3(
            cosf(V_ANGLE_RAD) * cosf(rowdownrad),
            sinf(-V_ANGLE_RAD),
            cosf(V_ANGLE_RAD) * sinf(rowdownrad)
        );
        rowupid++;
        rowdownid++;
        rowuprad += H_ANGLE_RAD;
        rowdownrad += H_ANGLE_RAD;
    }
    // indices
    _indices = {
        0,  1,  5,
        0,  5,  4,
        0,  4,  3,
        0,  3,  2,
        0,  2,  1,
        1,  6,  5,
        2,  7,  1,
        3,  8,  2,
        4,  9,  3,
        5, 10,  4,
        5,  6, 10,
        4, 10,  9,
        3,  9,  8,
        2,  8,  7,
        1,  7,  6,
        11, 10, 6,
        11, 9, 10,
        11, 8,  9,
        11, 7,  8,
        11, 6,  7,
    };
    assert(subdivisions == 0);
    // adjust raduis
    for (simd_float3& pos : _positions) {
        pos *= _radius;
    }
    // normals are just the vertex positions since the center is at the origin
    _normals = _positions;
}
