//
//  Scene.h
//  RayTracing
//
//  Created by Willy Tai on 6/29/23.
//

#import "Geometries/Geometry.h"

NS_ASSUME_NONNULL_BEGIN

// The scene contains different types of geometries,
// instances of geometries.
@interface Scene : NSObject

/// the geometries (meshes)
@property(nonatomic, readonly) NSArray<id<Geometry>>*   geometries;

/// the instances of geometries (meshes with transform)
@property(nonatomic, readonly) NSArray<GeometryInstance*>*  instances;

/// name of the scene
@property(nonatomic, readonly) NSString*    name;

/// initializer
/// all data (instances, geometris) are allocated via the allcator
- (nonnull instancetype)initWithBufferDataAllocator:(DataAllocator*)allocator;

/// the function to call when all changes are complete and update is required
- (void)upload;

@end

NS_ASSUME_NONNULL_END
