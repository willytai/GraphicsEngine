//
//  Geometry.h
//  RayTracing
//
//  Created by Willy Tai on 6/28/23.
//

#import <Metal/Metal.h>
#import <simd/simd.h>
#import "../Asset/DataAllocator.h"
#import "../Asset/MeshBuffer.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    MeshBuffer*             indexBuffer;
    NSArray<MeshBuffer*>*   vertexBuffers;
} GeometryResource;

typedef struct {
    NSArray<id<MTLBuffer>>* buffers;
} GeometryResourceRT;

/// The geometry interface
@protocol Geometry

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

/// TODO a mask for representing the type of the geometry

@end


/// The class encapsulating the geometry and it's transform
@interface GeometryInstance : NSObject

/// the underlying geometry
@property(nonatomic, readonly) id<Geometry> geometry;

/// the transform
@property(nonatomic, readonly) simd_float4x4 transform;

/// simple initalizer
- (nonnull instancetype)initWithGeometry:(id<Geometry>)geometry
                               Transform:(simd_float4x4)transform;

@end

NS_ASSUME_NONNULL_END
