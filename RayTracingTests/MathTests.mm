//
//  MathTests.mm
//  MathTests
//
//  Created by Willy Tai on 5/31/23.
//

#import <XCTest/XCTest.h>
#import "Math.hpp"
#import "Coordinates.hpp"
#import "CompareUtils.hpp"

@interface MathTests : XCTestCase

@end

@implementation MathTests

- (void)testMatrixSetup {
    // Testing if perspective projection and view matrix are setup properly.
    // Matrices are column-majored.
    simd_float4x4 proj = mathutil::perspective(45.0f, 1280.0f/760.0f, 0.1f, 1000.0f);
    simd_float4x4 view = mathutil::view((simd_float3){0.0f, 0.0f, 10.f}, WORLD_SPACE_ORIGIN, WORLD_SPACE_UP);
    
    // The projection matrix should be
    //    [[1.433439, 0.000000,  0.000000,  0.000000] 
    //     [0.000000, 2.414213,  0.000000,  0.000000] 
    //     [0.000000, 0.000000, -1.000100, -1.000000] 
    //     [0.000000, 0.000000, -0.100010,  0.000000]]
    float* ptr = (float*)&proj;
    XCTAssertTrue(test::fequal(ptr[0],   1.433439f), @"Expected %.6f, got %.6f.",  1.433439f, ptr[0]);
    XCTAssertTrue(test::fequal(ptr[1],   0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[1]);
    XCTAssertTrue(test::fequal(ptr[2],   0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[2]);
    XCTAssertTrue(test::fequal(ptr[3],   0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[3]);
    XCTAssertTrue(test::fequal(ptr[4],   0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[4]);
    XCTAssertTrue(test::fequal(ptr[5],   2.414213f), @"Expected %.6f, got %.6f.",  2.414213f, ptr[5]);
    XCTAssertTrue(test::fequal(ptr[6],   0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[6]);
    XCTAssertTrue(test::fequal(ptr[7],   0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[7]);
    XCTAssertTrue(test::fequal(ptr[8],   0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[8]);
    XCTAssertTrue(test::fequal(ptr[9],   0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[9]);
    XCTAssertTrue(test::fequal(ptr[10], -1.000100f), @"Expected %.6f, got %.6f.", -1.000100f, ptr[10]);
    XCTAssertTrue(test::fequal(ptr[11], -0.100010f), @"Expected %.6f, got %.6f.", -0.100010f, ptr[11]);
    XCTAssertTrue(test::fequal(ptr[12],  0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[12]);
    XCTAssertTrue(test::fequal(ptr[13],  0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[13]);
    XCTAssertTrue(test::fequal(ptr[14], -1.000000f), @"Expected %.6f, got %.6f.", -1.000000f, ptr[14]);
    XCTAssertTrue(test::fequal(ptr[15],  0.000000f), @"Expected %.6f, got %.6f.",  0.000000f, ptr[15]);
    
    // The view matrix should be
    //    [[ 1.000000,  0.000000,   0.000000, 0.000000]
    //     [ 0.000000,  1.000000,   0.000000, 0.000000]
    //     [ 0.000000,  0.000000,   1.000000, 0.000000]
    //     [-0.000000, -0.000000, -10.000000, 1.000000]]
    ptr = (float*)&view;
    XCTAssertTrue(test::fequal(ptr[0],    1.00000f), @"Expected %.6f, got %.6f.",   1.00000f, ptr[0]);
    XCTAssertTrue(test::fequal(ptr[1],    0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[1]);
    XCTAssertTrue(test::fequal(ptr[2],    0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[2]);
    XCTAssertTrue(test::fequal(ptr[3],    0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[3]);
    XCTAssertTrue(test::fequal(ptr[4],    0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[4]);
    XCTAssertTrue(test::fequal(ptr[5],    1.00000f), @"Expected %.6f, got %.6f.",   1.00000f, ptr[5]);
    XCTAssertTrue(test::fequal(ptr[6],    0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[6]);
    XCTAssertTrue(test::fequal(ptr[7],    0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[7]);
    XCTAssertTrue(test::fequal(ptr[8],    0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[8]);
    XCTAssertTrue(test::fequal(ptr[9],    0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[9]);
    XCTAssertTrue(test::fequal(ptr[10],   1.00000f), @"Expected %.6f, got %.6f.",   1.00000f, ptr[10]);
    XCTAssertTrue(test::fequal(ptr[11], -10.00000f), @"Expected %.6f, got %.6f.", -10.00000f, ptr[11]);
    XCTAssertTrue(test::fequal(ptr[12],   0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[12]);
    XCTAssertTrue(test::fequal(ptr[13],   0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[13]);
    XCTAssertTrue(test::fequal(ptr[14],   0.00000f), @"Expected %.6f, got %.6f.",   0.00000f, ptr[14]);
    XCTAssertTrue(test::fequal(ptr[15],   1.00000f), @"Expected %.6f, got %.6f.",   1.00000f, ptr[15]);
}

@end
