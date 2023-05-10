//
//  Renderer.h
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import "InputCodes.h"

// Our platform independent renderer class.   Implements the MTKViewDelegate protocol which
//   allows it to accept per-frame update and drawable resize callbacks.
@interface Renderer : NSObject <MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

/// mouse scrolled event, calls the camera's 'onScrolled'
- (void)onScrolled:(float)deltaY;

/// mouse down event, calls the camera's 'onMouseDown'
- (void)onMouseDown:(MouseButton)button;

/// mouse up event, calls the camera's 'onMouseUp'
/// this will be called only when the LEFT mouse button is up
- (void)onMouseUp;

@end

