//
//  RayTracingKernel.metal
//  RayTracing
//
//  Created by Willy Tai on 6/23/23.
//

#include <metal_stdlib>

#import "ShaderTypes.h"

using namespace metal;


kernel void rayTracingKernel(uint2                              position    [[ thread_position_in_grid ]],
                             constant Uniforms&                 uniforms    [[ buffer(BufferIndexUniforms) ]],
                             texture2d<float, access::write>    dstTarget   [[ texture(TextureIndexRayTracingKernelDestinationTarget) ]])
{
    if (position.x < dstTarget.get_width() && position.y < dstTarget.get_height())
    {
        dstTarget.write(float4((float)position.y/(float)dstTarget.get_height(), (float)position.y/(float)dstTarget.get_height(), 1.0f, 1.0f), position);
    }
}
