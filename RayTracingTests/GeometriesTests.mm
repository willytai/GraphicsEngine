//
//  GeometriesTests.mm
//  RayTracingTests
//
//  Created by Willy Tai on 6/10/23.
//

#import <XCTest/XCTest.h>
#import "GeometryObj.hpp"
#import "Icosphere.hpp"


uint32_t GeometryIndexType2Size(GeometryIndexType indexType) {
    switch (indexType) {
        case GeometryIndexType::UInt16: return sizeof(uint16_t);
        case GeometryIndexType::UInt32: return sizeof(uint32_t);
        default: XCTAssert(false, @"Did you added a new GeometryIndexType in GeometryObj.hpp and forgot to reflect the update here?");
    }
    return 0xffffff;
}


@interface GeometriesTests : XCTestCase

@property GeometryObj* geoObj;
@property Icosphere*   icosphere;

@end

@implementation GeometriesTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.geoObj = new GeometryObj;
    self.icosphere = new Icosphere(1.0f, 3);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    delete self.geoObj;
    delete self.icosphere;
}

- (void)testIndexTypeMatches {
    // We want to make sure that index type and index type size matches.
    XCTAssert(self.geoObj->indexTypeSize() == GeometryIndexType2Size(self.geoObj->indexType()),
              @"\nThe index type and sizeof the index type doesn't match.\n"
              @"Did you forgot to update GeometryIndexType after changing RawIndexType or vice versa in GeometryObj.hpp?");
}

- (void)testIcosphere {
    // All the indices in the icospehre should be used exactly 6 times
    // except for the first 12 generated in subdivision 0, which should be 5.
    XCTAssert(self.icosphere->subdivision() > 0, @"Subdivision 0 is trivial, tests with subdivision > 0.");
    for (const auto& [idx, freq] : self.icosphere->testData.indexAccessFrequency) {
        XCTAssert(freq == 6 || freq == 5 && self.icosphere->testData.indexSub0.find(idx) != self.icosphere->testData.indexSub0.end(),
                  @"vertex (%.6f, %.6f, %.6f) at index %d was used %d times ( != 6 ), something' wrong.",
                  ((float*)&self.icosphere->positions()[idx])[0],
                  ((float*)&self.icosphere->positions()[idx])[1],
                  ((float*)&self.icosphere->positions()[idx])[2],
                  idx,
                  freq);
    }
}

@end
