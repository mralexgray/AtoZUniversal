//
//  RectLikeTests.m
//  AtoZ
//
//  Created by Alex Gray on 5/4/14.
//  Copyright (c) 2014 mrgray.com, inc. All rights reserved.
//

@import XCTest;
@import AtoZUniversal;

_XCTCase(RectLikeTests) { NSWindow *w; AZR *azr; CAL* l; NSV* v; }

_XCTUp(

  w   = [NSW x:100 y:100 w:200 h:200];

  azr = [AZR withRect:_Rect_ {100, 100, 200, 200}];

  v   = [NSV rectLike:@100,@100,@200,@200, nil]; // Nice factory method for all RectLike Objects!

  l   = [CAL withRect: AZRectOffsetFromDim(AZRectFromDim(200),100)];

  [@[w, azr, v, l] do:^(id obj) {
    XCTAssertNotNil(obj, @"test obects should exist, but %@ didnt", [obj className]);
  }];
)

#define TesteeWas @"%@ was %f", [_NObj_ testee className]

- (void) miniSuite:(NSO<RectLike>*)testee {

  XCTAssertTrue([testee respondsToString:@"frame"], @"must respond!");
  XCTAssertTrue(NSEqualRects(testee.frame,_Rect_ {100, 100, 200, 200}), "Test rect:%@!", NSStringFromRect(testee.frame));

  XCTAssertTrue(testee.width     == 200,   TesteeWas, testee.width);
  if (testee.width    != 200) [NSException raise:@"oh girl" format:@""];
  XCTAssertTrue(testee.height    == 200,   TesteeWas, testee.height);
  XCTAssertTrue(testee.h         == 200,   TesteeWas, testee.h);
  XCTAssertTrue(testee.w         == 200,   TesteeWas, testee.w);
  XCTAssertTrue(testee.x         == 100,   TesteeWas, testee.x);
  XCTAssertTrue(testee.y         == 100,   TesteeWas, testee.y);
  XCTAssertTrue(testee.maxX      == 300,   TesteeWas, testee.maxX);
  XCTAssertTrue(testee.maxY      == 300,   TesteeWas, testee.maxY);
  XCTAssertTrue(testee.area      == 40000, TesteeWas, testee.area);
  XCTAssertTrue(testee.perimeter == 800,   TesteeWas, testee.perimeter);
}

_XCTest(ExistenceAndEquality,

  XCTAssertTrue(w && azr && v && l, @"none may be nil!");
  XCTAssertTrue(NSEqualRects(w.r, azr.r), @"%@ %@", AZString(w.r),AZString(azr.r));
  XCTAssertTrue(NSEqualRects(v.r, azr.r), @"%@ %@", AZString(v.r),AZString(azr.r));
  XCTAssertTrue(NSEqualRects(v.r, l.r),   @"%@ %@", AZString(v.r),AZString(l.r));

   XCTAssertTrue(AZEqualRects(w.r, azr.r, v.r, l.r), @"%@ %@ %@ %@",
        AZString(w.r),AZString(azr.r),AZString(v.r),AZString(l.r));
)

_XCTest( WindowConformance,  [self miniSuite:w];    )
_XCTest( LayerConformance,   [self miniSuite:l];    )
_XCTest( ViewConformance,    [self miniSuite:v];    )
_XCTest( AZRConformance,     [self miniSuite:azr];  )


_XCTest(Supeframe,

  [w setSuperframe:AZScreenFrameUnderMenu()];

  XCTAssertTrue(w.insideEdge &
                  AZTop | AZRgt,
                  @"should be at bottom left, was %@",
                  AZAlign2Text(w.insideEdge)
  );
//  printf("\n\n%s\n\n%s", w.insideEdgeHex.UTF8String, AZAlignByHex().cDesc);
//  printf("\n\n%s\n\n%s", w.insideEdgeHex.UTF8String, AZAlignByValue().cDesc);

)

_XCTest(Iteration,  __block int ctr = 0;

  [AZRBy(4,4) iterate:^(_Cord p) {

    dispatch_uno(

      XCTAssert(NSEqualPoints(p, NSZeroPoint), @"First iteration should be 0,0, was %@", NSStringFromPoint(p));
    );

    if (ctr++ == 16) XCTAssert(NSEqualPoints(AZPt(4,4), p), @"last pt fhould be 4,4?");
  }];
  XCTAssert(ctr == 16, @"should iterate 16 times., got %i", ctr);
)

￭
