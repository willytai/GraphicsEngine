//
//  Triangles.mm
//  RayTracing
//
//  Created by Willy Tai on 6/28/23.
//

#include <array>
#include <vector>
#include <unordered_map>
#include <unordered_set>
#import "Triangles.h"


#ifdef TEST
static TriangleTestData s_testData;
#endif


#pragma mark Cube Static Data

static const std::array<VtxPositionType, 24> s_CubePositionData = {
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

static const std::array<VtxNormalType, 24> s_CubeNormalData = {
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

static const std::array<TriangleIndexType, 36> s_CubeIndexData = {
        0,1,2,    0,2,3,
        4,5,6,    4,6,7,
        8,9,10,   8,10,11,
        12,13,14, 12,14,15,
        16,17,18, 16,18,19,
        20,21,22, 20,22,23,
};

#pragma mark Icosphere Static Data

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

// Constants for generating icospheres.
static const float H_ANGLE_RAD = 360.0f / 5.0f * M_PI / 180.0f;
static const float V_ANGLE_RAD = atanf(0.5f);

// Containers for generating icospheres.
static std::vector<VtxPositionType>     s_IcospherePositionData;
static std::vector<TriangleIndexType>   s_IcosphereIndexData;

// helper function for generating next subdivision
static void s_IcosphereGenerateNextSubdivision() {
#ifdef TEST
    // clear the map
    std::unordered_map<TriangleIndexType, int> newmap;
    s_testData.icosphere.indexAccessFrequency.swap(newmap);

    // make a copy of the indices of the 12 original vertices
    std::unordered_set<TriangleIndexType> indexSub0Old;
    s_testData.icosphere.indexSub0.swap(indexSub0Old);
#endif

    // cache generated vertices
    std::unordered_map<VtxPositionTypeHashKey, TriangleIndexType> vtx2idxMap;

    // make a copy of the previous subdivision
    std::vector<VtxPositionType>   oldPositions;
    std::vector<TriangleIndexType> oldIndices;
    s_IcospherePositionData.swap(oldPositions);
    s_IcosphereIndexData.swap(oldIndices);

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
            vtx2idxMap[v1] = (TriangleIndexType)s_IcospherePositionData.size();
            s_IcospherePositionData.push_back(v1);
        }
        if (vtx2idxMap.find(v2) == vtx2idxMap.end()) {
            vtx2idxMap[v2] = (TriangleIndexType)s_IcospherePositionData.size();
            s_IcospherePositionData.push_back(v2);
        }
        if (vtx2idxMap.find(v3) == vtx2idxMap.end()) {
            vtx2idxMap[v3] = (TriangleIndexType)s_IcospherePositionData.size();
            s_IcospherePositionData.push_back(v3);
        }
        if (vtx2idxMap.find(v12) == vtx2idxMap.end()) {
            vtx2idxMap[v12] = (TriangleIndexType)s_IcospherePositionData.size();
            s_IcospherePositionData.push_back(v12);
        }
        if (vtx2idxMap.find(v23) == vtx2idxMap.end()) {
            vtx2idxMap[v23] = (TriangleIndexType)s_IcospherePositionData.size();
            s_IcospherePositionData.push_back(v23);
        }
        if (vtx2idxMap.find(v31) == vtx2idxMap.end()) {
            vtx2idxMap[v31] = (TriangleIndexType)s_IcospherePositionData.size();
            s_IcospherePositionData.push_back(v31);
        }

        // retrieve the indices
        const TriangleIndexType& i1 = vtx2idxMap[v1];
        const TriangleIndexType& i2 = vtx2idxMap[v2];
        const TriangleIndexType& i3 = vtx2idxMap[v3];
        const TriangleIndexType& i12 = vtx2idxMap[v12];
        const TriangleIndexType& i23 = vtx2idxMap[v23];
        const TriangleIndexType& i31 = vtx2idxMap[v31];

        // generate triangles
        s_IcosphereIndexData.push_back(i1);
        s_IcosphereIndexData.push_back(i12);
        s_IcosphereIndexData.push_back(i31);
        s_IcosphereIndexData.push_back(i12);
        s_IcosphereIndexData.push_back(i2);
        s_IcosphereIndexData.push_back(i23);
        s_IcosphereIndexData.push_back(i31);
        s_IcosphereIndexData.push_back(i23);
        s_IcosphereIndexData.push_back(i3);
        s_IcosphereIndexData.push_back(i12);
        s_IcosphereIndexData.push_back(i23);
        s_IcosphereIndexData.push_back(i31);

#ifdef TEST
        s_testData.icosphere.indexAccessFrequency[i12] += 3;
        s_testData.icosphere.indexAccessFrequency[i23] += 3;
        s_testData.icosphere.indexAccessFrequency[i31] += 3;
        s_testData.icosphere.indexAccessFrequency[i1] += 1;
        s_testData.icosphere.indexAccessFrequency[i2] += 1;
        s_testData.icosphere.indexAccessFrequency[i3] += 1;

        if (indexSub0Old.find(oldIndices[i+0]) != indexSub0Old.end()) {
            s_testData.icosphere.indexSub0.insert(i1);
        }
        if (indexSub0Old.find(oldIndices[i+1]) != indexSub0Old.end()) {
            s_testData.icosphere.indexSub0.insert(i2);
        }
        if (indexSub0Old.find(oldIndices[i+2]) != indexSub0Old.end()) {
            s_testData.icosphere.indexSub0.insert(i3);
        }
#endif
    }
}


