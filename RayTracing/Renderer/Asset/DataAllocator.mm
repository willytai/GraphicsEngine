//
//  DataAllocator.mm
//  RayTracing
//
//  Created by Willy Tai on 6/29/23.
//

#import "DataAllocator.h"

@implementation DataAllocator

- (nonnull instancetype)initWithDevice:(nonnull id<MTLDevice>)device {
    if (self = [super init]) {
        _device = device;
    }
    return self;
}

- (nonnull id<MTLBuffer>)newManagedBufferWithElementSize:(NSUInteger)elementSize ElementCount:(NSUInteger)elementCount {
    return [_device newBufferWithLength:elementSize*elementCount options:MTLResourceStorageModeManaged];
}

@end
