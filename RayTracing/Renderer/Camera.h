//
//  Camera.h
//  RayTracing
//
//  Created by Willy Tai on 5/3/23.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "Timer.hpp"

NS_ASSUME_NONNULL_BEGIN


typedef struct CameraParams {
    float fov;
    float width;
    float height;
    float nearClip;
    float farClip;
} CameraParams;


/*!
 @abstract The camera class. Scroll to Zoom in/out. Hold down left mouse and drag to rotate.
 */
@interface Camera : NSObject

/// the parameters of the camera
@property (nonatomic, readonly) CameraParams params;

/// position of the camera
@property (nonatomic, readonly) simd_float3 position;

/// focal point of the camera
@property (nonatomic, readonly) simd_float3 focalPoint;

/// the view matrix
@property (nonatomic, readonly) simd_float4x4 viewMat;

/// the projection matrix
@property (nonatomic, readonly) simd_float4x4 projMat;

/// the view * projection matrix
@property (nonatomic, readonly) simd_float4x4 viewProjMat;

/// initializes the camera with CameraParams
- (nonnull instancetype)initWithParams:(CameraParams)params;

/// called very frame
- (void)onUpdateWithDeltaTime:(TimeStep)deltaTime;

/// when the view port resizes
/// projection matrix needs update
- (void)onResizeWidth:(float)width Height:(float)height;

/// Zoom in the camera
- (void)onScrolled:(float)deltaY;

/// Left mouse down, flag for rotation
- (void)onLeftMouseDown;

/// Left mouse up, un-flag for rotation
- (void)onLeftMouseUp;

/// Key down, move camera with 'w', 'a', 's', 'd'
- (void)onKeyDown:(unsigned short)keyCode;

/// Key up, un-flag the keys that are marked when 'onKeyDown' was called
- (void)onKeyUp:(unsigned short)keyCode;

@end

NS_ASSUME_NONNULL_END
