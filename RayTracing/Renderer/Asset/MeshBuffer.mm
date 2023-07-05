//
//  MeshBuffer.m
//  RayTracing
//
//  Created by Willy Tai on 5/20/23.
//

#import "MeshBuffer.h"

@implementation MeshBuffer

- (instancetype)initWithDevice:(id<MTLDevice>)device
                          Size:(NSUInteger)size
                   BufferIndex:(BufferIndex)bufferIndex
                       Options:(MTLResourceOptions)options
                                 Label:(NSString*)label {
    if (self = [super init]) {
        // init metal buffer
        _buffer = [device newBufferWithLength:size
                                      options:options];
        // offset is always zero for initialization
        _offset = 0;
        _bufferIndex = (NSUInteger)bufferIndex;
        _buffer.label = label;
    }
    return self;
}

- (nonnull instancetype)initWithDevice:(nonnull id<MTLDevice>)device
                                  Data:(nonnull const void*)data
                                  Size:(NSUInteger)size
                           BufferIndex:(BufferIndex)bufferIndex
                               Options:(MTLResourceOptions)options
                                 Label:(NSString*)label {
    if (self = [super init]) {
        // init metal buffer
        _buffer = [device newBufferWithBytes:data
                                      length:size
                                     options:options];
        // offset is always zero for initialization
        _offset = 0;
        _bufferIndex = (NSUInteger)bufferIndex;
        _buffer.label = label;
    }
    return self;
}

- (nonnull instancetype)initWithMTLBuffer:(nonnull id<MTLBuffer>)buffer
                                   Offset:(NSUInteger)offset
                              BufferIndex:(BufferIndex)bufferIndex
{
    if (self = [super init]) {
        _buffer = buffer;
        _offset = offset;
        _bufferIndex = bufferIndex;
    }
    return self;
}

- (void)addData:(nonnull const void*)data
           Size:(NSUInteger)size {
    memcpy((char*)_buffer.contents + _offset, data, size);
    // didModifyRange does not need to be called when the storage mode is shared
    // [_buffer didModifyRange:NSRange{_offset, size}];
    _offset += size;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    MeshBuffer* copy = [MeshBuffer new];
    [copy setBuffer:_buffer];
    [copy setOffset:_offset];
    [copy setBufferIndex:_bufferIndex];
    return copy;
}

#pragma mark For NSCopying

- (void)setBuffer:(id<MTLBuffer> _Nonnull)buffer {
    _buffer = buffer;
}
- (void)setOffset:(NSUInteger)offset {
    _offset = offset;
}
- (void)setBufferIndex:(NSUInteger)bufferIndex {
    _bufferIndex = bufferIndex;
}

@end
