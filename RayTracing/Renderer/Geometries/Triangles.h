//
//  Triangles.h
//  RayTracing
//
//  Created by Willy Tai on 6/28/23.
//

#import "Geometry.h"
#import "../Shader/ShaderTypes.h"
#import "../../Utils/Math.hpp"

typedef uint16_t TriangleIndexType;

#ifdef TEST
#include <unordered_map>
#include <unordered_set>
#include <vector>
struct TriangleTestData
{
    struct IcosphereTestData
    {
        uint64_t                                    subdivisions;
        std::unordered_map<TriangleIndexType, int>  indexAccessFrequency;
        std::unordered_set<TriangleIndexType>       indexSub0;
        std::vector<VtxPositionType>* _Nullable     positions;
    } icosphere;
};
#endif

NS_ASSUME_NONNULL_BEGIN

@interface Triangles : NSObject <Geometry>

/// the device to create the resources and acceleration structures if ray traced
- (nonnull instancetype)initWithDataAllocator:(nonnull DataAllocator*)allocator;

/// for retrieving the resources (buffers) to bind to the pipeline for normal rendering
- (GeometryResource)resource;

/// for retrieving the resources (buffers) to bind to the pipeline for ray tracing
- (GeometryResourceRT)resourceRT;

/// upload data to GPU
- (void)uploadBuffers;

/// index type
- (MTLIndexType)indexType;

/// index count
- (NSUInteger)indexCount;

/// index type
- (MTLPrimitiveType)primitiveType;

/// unit cube
- (void)addCubeWithMaterialID:(VtxMaterialIDType)materialID;

/// unit icosphere
- (void)addIcosphereWithSubdivisions:(NSUInteger)subdivisions MaterialID:(VtxMaterialIDType)materialID;

#ifdef TEST
- (TriangleTestData)testData;
- (size_t)indexTypeSize;
#endif

@end

NS_ASSUME_NONNULL_END
