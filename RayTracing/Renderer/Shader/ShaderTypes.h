//
//  ShaderTypes.h
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
// metal shader
#define ATTRIBUTE_ID(id)        [[attribute(id)]]
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
typedef metal::int32_t  EnumBackingType;
#else
// source code
#import <Foundation/Foundation.h>
#import <simd/simd.h>
#define ATTRIBUTE_ID(id)
typedef NSInteger       EnumBackingType;
#endif

#include <simd/simd.h>

#import "VertexType.hpp"


typedef NS_ENUM(EnumBackingType, BufferIndex)
{
    BufferIndexMeshPositions   = 1,
    BufferIndexMeshNormals     = 2,
    BufferIndexMeshMaterialIDs = 3,

    // Some helper macros.
    // This keeps track of how many vertex buffers
    // are required.
    // Make sure to update the '__BufferIndexMax' when
    // a new vertex attribute is added.
    __BufferIndexMax = BufferIndexMeshMaterialIDs,
    BufferIndexCount = __BufferIndexMax,
    
    BufferIndexUniforms = 0,
    BufferIndexDontCare = -1,
};

typedef NS_ENUM(EnumBackingType, VertexAttribute)
{
    VertexAttributePosition   = BufferIndexMeshPositions - 1,
    VertexAttributeNormal     = BufferIndexMeshNormals - 1,
    VertexAttributeMaterialID = BufferIndexMeshMaterialIDs - 1,
};

typedef NS_ENUM(EnumBackingType, TextureIndex)
{
    // for rayTracingKernel
    TextureIndexRayTracingKernelDestinationTarget = 0,

    // for copy shader
    TextureIndexCopyShaderDestinationTarget = 0,
};

typedef struct
{
    VtxPositionType     position   ATTRIBUTE_ID(VertexAttributePosition);
    VtxNormalType       normal     ATTRIBUTE_ID(VertexAttributeNormal);
    VtxMaterialIDType   materialID ATTRIBUTE_ID(VertexAttributeMaterialID);
} Vertex;

typedef struct
{
    simd_float4x4 projectionMatrix;
    simd_float4x4 viewProjectionMatrix;
    simd_float4x4 viewMatrix;
    unsigned int frameIndex;
} Uniforms;


// things specific for source code goes here
#ifndef __METAL_VERSION__

#define MAX_SUPPORTED_VERTEX_COUNT 1e6

#ifdef __cplusplus
extern "C"
#endif
size_t sizeofAttribute(VertexAttribute attribute);

#endif

#endif /* ShaderTypes_h */

