//
//  VertexDataAllocator.m
//  RayTracing
//
//  Created by Willy Tai on 5/23/23.
//

#import "BufferDataAllocator.h"
#import "MeshBuffer.h"
#import "../Shader/ShaderTypes.h"
#import "../../Utils/Logger.hpp"

@implementation BufferDataAllocator

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    if (self = [super init]) {
        MTLResourceOptions vtxBufRscOpts = MTLResourceStorageModeShared |
                                           MTLResourceCPUCacheModeWriteCombined;
        _vertexBuffers = @[
            [[MeshBuffer alloc] initWithDevice:device Size:MAX_SUPPORTED_VERTEX_COUNT * sizeofAttribute(VertexAttributePosition)   BufferIndex:BufferIndexMeshPositions  Options:vtxBufRscOpts Label:@"VertexPosition"],
            [[MeshBuffer alloc] initWithDevice:device Size:MAX_SUPPORTED_VERTEX_COUNT * sizeofAttribute(VertexAttributeNormal)     BufferIndex:BufferIndexMeshNormals    Options:vtxBufRscOpts Label:@"VertexNormal"],
            [[MeshBuffer alloc] initWithDevice:device Size:MAX_SUPPORTED_VERTEX_COUNT * sizeofAttribute(VertexAttributeMaterialID) BufferIndex:BufferIndexMeshMaterialID Options:vtxBufRscOpts Label:@"VertexMaterialID"],
        ];

        _device = device;

        // sanity check
        NSAssert(
            _vertexBuffers.count == BufferIndexCount,
            @"The number of vertex buffers allocated doesn't match the specification in 'ShaderTypes.h', did you forget to allocate vertex buffer(s) for the additional attribute(s) that were added?"
        );
    }
    return self;
}

- (nonnull MeshBuffer*)newIndexBufferForGeometry:(nonnull GeometryObj*)geometry {
    MeshBuffer* indexBuffer =  [[MeshBuffer alloc] initWithDevice:_device
                                                             Data:geometry->indices().data()
                                                             Size:geometry->indexCount() * geometry->indexTypeSize()
                                                      BufferIndex:BufferIndexDontCare
                                                          Options:MTLResourceStorageModeManaged
                                                            Label:@"IndexBuffer"];
    return indexBuffer;
}

- (nonnull NSArray<MeshBuffer*>*)newVertexBuffersForGeometry:(nonnull GeometryObj*)geometry {
    // upload the geometry's data and returns the buffers
    // since the vertex buffers are shared across meshes, making a copy of the state of vertex buffers
    // so that the offset is set correctly
    NSArray<MeshBuffer*>* newVertexBuffers = [[NSArray alloc] initWithArray:_vertexBuffers copyItems:YES];
    
    // the data are uploaded to the underlying metal buffer
    const std::vector<VtxPositionType>& positionData = geometry->positions();
    const std::vector<VtxNormalType>&   normalData   = geometry->normals();
    [_vertexBuffers[VertexAttributePosition] addData:positionData.data() Size:positionData.size() * sizeof(VtxPositionType)];
    [_vertexBuffers[VertexAttributeNormal]   addData:normalData.data()   Size:normalData.size() * sizeof(VtxNormalType)];
    
    return newVertexBuffers;
}

@end
