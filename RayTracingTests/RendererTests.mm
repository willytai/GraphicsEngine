//
//  RendererTests.mm
//  RayTracingTests
//
//  Created by Willy Tai on 6/10/23.
//

#import <XCTest/XCTest.h>
#import "Renderer.h"
#import "ShaderTypes.h"

@interface Renderer()
@property(nonatomic, readonly, nonnull) MTLVertexDescriptor* mtlVertexDescriptor;
- (void)_initVertexDescriptor;
@end

@interface RendererTests : XCTestCase

@property Renderer* renderer;

@end

@implementation RendererTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.renderer = [[Renderer alloc] init];
    [self.renderer _initVertexDescriptor];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testVertexDescriptor {
    // Test if the vertex descriptor has the correct value set.
    XCTAssertEqual(self.renderer.mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stride,  sizeof(VtxPositionType),
                   @"Vertex postion layout doesn't match. Expected stride to be %lu, got %lu.",
                   sizeof(VtxPositionType),
                   self.renderer.mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stride);

    XCTAssertEqual(self.renderer.mtlVertexDescriptor.layouts[BufferIndexMeshNormals].stride,  sizeof(VtxNormalType),
                   @"Vertex normal layout doesn't match. Expected stride to be %lu, got %lu.",
                   sizeof(VtxNormalType),
                   self.renderer.mtlVertexDescriptor.layouts[BufferIndexMeshNormals].stride);

    XCTAssertEqual(self.renderer.mtlVertexDescriptor.layouts[BufferIndexMeshMaterialIDs].stride,  sizeof(VtxMaterialIDType),
                   @"Vertex materialID layout doesn't match. Expected stride to be %lu, got %lu.",
                   sizeof(VtxMaterialIDType),
                   self.renderer.mtlVertexDescriptor.layouts[BufferIndexMeshMaterialIDs].stride);
}

@end
