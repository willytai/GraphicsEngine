//
//  Camera.m
//  RayTracing
//
//  Created by Willy Tai on 5/3/23.
//

#import "Camera.h"
#import "Math.hpp"

@implementation Camera
{
    // private members
}

- (nonnull instancetype)initWithParams:(CameraParams)params {
    if (self = [super init]) {
        _params = params;
        _position = simd_make_float3(0.0f, 0.0f, -10.0f);
        _focalPoint = simd_make_float3(0.0f, 0.0f, 0.0f);
        [self _calculateProjectionMatrix];
        [self _calculateViewMatrix];
        [self _calculateViewProjectionMatrix];
    }
    return self;
}

- (void)onUpdateWithDeltaTime:(TimeStep)deltaTime {
}

- (void)onResizeWidth:(float)width Height:(float)height {
    _params.width = width;
    _params.height = height;
    [self _calculateProjectionMatrix];
}

#pragma mark Private Functions

- (void)_calculateProjectionMatrix {
    _projMat = mathutil::perspective(_params.fov,
                                     _params.width/_params.height,
                                     _params.nearClip,
                                     _params.farClip);
}

- (void)_calculateViewMatrix {
    _viewMat = mathutil::view(_position, _focalPoint, simd_make_float3(0.0f, 1.0f, 0.0f));
}

- (void)_calculateViewProjectionMatrix {
    _viewProjMat = mathutil::matmul(_projMat, _viewMat);
}

@end