#pragma mark Triangles implementation

@implementation Triangles
{
    DataAllocator*  _dataAllocator;

    id<MTLBuffer>   _indexBuffer;
    id<MTLBuffer>   _vertexPositionBuffer;
    id<MTLBuffer>   _vertexNormalBuffer;
    id<MTLBuffer>   _vertexMaterialIDBuffer;

    std::vector<TriangleIndexType>  _indices;
    std::vector<VtxPositionType>    _positions;
    std::vector<VtxNormalType>      _normals;
    std::vector<VtxMaterialIDType>  _materialIDs;
}

- (nonnull instancetype)initWithDataAllocator:(nonnull DataAllocator *)allocator {
    if ((self = [super init])) {
        _dataAllocator = allocator;
        // TODO init buffers and set maximum capacity
    }
    return self;
}

- (GeometryResource)resource {
    return GeometryResource {
        [[MeshBuffer alloc] initWithMTLBuffer:_indexBuffer Offset:0 BufferIndex:BufferIndexDontCare],
        @[
            [[MeshBuffer alloc] initWithMTLBuffer:_vertexPositionBuffer Offset:0 BufferIndex:BufferIndexMeshPositions],
            [[MeshBuffer alloc] initWithMTLBuffer:_vertexNormalBuffer Offset:0 BufferIndex:BufferIndexMeshNormals],
            [[MeshBuffer alloc] initWithMTLBuffer:_vertexMaterialIDBuffer Offset:0 BufferIndex:BufferIndexMeshMaterialIDs],
        ]
    };
}

- (GeometryResourceRT)resourceRT {
    return GeometryResourceRT {
        @[_indexBuffer, _vertexPositionBuffer, _vertexNormalBuffer, _vertexMaterialIDBuffer],
    };
}

- (void)uploadBuffers {
    // create buffers
    _indexBuffer            = [_dataAllocator newManagedBufferWithElementSize:sizeof(TriangleIndexType) ElementCount:_indices.size()];
    _vertexPositionBuffer   = [_dataAllocator newManagedBufferWithElementSize:sizeof(VtxPositionType)   ElementCount:_positions.size()];
    _vertexNormalBuffer     = [_dataAllocator newManagedBufferWithElementSize:sizeof(VtxNormalType)     ElementCount:_normals.size()];
    _vertexMaterialIDBuffer = [_dataAllocator newManagedBufferWithElementSize:sizeof(VtxMaterialIDType) ElementCount:_materialIDs.size()];
    
    // copy data
    memcpy(_indexBuffer.contents,            _indices.data(),     _indexBuffer.length);
    memcpy(_vertexPositionBuffer.contents,   _positions.data(),   _vertexPositionBuffer.length);
    memcpy(_vertexNormalBuffer.contents,     _normals.data(),     _vertexNormalBuffer.length);
    memcpy(_vertexMaterialIDBuffer.contents, _materialIDs.data(), _vertexMaterialIDBuffer.length);

    // notify GPU since we are using managed buffers
    [_indexBuffer            didModifyRange:NSMakeRange(0, _indexBuffer.length)];
    [_vertexPositionBuffer   didModifyRange:NSMakeRange(0, _vertexPositionBuffer.length)];
    [_vertexNormalBuffer     didModifyRange:NSMakeRange(0, _vertexNormalBuffer.length)];
    [_vertexMaterialIDBuffer didModifyRange:NSMakeRange(0, _vertexMaterialIDBuffer.length)];
}

