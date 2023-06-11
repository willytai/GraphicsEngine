//
//  Shaders.metal
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

vertex ColorInOut vertexShader(Vertex in [[stage_in]], constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
{
    ColorInOut out;

    float4 position = float4(in.position, 1.0);
    out.position =  position;
    // out.position = position * uniforms.viewMatrix * uniforms.projectionMatrix;
    out.position = position * uniforms.viewProjectionMatrix;
    out.position /= out.position.w;
    out.texCoord = float2(0.0f, 0.0f);
    // out.texCoord = in.texCoord;

    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                               texture2d<half> colorMap     [[ texture(TextureIndexColor) ]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);

    // half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);

    return float4(1.0f);
    // return float4(colorSample);
}
