//
//  Submesh.m
//  RayTracing
//
//  Created by Willy Tai on 5/20/23.
//

#import "Submesh.h"

@implementation Submesh

- (nonnull instancetype)initWithPrimitiveType:(MTLPrimitiveType)primitiveType
                                    IndexType:(MTLIndexType)indexType
                                   IndexCount:(NSUInteger)indexCount
                                  IndexBuffer:(nonnull MeshBuffer*)indexBuffer {
    if (self = [super init]) {
        _primitiveType = primitiveType;
        _indexType = indexType;
        _indexCount = indexCount;
        _indexBuffer = indexBuffer;
    }
    return self;
}

@end
