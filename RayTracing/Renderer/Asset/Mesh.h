//
//  Mesh.h
//  RayTracing
//
//  Created by Willy Tai on 5/20/23.
//

#import "BufferDataAllocator.h"
#import "MeshBuffer.h"
#import "Submesh.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Mesh : NSObject

/// the submeshes, each submesh will have its own index buffer but will
/// refer to the same vertex buffer inside the Mesh class
@property(nonatomic, readonly, nonnull) NSArray<Submesh*>* submeshes;

/// the vertex buffers that contains the data describing the vertices of this
/// mesh request the vertex buffers from the allocator
@property(nonatomic, readonly, nonnull) NSArray<MeshBuffer*>* vertexBuffers;

/// simple initialization
- (instancetype)initWithSubmesh:(Submesh*)submesh
                  VertexBuffers:(NSArray<MeshBuffer*>*)vertexBuffers;
- (instancetype)initWithSubmeshes:(NSArray<Submesh*>*)submeshes
                    VertexBuffers:(NSArray<MeshBuffer*>*)vertexBuffers;

/// generates an icosphere
+ (instancetype)newIcosphereWithSubdivisions:(NSUInteger)subdivisions
                                   Allocator:(BufferDataAllocator*)allocator;

/// a simple cube
+ (instancetype)newCubeWithDimensionX:(float)x
                                    Y:(float)y
                                    Z:(float)z
                            Allocator:(BufferDataAllocator*)allocator;
@end

NS_ASSUME_NONNULL_END
