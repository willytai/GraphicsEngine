//
//  Camera.m
//  RayTracing
//
//  Created by Willy Tai on 5/3/23.
//

#import "Camera.h"
#import "Math.hpp"


/// the cutoff distance to the focal point for zooming
const float MINDIST = 3.0f;
const float MAXDIST = 1000.0f;


@implementation Camera
{
    /// the distance to the focal point
    /// need this param for scrolling events
    float _distance;

    /// indicates whether the projection matrix needs to be recalculated
    bool _updateProjection;

    /// indicates whether the view matrix needs to be recalculated
    bool _updateView;
}

- (nonnull instancetype)initWithParams:(CameraParams)params {
    if (self = [super init]) {
        _params = params;
        _position = mathutil::float3(0.0f, 0.0f, -20.0f);
        _focalPoint = mathutil::float3(0.0f, 0.0f, 0.0f);
        _distance = mathutil::length(_position - _focalPoint);

        [self _calculateProjectionMatrix];
        [self _calculateViewMatrix];
        [self _calculateViewProjectionMatrix];

        _updateProjection = NO;
        _updateView = NO;
    }
    return self;
}

- (void)onUpdateWithDeltaTime:(TimeStep)deltaTime {
    if (_updateProjection) [self _calculateProjectionMatrix];
    if (_updateView) [self _calculateViewMatrix];
    if (_updateProjection || _updateView) [self _calculateViewProjectionMatrix];
}

#pragma mark Event Callbacks

- (void)onResizeWidth:(float)width Height:(float)height {
    _params.width = width;
    _params.height = height;
    _updateProjection = YES;
}

- (void)onScrolled:(float)deltaY {
    /// update the position of the camera, the focal point stays unchanged
    float old = _distance;
    _distance -= deltaY * [self _zoomSpeed];
    _distance = std::fmax(MINDIST, _distance);
    _distance = std::fmin(MAXDIST, _distance);
    _position = _focalPoint + _distance / old * (_position - _focalPoint);
    _updateView = YES;
}

#pragma mark Private Functions

- (void)_calculateProjectionMatrix {
    _projMat = mathutil::perspective(_params.fov,
                                     _params.width/_params.height,
                                     _params.nearClip,
                                     _params.farClip);
}

- (void)_calculateViewMatrix {
    _viewMat = mathutil::view(_position, _focalPoint, mathutil::float3(0.0f, 1.0f, 0.0f));
}

- (void)_calculateViewProjectionMatrix {
    _viewProjMat = mathutil::matmul(_projMat, _viewMat);
}

- (float)_zoomSpeed {
    /// could be better
    /// leaving the fine-tuning work for the future
    return std::fmin(100.0f,
                     std::pow(_distance, 2) * 0.0005f);
}

@end
