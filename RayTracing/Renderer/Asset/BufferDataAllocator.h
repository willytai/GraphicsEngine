//
//  VertexDataAllocator.h
//  RayTracing
//
//  Created by Willy Tai on 5/23/23.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MeshBuffer.h"
#import "../Geometries/GeometryObj.hpp"

NS_ASSUME_NONNULL_BEGIN

/// all mesh objects should use the allocator to generate the vertex data
/// and record the state of the buffers for that specific mesh
/// this allows the data to be populated on a single set of vertex buffers
/// vertex buffers are shared but each submesh can have their own index buffer
/// (every draw call requires an index buffer parameter)
@interface BufferDataAllocator : NSObject

/// all the vertex buffers
@property(nonatomic, readonly, nonnull) NSArray<MeshBuffer*>* vertexBuffers;

/// the device
@property(nonatomic, readonly, nonnull) id<MTLDevice> device;

/// initialize the allocator with the required number of vertex buffer
/// the number of vertex buffers allocated is controlled by the number of attributes specified in 'ShaderTypes.h'
- (instancetype)initWithDevice:(id<MTLDevice>)device;

/// generates a new buffer for indices
- (MeshBuffer*)newIndexBufferForGeometry:(GeometryObj*)geometry;

/// generates vertex buffers for the given geometry
- (NSArray<MeshBuffer*>*)newVertexBuffersForGeometry:(GeometryObj*)geometry;

@end

NS_ASSUME_NONNULL_END
