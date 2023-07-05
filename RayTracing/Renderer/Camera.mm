//
//  Camera.m
//  RayTracing
//
//  Created by Willy Tai on 5/3/23.
//

#import <Cocoa/Cocoa.h>
#import "Camera.h"
#import "Geometries/Coordinates.hpp"
#import "../App/InputCodes.h"
#import "../Utils/Logger.h"
#import "../Utils/Math.hpp"


#pragma mark Constants
/// the cutoff distance to the focal point for zooming
const float MINDIST = 3.0f;
const float MAXDIST = 1000.0f;


#pragma mark Key Down Flags
typedef NS_OPTIONS(unsigned short, KeyDownFlags) {
    A_KEY_FLAG = 1 << 0,
    D_KEY_FLAG = 1 << 2,
    S_KEY_FLAG = 1 << 1,
    W_KEY_FLAG = 1 << 3,
    Q_KEY_FLAG = 1 << 4,
    E_KEY_FLAG = 1 << 5,
    NO_KEYS_DOWN = 0,
};


@implementation Camera
{
    /// the distance to the focal point
    /// need this param for scrolling events
    float _distance;

    /// orientation of the camera defined by pitch and yaw
    float _pitch;
    float _yaw;

    /// indicates whether the projection matrix needs to be recalculated
    bool _updateProjection;

    /// indicates whether the view matrix needs to be recalculated
    bool _updateView;

    /// indicates whether the left mouse button is held down
    bool _leftMouseDown;

    /// the position of the mouse for the previous frame
    simd_float2 _mousePosition;

    /// the keys that are currently held down
    /// we are only interested in 'w', 'a', 's', 'd'
    KeyDownFlags _keyDownFlags;
}
GEN_CLASS_LOGGER("renderer.raytracing.graphicsengine", "camera")

- (nonnull instancetype)initWithParams:(CameraParams)params {
    if (self = [super init]) {
        _params = params;
        _position = mathutil::float3(0.0f, 0.0f, 10.0f);
        _focalPoint = WORLD_SPACE_ORIGIN;
        _distance = mathutil::length(_position - _focalPoint);
        _pitch = 0.0f;
        _yaw = 0.0f;

        [self _calculateProjectionMatrix];
        [self _calculateViewMatrix];
        [self _calculateViewProjectionMatrix];

        _updateProjection = NO;
        _updateView = NO;
        _leftMouseDown = NO;
        _keyDownFlags = NO_KEYS_DOWN;
    }
    return self;
}

- (void)onUpdateWithDeltaTime:(TimeStep)deltaTime {
    if (_leftMouseDown) {
        simd_float2 newMousePosition = mathutil::float2(NSEvent.mouseLocation.x,
                                                        NSEvent.mouseLocation.y);
        simd_float2 deltaMouse = newMousePosition - _mousePosition;
        _mousePosition = newMousePosition;
        [self _rotateWithDeltaMouse:deltaMouse
                      WithDeltaTime:deltaTime];
    }
    if (_keyDownFlags) {
        [self _translateWithDeltaTime:deltaTime];
    }

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

- (void)onLeftMouseDown {
    _leftMouseDown = YES;

    // also reset the mouse position
    _mousePosition = mathutil::float2(NSEvent.mouseLocation.x,
                                      NSEvent.mouseLocation.y);
}

- (void)onLeftMouseUp {
    _leftMouseDown = NO;
}

- (void)onKeyDown:(unsigned short)keyCode {
    switch (keyCode) {
        case Key::W:
        {
            _keyDownFlags |= W_KEY_FLAG;
            break;
        }
        case Key::A:
        {
            _keyDownFlags |= A_KEY_FLAG;
            break;
        }
        case Key::S:
        {
            _keyDownFlags |= S_KEY_FLAG;
            break;
        }
        case Key::D:
        {
            _keyDownFlags |= D_KEY_FLAG;
            break;
        }
        case Key::Q:
        {
            _keyDownFlags |= Q_KEY_FLAG;
            break;
        }
        case Key::E:
        {
            _keyDownFlags |= E_KEY_FLAG;
            break;
        }
        default:
            LOG_ERROR("@%s, keycode: %u unrecognized.", __PRETTY_FUNCTION__, keyCode);
            break;
    }
}

- (void)onKeyUp:(unsigned short)keyCode {
    switch (keyCode) {
        case Key::W:
        {
            _keyDownFlags &= ~W_KEY_FLAG;
            break;
        }
        case Key::A:
        {
            _keyDownFlags &= ~A_KEY_FLAG;
            break;
        }
        case Key::S:
        {
            _keyDownFlags &= ~S_KEY_FLAG;
            break;
        }
        case Key::D:
        {
            _keyDownFlags &= ~D_KEY_FLAG;
            break;
        }
        case Key::Q:
        {
            _keyDownFlags &= ~Q_KEY_FLAG;
            break;
        }
        case Key::E:
        {
            _keyDownFlags &= ~E_KEY_FLAG;
            break;
        }
        default:
            LOG_ERROR("@%s, keycode: %u unrecognized.", __PRETTY_FUNCTION__, keyCode);
            break;
    }
}

#pragma mark Private Functions

- (void)_calculateProjectionMatrix {
    _projMat = mathutil::perspective(_params.fov,
                                     _params.width/_params.height,
                                     _params.nearClip,
                                     _params.farClip);
}

- (void)_calculateViewMatrix {
    _viewMat = mathutil::view(_position, _focalPoint, WORLD_SPACE_UP);
}

- (void)_calculateViewProjectionMatrix {
    _viewProjMat = mathutil::matmul(_viewMat, _projMat);
}

- (float)_zoomSpeed {
    /// could be better
    /// leaving the fine-tuning work for the future
    return std::fmin(100.0f,
                     std::pow(_distance, 2) * 0.0005f);
}

- (void)_rotateWithDeltaMouse:(simd_float2)deltaMouse
                WithDeltaTime:(TimeStep)deltaTime {
    static const float speed = 2e-5f;
    float ms = deltaTime.ms();
    _pitch -= deltaMouse.y * speed * ms;
    _yaw += deltaMouse.x * speed * ms;
    simd_quatf orientation = mathutil::quat(_pitch, _yaw, 0.0f);
    simd_float3 forward = mathutil::rotate(orientation, WORLD_SPACE_FORWARD);
    _focalPoint = _position + _distance * forward;
    _updateView = YES;
}

- (void)_translateWithDeltaTime:(TimeStep)deltaTime {
    static const float speed = 5e-3f;
    float deltaDist = deltaTime.ms() * speed;
    simd_float3 translation = mathutil::float3();
    if (_keyDownFlags & A_KEY_FLAG) {
        // left
        translation += deltaDist * WORLD_SPACE_LEFT;
    }
    if (_keyDownFlags & D_KEY_FLAG) {
        // right
        translation += deltaDist * WORLD_SPACE_RIGHT;
    }
    if (_keyDownFlags & W_KEY_FLAG) {
        // forward
        translation += deltaDist * WORLD_SPACE_FORWARD;
    }
    if (_keyDownFlags & S_KEY_FLAG) {
        // backward
        translation += deltaDist * WORLD_SPACE_BACKWARD;
    }
    if (_keyDownFlags & Q_KEY_FLAG) {
        // up
        translation += deltaDist * WORLD_SPACE_UP;
    }
    if (_keyDownFlags & E_KEY_FLAG) {
        // down
        translation += deltaDist * WORLD_SPACE_DOWN;
    }
    _position += translation;
    _focalPoint += translation;
    _updateView = YES;
}

@end
