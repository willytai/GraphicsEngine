//
//  GeometriesTests.mm
//  RayTracingTests
//
//  Created by Willy Tai on 6/10/23.
//

#import <XCTest/XCTest.h>
#import "Triangles.h"


uint32_t MTLIndexType2Size(MTLIndexType indexType) {
    switch (indexType) {
        case MTLIndexTypeUInt16: return sizeof(uint16_t);
        case MTLIndexTypeUInt32: return sizeof(uint32_t);
        default: XCTAssert(false, @"Unrecognized MTLIndexType: %lu", indexType);
    }
    return 0xffffff;
}


@interface GeometriesTests : XCTestCase

@property Triangles*    triangles;

@end

@implementation GeometriesTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _triangles = [[Triangles alloc] init];
    [_triangles addIcosphereWithSubdivisions:3 MaterialID:0];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testIndexTypeMatches {
    // We want to make sure that index type and index type size matches.
    XCTAssert(self.triangles.indexTypeSize == MTLIndexType2Size(self.triangles.indexType),
              @"\nThe index type and sizeof the index type doesn't match.\n"
              @"Did you forgot to update -[Triangles indexType] after changing TriangleIndexType or vice versa in Triangles.h?");
}

- (void)testIcosphere {
    // All the indices in the icospehre should be used exactly 6 times
    // except for the first 12 generated in subdivision 0, which should be 5.
    TriangleTestData::IcosphereTestData testData = self.triangles.testData.icosphere;
    XCTAssert(testData.subdivisions> 0, @"Subdivision 0 is trivial, test with subdivision > 0.");
    for (const auto& [idx, freq] : testData.indexAccessFrequency) {
        XCTAssert(freq == 6 || freq == 5 && testData.indexSub0.find(idx) != testData.indexSub0.end(),
                  @"vertex (%.6f, %.6f, %.6f) at index %d was used %d times ( != 6 ), something' wrong.",
                  ((float*)&testData.positions->at(idx))[0],
                  ((float*)&testData.positions->at(idx))[1],
                  ((float*)&testData.positions->at(idx))[2],
                  idx,
                  freq);
    }
}

@end
