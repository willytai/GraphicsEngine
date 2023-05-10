//
//  Renderer.h
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>

// Our platform independent renderer class.   Implements the MTKViewDelegate protocol which
//   allows it to accept per-frame update and drawable resize callbacks.
@interface Renderer : NSObject <MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

/// mouse scrolled event, calls the camera's 'onScrolled'
- (void)onScrolled:(float)deltaY;

@end

