//
//  Icosphere.cpp
//  RayTracing
//
//  Created by Willy Tai on 5/26/23.
//

#include <unordered_map>
#include "Icosphere.hpp"
#include "../../Utils/Logger.hpp"
#include "../../Utils/Math.hpp"

#include <iostream>


// A hash structure for VtxPositionType, which is a simd_float3.
// This is just for unordered_map to work.
struct VtxPositionTypeHashKey
{
    VtxPositionType value;

    VtxPositionTypeHashKey(VtxPositionType pos) : value(pos) {}

    bool operator==(const VtxPositionTypeHashKey& other) const {
        return mathutil::fequal(((float*)&value)[0], ((float*)&other.value)[0]) &&
               mathutil::fequal(((float*)&value)[1], ((float*)&other.value)[1]) &&
               mathutil::fequal(((float*)&value)[2], ((float*)&other.value)[2]);
    }
};

template <>
struct std::hash<VtxPositionTypeHashKey>
{
    std::size_t operator()(const VtxPositionTypeHashKey& key) const {
        // TODO not sure if this is good
        size_t* val = (size_t*)&key.value;
        return val[0] ^ val[1];
    }
};


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

#ifdef TEST
    // the indices for subdivision 0
    for (RawIndexType idx = 0; idx < 12; ++idx) {
        testData.indexSub0.insert(idx);
    }
#endif

    // generate subdivisions
    while (subdivisions--) {
        this->generateNextSubdivision();
    }

    // adjust raduis
    for (simd_float3& pos : _positions) {
        pos *= _radius;
    }

    // normals are just the vertex positions since the center is at the origin
    _normals = _positions;
}

void Icosphere::generateNextSubdivision() {
#ifdef TEST
    // clear the map
    std::unordered_map<RawIndexType, int> newmap;
    testData.indexAccessFrequency.swap(newmap);

    // map a copy of the indices of the 12 original vertices
    std::unordered_set<RawIndexType> indexSub0Old;
    testData.indexSub0.swap(indexSub0Old);
#endif

    // cache generated vertices
    std::unordered_map<VtxPositionTypeHashKey, RawIndexType> vtx2idxMap;

    // make a copy of the previous subdivision
    std::vector<VtxPositionType> oldPositions;
    std::vector<RawIndexType>    oldIndices;
    _positions.swap(oldPositions);
    _indices.swap(oldIndices);

    // generate the next subdivision from the trianlges of the previous subdivision
    for (int i = 0; i < oldIndices.size(); i += 3) {
        // compute 3 new vertices by spliting half on each edge
        //         v1
        //        / \
        //   v12 *---* v31
        //      / \ / \
        //    v2---*---v3
        //        v23
        const VtxPositionType& v1 = oldPositions[oldIndices[i+0]];
        const VtxPositionType& v2 = oldPositions[oldIndices[i+1]];
        const VtxPositionType& v3 = oldPositions[oldIndices[i+2]];
        VtxPositionType v12 = mathutil::normalize((v1 + v2) / 2.0f);
        VtxPositionType v23 = mathutil::normalize((v2 + v3) / 2.0f);
        VtxPositionType v31 = mathutil::normalize((v3 + v1) / 2.0f);

        // record positions and index mapping
        if (vtx2idxMap.find(v1) == vtx2idxMap.end()) {
            vtx2idxMap[v1] = (RawIndexType)_positions.size();
            _positions.push_back(v1);
        }
        if (vtx2idxMap.find(v2) == vtx2idxMap.end()) {
            vtx2idxMap[v2] = (RawIndexType)_positions.size();
            _positions.push_back(v2);
        }
        if (vtx2idxMap.find(v3) == vtx2idxMap.end()) {
            vtx2idxMap[v3] = (RawIndexType)_positions.size();
            _positions.push_back(v3);
        }
        if (vtx2idxMap.find(v12) == vtx2idxMap.end()) {
            vtx2idxMap[v12] = (RawIndexType)_positions.size();
            _positions.push_back(v12);
        }
        if (vtx2idxMap.find(v23) == vtx2idxMap.end()) {
            vtx2idxMap[v23] = (RawIndexType)_positions.size();
            _positions.push_back(v23);
        }
        if (vtx2idxMap.find(v31) == vtx2idxMap.end()) {
            vtx2idxMap[v31] = (RawIndexType)_positions.size();
            _positions.push_back(v31);
        }

        // retrieve the indices
        const RawIndexType& i1 = vtx2idxMap[v1];
        const RawIndexType& i2 = vtx2idxMap[v2];
        const RawIndexType& i3 = vtx2idxMap[v3];
        const RawIndexType& i12 = vtx2idxMap[v12];
        const RawIndexType& i23 = vtx2idxMap[v23];
        const RawIndexType& i31 = vtx2idxMap[v31];

        // generate triangles
        _indices.push_back(i1);
        _indices.push_back(i12);
        _indices.push_back(i31);
        _indices.push_back(i12);
        _indices.push_back(i2);
        _indices.push_back(i23);
        _indices.push_back(i31);
        _indices.push_back(i23);
        _indices.push_back(i3);
        _indices.push_back(i12);
        _indices.push_back(i23);
        _indices.push_back(i31);

#ifdef TEST
        testData.indexAccessFrequency[i12] += 3;
        testData.indexAccessFrequency[i23] += 3;
        testData.indexAccessFrequency[i31] += 3;
        testData.indexAccessFrequency[i1] += 1;
        testData.indexAccessFrequency[i2] += 1;
        testData.indexAccessFrequency[i3] += 1;

        if (indexSub0Old.find(oldIndices[i+0]) != indexSub0Old.end()) {
            testData.indexSub0.insert(i1);
        }
        if (indexSub0Old.find(oldIndices[i+1]) != indexSub0Old.end()) {
            testData.indexSub0.insert(i2);
        }
        if (indexSub0Old.find(oldIndices[i+2]) != indexSub0Old.end()) {
            testData.indexSub0.insert(i3);
        }
#endif
    }
}
