//
//  DataAllocator.h
//  RayTracing
//
//  Created by Willy Tai on 6/29/23.
//

#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

// A wrapper class for resource allocation
@interface DataAllocator : NSObject

@property(nonnull, nonatomic, readonly) id<MTLDevice> device;

/// information of the device will be stored inside this class
- (instancetype)initWithDevice:(id<MTLDevice>)device;

/// simple wrapper for generating managed buffers, might want to add some more functionality to this in the future
- (id<MTLBuffer>)newManagedBufferWithElementSize:(NSUInteger)elementSize
                                    ElementCount:(NSUInteger)elementCount;

@end

NS_ASSUME_NONNULL_END
