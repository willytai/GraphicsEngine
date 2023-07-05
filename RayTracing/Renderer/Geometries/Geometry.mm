//
//  Geometry.mm
//  RayTracing
//
//  Created by Willy Tai on 6/28/23.
//

#import "Geometry.h"

@implementation GeometryInstance

- (nonnull instancetype)initWithGeometry:(nonnull id<Geometry>)geometry Transform:(simd_float4x4)transform {
    if ((self = [super init])) {
        _geometry = geometry;
        _transform = transform;
    }
    return self;
}

@end
