//
//  CopyShader.metal
//  RayTracing
//
//  Created by Willy Tai on 6/23/23.
//

#include <metal_stdlib>

#import "ShaderTypes.h"

using namespace metal;


struct VOut
{
    float4 position [[position]];
    float2 uv;
};

// screen quad in normalized device coordinates
constant float2 quadVertices[] =
{
    float2(-1, -1),
    float2(-1,  1),
    float2( 1,  1),
    float2(-1, -1),
    float2( 1,  1),
    float2( 1, -1)
};

// passes quad positions in normalized device coordinates
vertex VOut copyVertex(unsigned short vid [[vertex_id]])
{
    VOut out;

    float2 pos = quadVertices[vid];
    out.position = float4(pos, 0, 1);
    // normalize to [0, 1]
    out.uv = pos * 0.5f + 0.5f;
    // uv should be flipped hirizontally because the texture coordinate
    // origin is at the top left
    out.uv = float2(0.0f, 1.0f) - out.uv;

    return out;
}

// copies the final image to the view's drawable after tonemapping
fragment float4 copyFragment(VOut               in                  [[stage_in]],
                             texture2d<float>   finalFramebuffer    [[ texture(TextureIndexCopyShaderDestinationTarget) ]])
{
    constexpr sampler copySampler(min_filter::nearest,
                                  mag_filter::nearest,
                                  mip_filter::none);

    float3 color = finalFramebuffer.sample(copySampler, in.uv).rgb;

    // reduce dynamic range
    // color /= 1.0f + color;

    return float4(color, 1.0f);
}
