//
//  MeshBuffer.h
//  RayTracing
//
//  Created by Willy Tai on 5/20/23.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "../Shader/ShaderTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface MeshBuffer : NSObject<NSCopying>

/// the underlying metal buffer
@property (nonatomic, readonly) id<MTLBuffer> buffer;

/// the offset where the data begins
@property (nonatomic, readonly) NSUInteger offset;

/// the buffer index that this buffer should be bound at if it is a vertex buffer
/// not important if it is an index buffer
@property (nonatomic, readonly) NSUInteger bufferIndex;

/// initializes the underlying metal buffer with 'size',  'bufferIndex', and 'option'
/// this initializes an empty metal buffer for data to be uploaded later
- (instancetype)initWithDevice:(id<MTLDevice>)device
                          Size:(NSUInteger)size
                   BufferIndex:(BufferIndex)bufferIndex
                       Options:(MTLResourceOptions)options
                         Label:(NSString*)label;

/// initializes metal buffer with some data
/// typically used for private storage buffer
- (instancetype)initWithDevice:(id<MTLDevice>)device
                          Data:(const void*)data
                          Size:(NSUInteger)size
                   BufferIndex:(BufferIndex)bufferIndex
                       Options:(MTLResourceOptions)options
                         Label:(NSString*)label;

/// a wrapper for a given MTLBuffer
- (nonnull instancetype)initWithMTLBuffer:(id<MTLBuffer>)buffer
                                   Offset:(NSUInteger)offset
                              BufferIndex:(BufferIndex)bufferIndex;

/// populate buffer with data
- (void)addData:(const void*)data
           Size:(NSUInteger)size;
@end

NS_ASSUME_NONNULL_END
