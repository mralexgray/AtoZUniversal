//
//  CategoryTests.m
//  AtoZUniversal
//
//  Created by Alex Gray on 7/8/15.
//  Copyright © 2015 Alex Gray. All rights reserved.
//

#import <XCTest/XCTest.h>
@import AtoZUniversal;

@interface CategoryTests : XCTestCase

@end

@implementation CategoryTests

- (void)setUp {
    [super setUp];
}

- (void)testExample {

  _Text x = [Text dicksonParagraphWith:1];
  _List z = [Text dicksonPhrases];
  _List y = [Text dicksonisms];

  XCTAssertNotNil(x, @"should have one sentence.");
  XCTAssertNotNil(z, @"should have many phrases");
  XCTAssert(z.count >= 10, @"should have many phrases");
  XCTAssertNotNil(y, @"not sure what this is!");

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