- (MTLIndexType)indexType {
    return MTLIndexTypeUInt16;
}

- (NSUInteger)indexCount {
    return _indices.size();
}

- (MTLPrimitiveType)primitiveType {
    return MTLPrimitiveTypeTriangle;
}

- (void)addCubeWithMaterialID:(VtxMaterialIDType)materialID {
    // populate vertex positions
    for (const VtxPositionType& pos : s_CubePositionData) {
        _positions.push_back(pos);
    }
    // populate vertex normals
    for (const VtxNormalType& norm : s_CubeNormalData) {
        _normals.push_back(norm);
    }
    // populate vertex materialIDs
    for (int i = 0; i < s_CubePositionData.size(); ++i) {
        _materialIDs.push_back(materialID);
    }
    // populate indices
    TriangleIndexType indexOffset = (TriangleIndexType)_indices.size();
    for (const TriangleIndexType& index : s_CubeIndexData) {
        _indices.push_back(indexOffset + index);
    }
}

// unit icosphere
- (void)addIcosphereWithSubdivisions:(NSUInteger)subdivisions MaterialID:(VtxMaterialIDType)materialID {
    // clear the containers
    s_IcospherePositionData.clear();
    s_IcosphereIndexData.clear();

    // * subdivision 0
    //     - base case:
    //        12 vertices
    //        60 indices (20 faces/triangles)
    s_IcospherePositionData.resize(12);
    s_IcosphereIndexData.resize(60);

    //     - top/bottom vertex
    s_IcospherePositionData[0]  = {0.0f,  1.0f, 0.0f};
    s_IcospherePositionData[11] = {0.0f, -1.0f, 0.0f};

    //     - first and second row
    //     - angle of first row starts at -M_PI / 2.0f + 3 * H_ANGLE_RAD
    //     - angle of second row starts at M_PI / 2.0f
    int rowupid = 1, rowdownid = 6;
    float rowuprad = -M_PI / 2.0f + 3 * H_ANGLE_RAD;
    float rowdownrad = M_PI / 2.0f;
    for (int i = 0; i < 5; ++i) {
        s_IcospherePositionData[rowupid] = mathutil::float3(
            cosf(V_ANGLE_RAD) * cosf(rowuprad),
            sinf(V_ANGLE_RAD),
            cosf(V_ANGLE_RAD) * sinf(rowuprad)
        );
        s_IcospherePositionData[rowdownid] = mathutil::float3(
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
    s_IcosphereIndexData = {
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
    for (TriangleIndexType idx = 0; idx < 12; ++idx) {
        s_testData.icosphere.indexSub0.insert(idx);
    }
    // record the number of subdivisions
    s_testData.icosphere.subdivisions = subdivisions;
    // give a reference to the position data
    s_testData.icosphere.positions = &s_IcospherePositionData;
#endif

    // generate subdivisions
    while (subdivisions--) {
        s_IcosphereGenerateNextSubdivision();
    }

    // populate vertex positions
    for (const VtxPositionType& pos : s_IcospherePositionData) {
        _positions.push_back(pos);
    }
    // populate vertex normals
    // normals are exactly the same as position for unit spheres
    for (const VtxNormalType& norm : s_IcospherePositionData) {
        _normals.push_back(norm);
    }
    // populate vertex materialIDs
    for (int i = 0; i < s_IcospherePositionData.size(); ++i) {
        _materialIDs.push_back(materialID);
    }
    // populate indices
    TriangleIndexType indexOffset = (TriangleIndexType)_indices.size();
    for (const TriangleIndexType& index : s_IcosphereIndexData) {
        _indices.push_back(indexOffset + index);
    }
}

#ifdef TEST
- (TriangleTestData)testData {
    return s_testData;
}
- (size_t)indexTypeSize {
    return sizeof(TriangleIndexType);
}
#endif

@end
