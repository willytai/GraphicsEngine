//
//  Scene.mm
//  RayTracing
//
//  Created by Willy Tai on 6/29/23.
//

#import "Scene.h"
#import "Geometries/Triangles.h"
#import "Material/Materials.h"
#import "../Utils/Logger.h"

@implementation Scene
{
    DataAllocator*    _dataAllocator;
    
    // assets
    NSMutableArray<id<Geometry>>*       _geometries;
    NSMutableArray<GeometryInstance*>*  _instances;
}
GEN_CLASS_LOGGER("Scene.RayTracing.GraphisEngine", "Scene")

#pragma mark Access Functions

// overwritet synthesized get function to type cast it to NSArray
- (NSArray<id<Geometry>>*)geometries
{
    return _geometries;
}

// overwritet synthesized get function to type cast it to NSArray
- (NSArray<GeometryInstance*>*)instances
{
    return _instances;
}

#pragma mark Load Assets

- (nonnull instancetype)initWithBufferDataAllocator:(nonnull DataAllocator *)allocator
{
    if (self = [super init]) {
        _name = @"Default Scene";
        _dataAllocator = allocator;
        _geometries = [[NSMutableArray alloc] init];
        _instances = [[NSMutableArray alloc] init];
        [self _initScene];
    }
    return self;
}


- (void)_initScene
{
    // setup a triangle geometry
    Triangles* triangleGeometry = [[Triangles alloc] initWithDataAllocator:_dataAllocator];
    [_geometries addObject:triangleGeometry];

    // add a cube mesh
    // [triangleGeometry addCubeWithMaterialID:DefaultMaterial.MaterialID];

    // add a icosphere mesh
    [triangleGeometry addIcosphereWithSubdivisions:3 MaterialID:DefaultMaterial.MaterialID];

    // create one instance of the cube mesh
    GeometryInstance* testMesh = [[GeometryInstance alloc] initWithGeometry:triangleGeometry
                                                                  Transform:mathutil::float4x4()];
    [_instances addObject:testMesh];

    LOG_INFO("%@ initialized", _name);
}

- (void)upload {
    for (id<Geometry> geometry in _geometries) {
        [geometry uploadBuffers];
    }
}

@end
