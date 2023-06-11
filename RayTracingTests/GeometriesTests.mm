//
//  GeometriesTests.mm
//  RayTracingTests
//
//  Created by Willy Tai on 6/10/23.
//

#import <XCTest/XCTest.h>
#import "GeometryObj.hpp"


uint32_t GeometryIndexType2Size(GeometryIndexType indexType) {
    switch (indexType) {
        case GeometryIndexType::UInt16: return sizeof(uint16_t);
        case GeometryIndexType::UInt32: return sizeof(uint32_t);
        default: XCTAssert(false, @"Did you added a new GeometryIndexType in GeometryObj.hpp and forgot to reflect the update here?");
    }
    return 0xffffff;
}


@interface GeometriesTests : XCTestCase

@property GeometryObj* testObj;

@end

@implementation GeometriesTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testObj = new GeometryObj;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    delete self.testObj;
}

- (void)testIndexTypeMatches {
    // We want to make sure that index type and index type size matches
    XCTAssert(self.testObj->indexTypeSize() == GeometryIndexType2Size(self.testObj->indexType()),
              @"\nThe index type and sizeof the index type doesn't match.\n"
              @"Did you forgot to update GeometryIndexType after changing RawIndexType or vice versa in GeometryObj.hpp?");
}

@end
