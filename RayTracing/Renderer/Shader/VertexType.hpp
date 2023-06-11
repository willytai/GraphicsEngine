//
//  VertexType.h
//  RayTracing
//
//  Created by Willy Tai on 6/1/23.
//

#ifndef VertexType_hpp
#define VertexType_hpp


#ifdef __METAL_VERSION__
// metal shader
#include <metal_stdlib>
typedef float3          VtxPositionType;
typedef float3          VtxNormalType;
typedef uint8_t         VtxMaterialIDType;
#else
// source code
#include <simd/simd.h>
typedef simd_float3     VtxPositionType;
typedef simd_float3     VtxNormalType;
typedef uint8_t         VtxMaterialIDType;
#endif


#endif /* VertexType_hpp */
