//
//  Submesh.h
//  RayTracing
//
//  Created by Willy Tai on 5/20/23.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MeshBuffer.h"

NS_ASSUME_NONNULL_BEGIN

@interface Submesh : NSObject

/// self-explanatory
@property (nonatomic, readonly) MTLPrimitiveType primitiveType;

/// self-explanatory
@property (nonatomic, readonly) NSUInteger indexCount;

/// self-explanatory
@property (nonatomic, readonly) MTLIndexType indexType;

/// the index buffer that contains the indices for the submesh
/// request an index buffer from the allocator
@property (nonatomic, readonly, nonnull) MeshBuffer* indexBuffer;

/// simple initialization
- (instancetype)initWithPrimitiveType:(MTLPrimitiveType)primitiveType
                            IndexType:(MTLIndexType)indexType
                           IndexCount:(NSUInteger)indexCount
                          IndexBuffer:(MeshBuffer*)indexBuffer;

@end

NS_ASSUME_NONNULL_END
