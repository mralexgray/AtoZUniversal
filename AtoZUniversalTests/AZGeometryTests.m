
@import XCTest;
@import AtoZUniversal;

#define GOOGLE_IP 173.194.123.46


_XCTCase(LocaleTests) { Locale * locale; _List props; }

_XCTUp(

)

_XCTest(MyLocale,

  locale  = [Locale localeOfIP:NET.externalIP];

  [Locale.properties each:^(id x){

    XCTAssertNotNil([locale vFK:x], @"Needs value for %@", x);
  }];

//  googleLocale = [Locale localeOfIP:GOOGLE_IP];
)
￭

//+ _Kind_ localeOfIP __Text_ ip ___
//
//+ _Dict_ flags ___
//
//@property (readonly) NSImage *flag;
//
//_CP _Text city, postal_code, zip_code, metro_code,
//          country_code, country_name, country_code3, country, continent_code,
//          region_code, region_name,
//          latitude, longitude, time_zone, timezone,
//          ip, asn, isp,  message, code, dma_code, area_code;

/*

_XCTest(PointIsInInsetRects,

  XCTAssertTrue  (AZPointIsInInsetRects(pt0, rect100, AZSizeFromDim(10)), @"{0, 0} SHOULD technically be inside insets of size {10,10} inside {0,0,100,100}");
  XCTAssertFalse (AZPointIsInInsetRects(AZPointFromDim(-10),rect100,AZSizeFromDim(10)), @"{-10, -10} should NOT be inside insets of size {10,10} inside {0,0,100,100}");
  XCTAssertFalse (AZPointIsInInsetRects(AZPointFromDim( 20),rect100,AZSizeFromDim(10)), @"{20,20} should NOT be in edges of size {10,10} inside {0,0,100,100}");
  XCTAssertThrows(AZPointIsInInsetRects(AZPointFromDim(101),rect100,AZSizeFromDim(100)), @"Should complain inset is too big!");
)
￭

_Enum(AZTestCase, AZTestFailed, AZTestPassed, AZTestUnset, AZTestNoFailures);

typedef  void (^AZCLITest)(void);

@interface AZTestNode : BaseModel
//+(NSA*) tests;
//+(NSA*) results;
@end

@interface     AZSizerTests  : AZTestNode @end
@interface  AZGeometryTestsA : AZTestNode @end
@interface   AZFavIconTests  : AZTestNode @end
@interface     NSImageTests :AZTestNode  @end


@interface AZTestNode ()
@property (strong) NSMD *testD;
@end
@implementation AZTestNode


- (void) setUp {

	if (![self.class hasSharedInstance]) {
		[self.class setSharedInstance:self];
		_testD = [self.methodNames map:^id(id obj) {
			return @{obj:@{@"result" : @(AZTestUnset)}.mutableCopy};
		}].mutableCopy;
	}
//	self.defaultCollectionKey = @"testsD.allValues";
	
//	LOGCOLORS($(@"TESTS in %@", AZCLSSTR), [, [NSC.randomPalette withMinItems:_tests.count + 10], nil);
//	_results =	[_tests nmap:^id(id obj, NSUInteger index) {
//		NSLog(@"Running test %ld of %ld", index, _tests.count);
//		return AZTestCase2Text( (int) [self performSelectorWithoutWarnings:NSSelectorFromString(obj)] );
//	}];
}

@end

@implementation AZFavIconTests

- (AZTestCase) testiconForURL	{

	__block AZTestCase test = AZTestUnset;
	
@end

//- (AZTestCase) colorNames	{

//	__block AZTestCase test = AZTestUnset;
//	NSA* colorNames = [NSC colorNames];

//	[colorNames each:^(id obj) {

//}];
//return test;
//}


@implementation AZGeometryTestsA

- (AZTestCase) testAZAlign	{

	__block __unused AZTestCase test = AZTestUnset;

	NSR testRect = AZRectFromDim(100);

	NSR a = AZRectFromDim(20);
	NSR b = AZRectOffsetFromDim(a,80);
	[[NSA arrayWithRects:a,b, nil] each:^(id obj) {
		NSR oRect = [obj rectValue];
		AZA e = AZAlignmentInsideRect(oRect,testRect);
		NSLog(@"%@'s Alignment in %@: %@", AZStringFromRect(oRect), AZStringFromRect(testRect), AZAlign2Text(e));
	}];
	[[@0 to:@3] each:^(id obj) {
		NSR r = quadrant(testRect, [obj integerValue]);
		AZA e = AZAlignmentInsideRect([obj rectValue],testRect);
		NSLog(@"%@'s Alignment in %@: %@", AZStringFromRect(r), AZStringFromRect(testRect), AZAlign2Text(e));
	}];
  return test;//(id) nil;
//	NSLog(@"%@",AZAlignByValue(AZAlignTop));
//	NSLog(@"%@",AZAlign2Text(AZAlignBottomLeft));

}
@end
*/
/*

@implementation AZSizerTests
{
	id objects;
	NSN* number;
	NSR frame;
	NSSZ hardCodeItemSize;
	NSUI hardCodeColumns;
}

//- (void) setUp {  objects = NSIMG.monoIcons;  number = @([objects count]);  frame = AZScreenFrameUnderMenu(); 
//						hardCodeColumns = 10;  hardCodeItemSize = AZSizeFromDim(50); 	}

//- (AZCLITest) forQuantityQofSizeWithColumnsTest {
//
//	return ^{  id s = [AZSizer forQuantity:number.unsignedIntegerValue ofSize:hardCodeItemSize withColumns:hardCodeColumns]; 
//					NSLog(@"%p: %@", _cmd, s);
//	};
//}


//+ (AZSizer*)   forObjects: (NSA*)objects  withFrame:(NSR)aFrame arranged:(AZOrient)arr;
//+ (AZSizer*)  forQuantity: (NSUI)aNumber aroundRect:(NSR)aFrame;
//+ (AZSizer*)  forQuantity: (NSUI)aNumber	 inRect:(NSR)aFrame;
//+ (NSR) structForQuantity: (NSUI)aNumber	 inRect:(NSR)aFrame;
//+ (NSR)   rectForQuantity: (NSUI)q 			 ofSize:(NSSize)s  	withColumns:(NSUI)c;
//- (NSR)		rectForPoint: (NSP)point;


@end

*/