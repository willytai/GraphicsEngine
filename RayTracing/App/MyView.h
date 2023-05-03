//
//  MyView.h
//  RayTracing
//
//  Created by Willy Tai on 5/3/23.
//

#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

// Simply overwrites the 'acceptFirstResponder' in MTKView to Yes
// so that key events can propagate.
@interface MyView : MTKView

@end

NS_ASSUME_NONNULL_END
