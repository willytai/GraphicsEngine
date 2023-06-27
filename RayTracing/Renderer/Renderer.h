//
//  Renderer.h
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import "../App/InputCodes.h"

typedef NS_ENUM(NSInteger, RendererMode)
{
    RendererModeRayTracing,
    RendererModeNormalRendering,

    RendererModeUndefined,
};

// Our platform independent renderer class.   Implements the MTKViewDelegate protocol which
//   allows it to accept per-frame update and drawable resize callbacks.
@interface Renderer : NSObject <MTKViewDelegate>

/// the rendering mode, currently supports ray tracing and normal rendering
@property(nonatomic, readonly) RendererMode rendererMode;

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

/// mouse scrolled event, calls the camera's 'onScrolled'
- (void)onScrolled:(float)deltaY;

/// mouse down event, calls the camera's 'onMouseDown'
- (void)onMouseDown:(MouseButton)button;

/// mouse up event, calls the camera's 'onMouseUp'
/// this will be called only when the LEFT mouse button is up
- (void)onMouseUp;

/// key down event, calls the camera's 'onKeyDown'
- (void)onKeyDown:(unsigned short)keyCode
     WithModifier:(NSUInteger)modifierFlags;

/// key up event, calls the camera's 'onKeyUp'
- (void)onKeyUp:(unsigned short)keyCode;

/// setting requires checks
- (void)setRendererMode:(RendererMode)rendererMode
               WithView:(nonnull MTKView*)view;

/// helper function to convert string to render mode
+ (RendererMode)getRendererModeFromString:(nonnull NSString*)mode;

@end

