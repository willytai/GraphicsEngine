//
//  Mesh.m
//  RayTracing
//
//  Created by Willy Tai on 5/20/23.
//

#import "Mesh.h"

@implementation Mesh {
}

- (nonnull instancetype)initWithSubmesh:(nonnull Submesh*)submesh
                          VertexBuffers:(nonnull NSArray<MeshBuffer*>*)vertexBuffers {
    if (self = [super init]) {
        _submeshes = @[ submesh ];
        _vertexBuffers = vertexBuffers;
    }
    return self;
}

- (nonnull instancetype)initWithSubmeshes:(nonnull NSArray<Submesh*>*)submeshes
                            VertexBuffers:(nonnull NSArray<MeshBuffer*>*)vertexBuffers {
    if (self = [super init]) {
        _submeshes = submeshes;
        _vertexBuffers = vertexBuffers;
    }
    return self;
}

// + (nonnull instancetype)newIcosphereWithSubdivisions:(NSUInteger)subdivisions
//                                            Allocator:(BufferDataAllocator*)allocator {
//     // uses uint16_t for indices
//     Ref<GeometryObj> sphere = CreateRef<Icosphere>(2.0f, subdivisions);
//     // allocate the index buffer
//     MeshBuffer* indexBuffer = [allocator newIndexBufferForGeometry:sphere.get()];
//     // allocate the vertex buffers
//     NSArray<MeshBuffer*>* vertexBuffers = [allocator newVertexBuffersForGeometry:sphere.get()];
//     // we only need one submesh for a sphere
//     Submesh *submesh = [[Submesh alloc] initWithPrimitiveType:MTLPrimitiveTypeTriangle
//                                                     IndexType:toMetalIndexType(sphere->indexType())
//                                                    IndexCount:sphere->indexCount()
//                                                   IndexBuffer:indexBuffer];
//     // create the Mesh instance
//     return [[Mesh alloc] initWithSubmesh:submesh VertexBuffers:vertexBuffers];
// }
// 
// + (nonnull instancetype)newCubeWithDimensionX:(float)x
//                                             Y:(float)y
//                                             Z:(float)z
//                                     Allocator:(BufferDataAllocator*)allocator {
//     Ref<GeometryObj> cube = CreateRef<Cube>(x, y, z);
//     // allocate the index buffer
//     MeshBuffer* indexBuffer = [allocator newIndexBufferForGeometry:cube.get()];
//     // allocate the vertex buffers
//     NSArray<MeshBuffer*>* vertexBuffers = [allocator newVertexBuffersForGeometry:cube.get()];
//     // we only need one submesh for a cube
//     Submesh *submesh = [[Submesh alloc] initWithPrimitiveType:MTLPrimitiveTypeTriangle
//                                                     IndexType:toMetalIndexType(cube->indexType())
//                                                    IndexCount:cube->indexCount()
//                                                   IndexBuffer:indexBuffer];
//     // create the Mesh instance
//     return [[Mesh alloc] initWithSubmesh:submesh VertexBuffers:vertexBuffers];
//     
// }

@end
