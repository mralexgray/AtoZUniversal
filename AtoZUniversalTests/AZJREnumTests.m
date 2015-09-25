//
//  JREnumTests.m
//  AtoZ
//
//  Created by Alex Gray on 2/19/14.
//  Copyright (c) 2014 mrgray.com, inc. All rights reserved.
//

@import XCTest;
@import AtoZUniversal;

_EnumKind(SplitEnumWith1ConstantSansExplicitValues, SplitEnumWith1ConstantSansExplicitValues_Constant1);
_EnumKind(SplitEnumWith1ConstantWithExplicitValues, SplitEnumWith1ConstantWithExplicitValues_Constant1 = 42);
_EnumKind(TestClassState,   TestClassState_Closed,
                                TestClassState_Opening,
                                TestClassState_Open,
                                TestClassState_Closing  );


_EnumPlan(SplitEnumWith1ConstantSansExplicitValues);
_EnumPlan(SplitEnumWith1ConstantWithExplicitValues);
_EnumPlan(TestClassState);

_Enum(EnumWith1ConstantSansExplicitValues, EnumWith1ConstantSansExplicitValues_Constant1);
_Enum(EnumWith1ConstantWithExplicitValues, EnumWith1ConstantWithExplicitValues_Constant1 = 42);

_XCTCase(AZJREnumTests)  {    EnumWith1ConstantSansExplicitValues       a;
                              SplitEnumWith1ConstantSansExplicitValues  b;
                              SplitEnumWith1ConstantWithExplicitValues  c; }

_XCTUp( a = 0; b = 0; c = 42; )

_XCTest(Example,

  XCTAssertTrue(EnumWith1ConstantSansExplicitValuesxLbl().count == 1, @"");
  XCTAssertEqualObjects([EnumWith1ConstantSansExplicitValuesxLbl() objectForKey:@"EnumWith1ConstantSansExplicitValues_Constant1"], @0, @"");

  XCTAssertTrue(EnumWith1ConstantSansExplicitValuesxVal().count == 1, @"");
  XCTAssertEqualObjects(EnumWith1ConstantSansExplicitValuesxVal()[@0], @"EnumWith1ConstantSansExplicitValues_Constant1", @"");


  XCTAssertTrue(EnumWith1ConstantSansExplicitValues_Constant1 == a, @"");
  XCTAssertTrue( [@"EnumWith1ConstantSansExplicitValues_Constant1" isEqualToString:EnumWith1ConstantSansExplicitValues2Text(a)], @"");
  XCTAssertTrue( EnumWith1ConstantSansExplicitValues4Text(EnumWith1ConstantSansExplicitValues2Text(EnumWith1ConstantSansExplicitValues_Constant1), &a), @"");
  XCTAssertTrue(EnumWith1ConstantSansExplicitValues_Constant1 == a, @"");

  a++;
  XCTAssertTrue([@"<unknown EnumWith1ConstantSansExplicitValues: 1>" isEqualToString:EnumWith1ConstantSansExplicitValues2Text(a)], @"");
  XCTAssertTrue(!EnumWith1ConstantSansExplicitValues4Text(@"foo", &a), @"");

)
_XCTest(splitEnumTests,

  XCTAssertTrue(SplitEnumWith1ConstantSansExplicitValues_Constant1 == b, @"");
  XCTAssertTrue([@"SplitEnumWith1ConstantSansExplicitValues_Constant1" isEqualToString:SplitEnumWith1ConstantSansExplicitValues2Text(b)], @"");
  XCTAssertTrue(SplitEnumWith1ConstantSansExplicitValues4Text(SplitEnumWith1ConstantSansExplicitValues2Text(SplitEnumWith1ConstantSansExplicitValues_Constant1), &b), @"");
  XCTAssertTrue(SplitEnumWith1ConstantSansExplicitValues_Constant1 == b, @"");
  b++;
  XCTAssertTrue([@"<unknown SplitEnumWith1ConstantSansExplicitValues: 1>" isEqualToString:SplitEnumWith1ConstantSansExplicitValues2Text(b)], @"");
  XCTAssertTrue(!SplitEnumWith1ConstantSansExplicitValues4Text(@"foo", &b), @"");
)
_XCTest(Explicit,

  XCTAssertTrue(SplitEnumWith1ConstantWithExplicitValues_Constant1 == c, @"");
  XCTAssertTrue([@"SplitEnumWith1ConstantWithExplicitValues_Constant1" isEqualToString:SplitEnumWith1ConstantWithExplicitValues2Text(c)], @"");
  XCTAssertTrue(SplitEnumWith1ConstantWithExplicitValues4Text(SplitEnumWith1ConstantWithExplicitValues2Text(SplitEnumWith1ConstantWithExplicitValues_Constant1), &c), @"");
  XCTAssertTrue(SplitEnumWith1ConstantWithExplicitValues_Constant1 == c, @"");
  c++;
  XCTAssertTrue([@"<unknown SplitEnumWith1ConstantWithExplicitValues: 43>" isEqualToString:SplitEnumWith1ConstantWithExplicitValues2Text(c)], @"");;
  XCTAssertTrue(!SplitEnumWith1ConstantWithExplicitValues4Text(@"foo", &c), @"");
)


/* reference 

_EnumKind( AZAlign, AZAlignUnset     		= 0x00000000,
                        AZAlignLeft         = 0x00000001,
                        AZAlignRight      	= 0x00000010,
                        AZAlignTop	        = 0x00000100,
                        AZAlignBottom       = 0x00001000,
                        AZAlignTopLeft      = 0x00000101,
                        AZAlignBottomLeft		= 0x00001001,
                        AZAlignTopRight   	= 0x00000110,
                        AZAlignBottomRight  = 0x00001010,
                        AZAlignCenter    		= 0x11110000,
                        AZAlignOutside  		= 0x00001111,
                        AZAlignAutomatic		= 0x11111111, );

*/

_XCTest(Options, AZA unset;

  XCTAssertEqual( unset, AZUnset, @"uninitialized Alignments should be Unset!") ___

  XCTAssertEqual( unset, (AZA)NO, @"aka NO") ___

  XCTAssertEqual( AZAlignxVal().count, _UInt_ 15, @"Should be 12 positions");

  XCTAssertTrue( (AZAlignTop | AZAlignLeft) == AZAlignTopLeft, @"Combining Bitmasks works");

  XCTAssertTrue( (AZAlignTop | AZAlignLeft | AZAlignRight | AZAlignBottom) == AZAlignCenter, @"Allsides totals center");
  
//  AZAlignByValue().allKeys.nextObject
  XCTAssertFalse ( AZAlignOutside & (AZAlignTop|AZAlignLeft|AZAlignRight|AZAlignBottom), @"No sides is outside.");

  XCTAssertTrue  ( AZAlignTop&AZAlignCenter,   @"Align Cneter includes top");

)
//- (void) testDecoding { AZA zTop = AZTop;
//
//  STAssertTrue( AZAIsVertical ), <#description, ...#>
//
//}

@end
