
//#import <AtoZ/AZGrid, AZMatrix.h, AZPoint, AZSize, AZRect, AZSegmentedRect

// Predifined Points, Sizes and Rects

#define AZHalfPoint NSMakePoint ( .5, .5 )
#define  AZMaxPoint NSMakePoint ( MAXFLOAT, MAXFLOAT )

#define  AZHalfSize  NSMakeSize ( .5, .5 )
#define   AZMaxSize  NSMakeSize ( MAXFLOAT, MAXFLOAT )

#define AZNormalRect NSMakeRect ( 0, 0, 1, 1 )

/*! AZEqualRects(...) - Compare MANY rects. AZAllAreEqualRects(r2, r44, NSZeroRect), etc.  
    @see helper _AZAllAreEqualRects 
 */
BOOL _AZAllAreEqualRects(int count, ...);
#define AZEqualRects(...) (BOOL)_AZAllAreEqualRects(metamacro_argcount(__VA_ARGS__),__VA_ARGS__) 

//metamacro_head(__VA_ARGS__), metamacro_tail(__VA_ARGS__)))

///* AZEqualRects macro helper */ BOOL _AZAllAreEqualRects(int ct,...);


OBJC_EXPORT _Rect AZRectOffsetLikePoints( _Rect r, NSP p1, NSP p2);
OBJC_EXPORT _Rect AZRectResizedLikePointsInQuad( _Rect frame, NSP point1, NSP point2, AZQuad quadrant);

OBJC_EXPORT BOOL            AZIsZeroSize( NSSZ z);
OBJC_EXPORT BOOL            AZIsZeroRect( _Rect r);
OBJC_EXPORT _Rect  AZRectCheckWithMinSize( _Rect r,     NSSZ    sz);
OBJC_EXPORT _Rect         AZTransformRect( _Rect target, _Rect model);
OBJC_EXPORT _Rect            nanRectCheck( _Rect  r);
OBJC_EXPORT  NSP           nanPointCheck( NSP   p);
OBJC_EXPORT NSSZ            nanSizeCheck( NSSZ  s);
OBJC_EXPORT   id    	          nanCheck( NSV* point);

OBJC_EXPORT BOOL SameRect ( _Rect r1, _Rect r2 );

OBJC_EXPORT NSP AZAnchorPointInRect(CGP anch, _Rect rect);
OBJC_EXPORT                   AZAP AZAnchorPointOfActualRect( _Rect rect, AZA pos);
OBJC_EXPORT                   AZAP         AZAnchorPtAligned(AZA pos);

FOUNDATION_EXPORT const AZAnchorPt  AZAnchorTop,      AZAnchorBottom,     AZAnchorRight,    AZAnchorLeft, 
                                    AZAnchorTopLeft,  AZAnchorBottomLeft, AZAnchorTopRight, AZAnchorBottomRight,
                                    AZAnchorCenter;

OBJC_EXPORT const CGR CGRectOne;

OBJC_EXPORT NSP AZTopLeftPoint  ( _Rect rect );
OBJC_EXPORT NSP AZTopRightPoint ( _Rect rect );
OBJC_EXPORT NSP AZBotLeftPoint  ( _Rect rect );
OBJC_EXPORT NSP AZBotRightPoint ( _Rect rect );

/**	NSRange from a min and max values even though the names imply that min should be greater than max the order does not matter the range will always start at the lower value and have a size to reach the upper value **/
//NSRange AZMakeRange ( NSUI min, NSUI max );

#define AZDistanceBetween(A,B) AZPointDistance(A,B)
OBJC_EXPORT CGF     AZPointDistance ( CGP p1, CGP p2 );
OBJC_EXPORT CGF        AZPointAngle ( CGP p1, CGP p2 );
OBJC_EXPORT CGF AZDistanceFromPoint ( NSP p1, NSP p2 );

OBJC_EXPORT NSP	    AZPointOffsetBy	( NSP p, CGF x, CGF y);
OBJC_EXPORT NSP       AZPointOffset ( NSP p, NSP size );
OBJC_EXPORT NSP      AZPointOffsetY ( NSP p, CGF dist );
OBJC_EXPORT NSP      AZPointOffsetX ( NSP p, CGF dist );

OBJC_EXPORT int GCD ( int a, int b );
OBJC_EXPORT BOOL isWhole ( CGF fl );

OBJC_EXPORT NSI AZLowestCommonDenominator ( int a, int b );

OBJC_EXPORT NSS * AZAspectRatioString ( CGF ratio );
OBJC_EXPORT CGF   AZAspectRatioOf ( CGF width, CGF height );
OBJC_EXPORT CGF   AZAspectRatioForSize ( NSSZ size );

// Simple Length and Area calculus

OBJC_EXPORT CGF AZPerimeter ( _Rect rect );
OBJC_EXPORT CGF AZPerimeterWithRoundRadius  ( _Rect rect, CGF radius );

OBJC_EXPORT AZPOS                           AZPositionOpposite(AZPOS pos);
OBJC_EXPORT AZPOS AZPositionOfEdgeAtOffsetAlongPerimeterOfRect(CGF off, _Rect r);
OBJC_EXPORT   CGP          AZPointAtOffsetAlongPerimeterOfRect(CGF off, _Rect r);  //from bottom left going counterclockwise
OBJC_EXPORT AZPOS        AZPositionOfRectPinnedToOutisdeOfRect( _Rect box, _Rect innerBox  );
OBJC_EXPORT   AZA                        AZAlignmentInsideRect( _Rect inner, _Rect outer);
OBJC_EXPORT   AZA AZAlignNext(AZA a);

//NS_INLINE BOOL AZAlignIsCorner(AZA a){ AZA r; int ctr;
//
//  for(ctr = 0, r = AZAUnset; r; (AZA)(r<<=1)) if(r&a) ctr++;  return ctr == 1;
//}

//Includes corner preciion based on inner rect size;
OBJC_EXPORT AZPOS AZPositionOfRectAtOffsetInsidePerimeterOfRect( _Rect inner, CGF offset, _Rect outer);
OBJC_EXPORT AZPOS AZPositionOfQuadInRect ( _Rect rect, _Rect outer );
OBJC_EXPORT AZPOS AZOutsideEdgeOfRectInRect ( _Rect rect, _Rect outer );

OBJC_EXPORT AZPOS AZOutsideEdgeOfPointInRect (NSP inside, _Rect outer );

OBJC_EXPORT AZPOS AZPositionAtPerimeterInRect ( _Rect edgeBox, _Rect outer );
OBJC_EXPORT NSSZ  AZDirectionsOffScreenWithPosition ( _Rect rect, AZPOS position );

OBJC_EXPORT AZOrient deltaDirectionOfPoints ( NSP a, NSP b );

OBJC_EXPORT _Rect  AZScreenFrame ( void );
OBJC_EXPORT NSSZ AZScreenSize  ( void );
OBJC_EXPORT _Rect  AZScreenFrameUnderMenu ( void );

OBJC_EXPORT CGF AZMinEdge ( _Rect r );
OBJC_EXPORT CGF AZMaxEdge ( _Rect r );
OBJC_EXPORT CGF AZMaxDim ( NSSZ sz );
OBJC_EXPORT CGF AZMinDim ( NSSZ sz );

//OBJC_EXPORT CGF AZLengthOfPoint ( NSP  p );
OBJC_EXPORT CGF    AZAreaOfSize ( NSSZ s );
OBJC_EXPORT CGF    AZAreaOfRect ( _Rect  r );
// Size -> Point conversion
OBJC_EXPORT NSP AZPointFromSize ( NSSZ size );
OBJC_EXPORT CGF AZMenuBarH (void) ;
// NSP result methods
OBJC_EXPORT NSP AZOriginFromMenubarWithX ( CGF yOffset, CGF xOffset );
// returns the absolute values of a point  ( pt.x >= 0, pt.y >= 0)
OBJC_EXPORT NSP AZAbsPoint ( NSP point );
// floor, ceil and round simply use those functions on both values of the point
OBJC_EXPORT NSP AZFloorPoint ( NSP point );
OBJC_EXPORT NSP AZCeilPoint ( NSP point );
OBJC_EXPORT NSP AZRoundPoint ( NSP point );
// pt.x = -pt.x, pt.y = -pt.x
OBJC_EXPORT NSP AZNegatePoint ( NSP point );
// pt.x = 1 / pt.x, pt.y = 1 / pt.y
OBJC_EXPORT NSP AZInvertPoint ( NSP point );
// exchanges both x and y values
OBJC_EXPORT NSP AZSwapPoint ( NSP point );
// sum of two points
OBJC_EXPORT NSP AZAddPoints ( NSP one, NSP another );
// subtracts the 2nd from the 1st point
OBJC_EXPORT NSP AZSubtractPoints ( NSP origin, NSP subtrahend );
// sums a list of points
OBJC_EXPORT NSP AZSumPoints ( NSUI count, NSP points, ... );
// multiplies both x and y with one multiplier
OBJC_EXPORT NSP AZMultiplyPoint ( NSP point, CGF multiplier );
// multiplies each value with its corresponding value in another point
OBJC_EXPORT NSP AZMultiplyPointByPoint ( NSP one, NSP another );
// multiplies each value with its corresponding value in a size
OBJC_EXPORT NSP AZMultiplyPointBySize ( NSP one, NSSZ size );
// positions a relative {0-1,0-1} point within absolute bounds
OBJC_EXPORT NSP AZRelativeToAbsolutePoint ( NSP relative, _Rect bounds );
// calculates the relative {0-1,0-1} point from absolute bounds
OBJC_EXPORT NSP AZAbsoluteToRelativePoint ( NSP absolute, _Rect bounds );
OBJC_EXPORT NSP AZDividePoint ( NSP point, CGF divisor );
OBJC_EXPORT NSP AZDividePointByPoint ( NSP point, NSP divisor );
OBJC_EXPORT NSP AZDividePointBySize ( NSP point, NSSZ divisor );

// moves from an origin towards the destination point
// at a distance of 1 it will reach the destination
OBJC_EXPORT NSP AZMovePoint ( NSP origin, NSP target, CGF relativeDistance );

// moves from an origin towards the destination point
// distance on that way is measured in pixels
OBJC_EXPORT NSP AZMovePointAbs ( NSP origin, NSP target, CGF pixels );

// returns the center point of a rect
OBJC_EXPORT NSP AZCenterOfRect ( _Rect rect );

// returns the center point of a size
OBJC_EXPORT NSP AZCenterOfSize ( NSSZ size );

// will return the origin + size value of a rect
OBJC_EXPORT NSP AZEndOfRect ( _Rect rect );

/*! Returns the average distance of two rects

     +-------+
     |	     |
     |   a   |   +-------+
     |	     |   |	     |
     +-------+   |   b   |
    		         |	     |
 		  	         +-------+    
*/
OBJC_EXPORT NSP AZCenterDistanceOfRects ( _Rect from, _Rect to );

// will return the shortest possible distance in x and y
OBJC_EXPORT NSP AZBorderDistanceOfRects ( _Rect from, _Rect to );



OBJC_EXPORT NSP AZPointClosestOnRect ( NSP point, _Rect rect );

// will return the shortes possible distance from point to rect
OBJC_EXPORT NSP AZPointDistanceToBorderOfRect ( NSP point, _Rect rect );

OBJC_EXPORT NSP AZNormalizedDistanceOfRects ( _Rect from, _Rect to );
OBJC_EXPORT NSP AZNormalizedDistanceToCenterOfRect ( NSP point, _Rect rect );

OBJC_EXPORT NSP AZPointFromDim ( CGF val );
/*! NSSZ result methods  */
// converts a float to a rect of equal sized sizes of dim;
OBJC_EXPORT _Rect AZRectFromDim ( CGF dim );

OBJC_EXPORT NSP AZPt(CGF x, CGF y);

//  Makes _Rect 0, 0, boundsX, boundsY  easy syntax AZRectBy ( 200,233)
OBJC_EXPORT _Rect AZRectBy ( CGF boundX, CGF boundY );

// MaxX, MaxY point of Rect
OBJC_EXPORT NSP AZRectApex( _Rect r);

// converts a float to a size;
OBJC_EXPORT NSSZ AZSizeFromDim ( CGF dim );

// Scale a size by factor.
OBJC_EXPORT NSSZ	AZScaleSize   (const NSSZ  sz, const CGF scale);

// converts a point to a size
OBJC_EXPORT NSSZ AZSizeFromPoint ( NSP point );
OBJC_EXPORT NSSZ 	AZSizeFromRect	( _Rect rect);
// ABS on both values of the size
OBJC_EXPORT NSSZ AZAbsSize ( NSSZ size );

// Adds the width and height of two sizes
OBJC_EXPORT NSSZ AZAddSizes ( NSSZ one, NSSZ another );

// subtracts the subtrahends dimensions from the ones of the size
OBJC_EXPORT NSSZ AZSubtractSizes ( NSSZ size, NSSZ subtrahend );

// returns 1 / value on both values of the size
OBJC_EXPORT NSSZ AZInvertSize ( NSSZ size );

// will return the ratio of an inner size to an outer size
OBJC_EXPORT NSSZ AZRatioOfSizes ( NSSZ inner, NSSZ outer );

OBJC_EXPORT NSSZ AZMultiplySize( NSSZ size, CGF multiplier );

// will multiply a size by a single multiplier
OBJC_EXPORT NSSZ AZMultiplySizeBy( NSSZ size, CGF multiplier );
//NSSZ AZMultiplySize ( NSSZ size, CGF multiplier );

// will multiply a size by another size
OBJC_EXPORT NSSZ AZMultiplySizeBySize ( NSSZ size, NSSZ another );

// will multiply a size by a point
OBJC_EXPORT NSSZ AZMultiplySizeByPoint ( NSSZ size, NSP point );

// blends one size towards another
// percentage == 0 -> one
// percentage == 1 -> another
// @see AZMovePoint
OBJC_EXPORT NSSZ AZBlendSizes ( NSSZ one, NSSZ another, CGF percentage );

OBJC_EXPORT NSSZ AZSizeMax ( NSSZ one, NSSZ another );
OBJC_EXPORT NSSZ AZSizeMin ( NSSZ one, NSSZ another );
OBJC_EXPORT NSSZ AZSizeBound ( NSSZ preferred, NSSZ minSize, NSSZ maxSize );
// _Rect result methods
OBJC_EXPORT _Rect AZZeroHeightBelowMenu ( void );

OBJC_EXPORT _Rect AZFlipRectinRect ( CGRect local, CGRect dest );

OBJC_EXPORT CGF AZMenuBarThickness  ( void );

OBJC_EXPORT _Rect AZMenuBarFrame ( void );

OBJC_EXPORT _Rect AZRectOffsetBy        (CGR rect, CGF x, CGF y);
OBJC_EXPORT _Rect AZRectOffsetBySize    (CGR rect, CGSZ sz);
OBJC_EXPORT NSR	AZRectResizedBySize		(CGR rect, CGSZ sz);
OBJC_EXPORT _Rect AZRectOffsetByPt      (CGR rect, NSP pt);
OBJC_EXPORT _Rect AZRectOffsetFromDim   (CGR rect, CGF xyDistance);

OBJC_EXPORT _Rect AZRectVerticallyOffsetBy (CGR rect, CGF offset );
OBJC_EXPORT _Rect AZRectHorizontallyOffsetBy ( CGRect rect, CGF offset );

OBJC_EXPORT _Rect AZMenulessScreenRect ( void );

OBJC_EXPORT _Rect AZMakeRectMaxXUnderMenuBarY ( CGF distance );

OBJC_EXPORT CGF AZHeightUnderMenu ( void );
OBJC_EXPORT _Rect AZSquareFromLength ( CGF length );

// returns a zero sized rect with the argumented point as origin
OBJC_EXPORT _Rect AZMakeRectFromPoint ( NSP point );

// returns a zero point origin with the argumented size
OBJC_EXPORT _Rect AZMakeRectFromSize ( NSSZ size );

// just another way of defining a rect
OBJC_EXPORT _Rect AZMakeRect ( NSP point, NSSZ size );

// creates a square rect around a center point
OBJC_EXPORT _Rect AZMakeSquare ( NSP center, CGF radius );

OBJC_EXPORT _Rect AZMultiplyRectBySize ( _Rect rect, NSSZ size );

// transforms a relative rect to an absolute within absolute bounds
OBJC_EXPORT _Rect AZRelativeToAbsoluteRect ( _Rect relative, _Rect bounds );

// transforms an absolute rect to a relative rect within absolute bounds
OBJC_EXPORT _Rect AZAbsoluteToRelativeRect ( _Rect absolute, _Rect bounds );

OBJC_EXPORT _Rect AZPositionRectOnRect ( _Rect inner, _Rect outer, NSP position );

enum CAAutoresizingMask AZPositionToAutoresizingMask (AZPOS p);

OBJC_EXPORT _Rect AZRectWithDimsCenteredOnPoints(CGF width, CGF heigt, CGF cx, CGF cy);  /** NICE **/

// moves the origin of the rect
OBJC_EXPORT _Rect AZCenterRectOnPoint ( _Rect rect, NSP center );

// returns the innter rect with its posiion centeredn on the outer rect
OBJC_EXPORT _Rect AZCenterRectOnRect ( _Rect inner, _Rect outer );

OBJC_EXPORT _Rect AZConstrainRectToRect( _Rect innerRect, _Rect outerRect);

// will a square rect with a given center
OBJC_EXPORT _Rect AZSquareAround ( NSP center, CGF distance );

// blends a rect from one to another
OBJC_EXPORT _Rect AZBlendRects ( _Rect from, _Rect to, CGF at );

// Croped Rects

OBJC_EXPORT _Rect AZRectTrimmedOnRight ( _Rect rect, CGF width );
OBJC_EXPORT _Rect AZRectTrimmedOnBottom ( _Rect rect, CGF height );
OBJC_EXPORT _Rect AZRectTrimmedOnLeft ( _Rect rect, CGF width );
OBJC_EXPORT _Rect AZRectTrimmedOnTop ( _Rect rect, CGF height );

OBJC_EXPORT NSSZ AZSizeExceptWide  ( NSSZ sz, CGF wide );
OBJC_EXPORT NSSZ AZSizeExceptHigh  ( NSSZ sz, CGF high );

OBJC_EXPORT _Rect AZRectExtendedOnLeft( _Rect rect, CGF amount);
OBJC_EXPORT _Rect AZRectExtendedOnBottom( _Rect rect, CGF amount);
OBJC_EXPORT _Rect AZRectExtendedOnTop( _Rect rect, CGF amount);
OBJC_EXPORT _Rect AZRectExtendedOnRight( _Rect rect, CGF amount);

OBJC_EXPORT _Rect 	AZRectExceptSize ( _Rect rect, NSSZ size);
FOUNDATION_EXPORT _Rect AZRectExceptWide  ( _Rect rect, CGF wide );
FOUNDATION_EXPORT _Rect AZRectExceptHigh  ( _Rect rect, CGF high );
FOUNDATION_EXPORT _Rect AZRectExceptOriginX  ( _Rect rect, CGF x );
FOUNDATION_EXPORT _Rect AZRectExceptOriginY  ( _Rect rect, CGF y );
FOUNDATION_EXPORT NSR	AZRectExceptOrigin	( _Rect r, NSP origin);

// returns a rect with insets of the same size x and y
FOUNDATION_EXPORT _Rect AZInsetRect ( _Rect rect, CGF inset );

// returns a rect at the left edge of a rect with a given inset width
FOUNDATION_EXPORT _Rect AZLeftEdge ( _Rect rect, CGF width );

// returns a rect at the right edge of a rect with a given inset width
FOUNDATION_EXPORT _Rect AZRightEdge ( _Rect rect, CGF width );

// returns a rect at the lower edge of a rect with a given inset width
FOUNDATION_EXPORT _Rect AZLowerEdge ( _Rect rect, CGF height );

// returns a rect at the upper edge of a rect with a given inset width
FOUNDATION_EXPORT _Rect AZUpperEdge ( _Rect rect, CGF height );


OBJC_EXPORT _Rect AZRectInsideRectOnEdge(NSRect center, _Rect outer, AZPOS position);
OBJC_EXPORT _Rect AZRectOutsideRectOnEdge(NSRect center, _Rect outer, AZPOS position);
OBJC_EXPORT _Rect AZRectFlippedOnEdge(NSRect r, AZPOS position);

FOUNDATION_EXPORT _Rect AZInsetRectInPosition ( _Rect outside, NSSZ inset, AZPOS pos );

FOUNDATION_EXPORT AZPOS AZPosOfPointInInsetRects ( NSP point, _Rect outside, NSSZ inset );

/* Is point "point" within edges of "rect" within inset of size? */ /* UNIT TESTS OK */
FOUNDATION_EXPORT BOOL  AZPointIsInInsetRects	(NSP innerPoint, _Rect outerRect, NSSZ size);

typedef struct AZInsetRects {	_Rect top; _Rect right; _Rect bottom;	_Rect left; } AZInsetRects;

/*!  +-------+------------------+-------+
     |	     |        T         |       |             
     |=======+==================+=======+        +-------+
     |	     |                  |	      |        | sizes |
     |	     |                  |	      |        +-------+
     |	 L   |                  |	  R   |
     |	     |     INSIDE       |	      |     
     |	     |                  |	      |
     |	     |                  |	      |
     |=======+==================+=======+
     |	     |        B         |       |
     +-------+------------------+-------+    */

NS_INLINE AZInsetRects AZMakeInsideRects(_Rect rect, NSSZ inset) {

 return  (AZInsetRects){ AZUpperEdge(rect, inset.height), AZRightEdge(rect, inset.width),
                         AZLowerEdge(rect, inset.height),  AZLeftEdge(rect, inset.width)}; 
}

//FOUNDATION_EXPORT AZOutsideEdges AZOutsideEdgesSized(NSRect rect, NSSZ size);

//BOOL AZPointInOutsideEdgeOfRect(NSP point, _Rect rect, NSSZ size);

// macro to call a border drawing method with a border width
// this will effectively draw the border but clip the inner rect

// Example: AZInsideClip ( NSDrawLightBezel, rect, 2 );
//		  Will draw a 2px light beezel around a rect
#define AZInsideClip ( METHOD,RECT,BORDER) \
	METHOD ( RECT, AZLeftEdge( RECT, BORDER ) ); \
	METHOD ( RECT, AZRightEdge ( RECT, BORDER ) ); \
	METHOD ( RECT, AZUpperEdge ( RECT, BORDER ) ); \
	METHOD ( RECT, AZLowerEdge ( RECT, BORDER ))
// Comparison methods
OBJC_EXPORT BOOL AZIsPointLeftOfRect  ( NSP point, _Rect rect );
OBJC_EXPORT BOOL AZIsPointRightOfRect ( NSP point, _Rect rect );
OBJC_EXPORT BOOL AZIsPointAboveRect   ( NSP point, _Rect rect );
OBJC_EXPORT BOOL AZIsPointBelowRect   ( NSP point, _Rect rect );

OBJC_EXPORT BOOL AZIsRectLeftOfRect   ( _Rect rect, _Rect compare );
OBJC_EXPORT BOOL AZIsRectRightOfRect  ( _Rect rect, _Rect compare );
OBJC_EXPORT BOOL AZIsRectAboveRect	( _Rect rect, _Rect compare );
OBJC_EXPORT BOOL AZIsRectBelowRect	( _Rect rect, _Rect compare );

OBJC_EXPORT _Rect rectZoom 			 ( _Rect rect,float zoom,int quadrant );
OBJC_EXPORT _Rect 	AZSquareInRect      ( _Rect rect );
OBJC_EXPORT _Rect 	AZSizeRectInRect    ( _Rect innerRect,_Rect outerRect,bool expand );
OBJC_EXPORT NSP 	AZOffsetPoint       (NSP fromPoint, NSP toPoint );
OBJC_EXPORT _Rect 	AZFitRectInRect     ( _Rect innerRect,_Rect outerRect,bool expand );
OBJC_EXPORT _Rect 	AZCenterRectInRect  ( _Rect rect, _Rect mainRect );
OBJC_EXPORT _Rect 	AZRectFromSize      (NSSZ size );
OBJC_EXPORT NSR	AZRectFromSizeOfRect  ( _Rect rect);
//Rect rectWithProportion ( _Rect innerRect,float proportion,bool expand );

OBJC_EXPORT _Rect AZRectInsideRectOnEdgeInset ( _Rect rect, AZA side, CGF inset );
OBJC_EXPORT _Rect AZCornerRectPositionedWithSize( _Rect outerRect, AZPOS pos, NSSZ sz);
//Rect 	sectionPositioned ( _Rect r, AZPOS p );
OBJC_EXPORT int 	oppositeQuadrant ( int quadrant );
OBJC_EXPORT _Rect 	quadrant ( _Rect r, AZQuad quad );
OBJC_EXPORT _Rect 	AZRectOfQuadInRect		  ( _Rect originalRect, AZQuad quad); //alias for quadrant

OBJC_EXPORT CGF 	quadrantsVerticalGutter   ( _Rect r );
OBJC_EXPORT CGF quadrantsHorizontalGutter ( _Rect r );
OBJC_EXPORT _Rect constrainRectToRect 		  ( _Rect innerRect, _Rect outerRect );
OBJC_EXPORT _Rect alignRectInRect			  ( _Rect innerRect,	_Rect outerRect,	int quadrant );
//Rect expelRectFromRect ( _Rect innerRect, _Rect outerRect,float peek );
//Rect expelRectFromRectOnEdge ( _Rect innerRect, _Rect outerRect,NSREdge edge,float peek );

OBJC_EXPORT AZPOS AZPosAtCGRectEdge ( CGRectEdge edge );
OBJC_EXPORT CGRectEdge CGRectEdgeAtPosition ( AZPOS pos );

OBJC_EXPORT CGRectEdge AZEdgeTouchingEdgeForRectInRect ( _Rect innerRect, _Rect outerRect );
AZPOS AZClosestCorner ( _Rect r,NSP pt);
OBJC_EXPORT QUAD 	AZOppositeQuadrant ( int quadrant );
OBJC_EXPORT _Rect 	AZBlendRects ( _Rect start, _Rect end, CGF b );
OBJC_EXPORT void 	logRect ( _Rect rect );
OBJC_EXPORT _Rect AZRandomRectInRect 	( CGRect rect );
OBJC_EXPORT _Rect AZRandomRectInFrame		( CGRect rect );
OBJC_EXPORT CGP AZRandomPointInRect ( CGRect rect );

/** Returns the center point of a CGRect. */
NS_INLINE CGP AZCenter(CGR r){ return CGPointMake( CGRectGetMidX(r),CGRectGetMidY(r)); }

//typedef struct _BTFloatRange { 	float value;	float location; 	float length; } BTFloatRange;
//BTFloatRange BTMakeFloatRange ( float value,float location,float length );
//float BTFloatRangeMod ( BTFloatRange range );
//float BTFloatRangeUnit ( BTFloatRange range );

//NSP AZRectOffset ( _Rect innerRect, _Rect outerRect, QUAD quadrant );

OBJC_EXPORT _Rect        AZRectOffset( _Rect r, NSP ptOff);
OBJC_EXPORT _Rect NSRectFromTwoPoints	( const NSP a, const NSP b );
OBJC_EXPORT _Rect NSRectCentredOnPoint	( const NSP p, const NSSZ size );
OBJC_EXPORT _Rect AZUnionOfTwoRects		( const _Rect a, const _Rect b );
OBJC_EXPORT _Rect AZUnionOfRectsInSet		( const NSSet* aSet );
OBJC_EXPORT NSST* AZDifferenceOfTwoRects ( const _Rect a, const _Rect b );
OBJC_EXPORT NSST* AZSubtractTwoRects		( const _Rect a, const _Rect b );

OBJC_EXPORT BOOL AZAreSimilarRects( const _Rect a, const _Rect b, const CGF epsilon );

OBJC_EXPORT CGF AZPointFromLine		 ( const NSP inPoint, const NSP a, const NSP b );
OBJC_EXPORT NSP AZNearestPointOnLine ( const NSP inPoint, const NSP a, const NSP b );
OBJC_EXPORT CGF AZRelPoint				 ( const NSP inPoint, const NSP a, const NSP b );
OBJC_EXPORT NSI AZPointInLineSegment ( const NSP inPoint, const NSP a, const NSP b );

OBJC_EXPORT NSP AZBisectLine( const NSP a, const NSP b );
OBJC_EXPORT NSP AZInterpolate( const NSP a, const NSP b, const CGF proportion);
OBJC_EXPORT CGF AZLineLength( const NSP a, const NSP b );

OBJC_EXPORT CGF AZSquaredLength( const NSP p );
OBJC_EXPORT NSP AZDiffPoint( const NSP a, const NSP b );
OBJC_EXPORT CGF AZDiffPointSquaredLength( const NSP a, const NSP b );
OBJC_EXPORT NSP AZSumPoint( const NSP a, const NSP b );

OBJC_EXPORT NSP AZEndPoint			( NSP origin, 	CGF angle, CGF length );
OBJC_EXPORT CGF AZSlope				( const NSP a, const NSP b );
OBJC_EXPORT CGF AZAngleBetween	( const NSP a, const NSP b, const NSP c );
OBJC_EXPORT CGF AZDotProduct		( const NSP a, const NSP b );
OBJC_EXPORT NSP AZIntersection	( const NSP aa, const NSP ab, const NSP ba, const NSP bb );
OBJC_EXPORT NSP AZIntersection2	( const NSP p1, const NSP p2, const NSP p3, const NSP p4 );

OBJC_EXPORT _Rect AZCentreRectOnPoint		  ( const _Rect inRect, const NSP p 	 );
OBJC_EXPORT NSP AZMapPointFromRect		  ( const NSP p, 		 const _Rect rect );
OBJC_EXPORT NSP AZMapPointToRect			  ( const NSP p, 		 const _Rect rect );
OBJC_EXPORT NSP AZMapPointFromRectToRect ( const NSP p, 		 const _Rect srcRect, const _Rect destRect );
OBJC_EXPORT _Rect AZMapRectFromRectToRect  ( const _Rect inRect, const _Rect srcRect, const _Rect destRect );

OBJC_EXPORT _Rect AZRectExceptSpanAnchored( _Rect r1, CGF span, AZA anchor);
OBJC_EXPORT _Rect         AZScaleRect	( const _Rect  inRect, const CGF scale 	);
OBJC_EXPORT _Rect AZRectScaledToRect( _Rect resizeRect, _Rect fitRect);
OBJC_EXPORT _Rect  AZCentreRectInRect	( const _Rect  r, 		const _Rect cr 		);
OBJC_EXPORT NSBP *    AZRotatedRect ( const _Rect  r,	 	const CGF radians );

OBJC_EXPORT _Rect AZNormalizedRect( const _Rect r );

OBJC_EXPORT _AffT AZRotationTransform( const CGF radians, const NSP aboutPoint );

OBJC_EXPORT NSP AZNearestPointOnCurve( const NSP inp, const NSP bez[4], double* tValue );
OBJC_EXPORT NSP AZBezier( const NSP* v, const NSI degree, const double t, NSP* Left, NSP* Right );

OBJC_EXPORT CGF AZBezierSlope( const NSP bez[4], const CGF t );

//NSP			PerspectiveMap( NSP inPoint, NSSZ sourceSize, NSP quad[4]);
//extern const NSP NSNotFoundPoint;


//ADBGeometry provides various functions for manipulating NSPoints, NSSizes and NSRects.

#if __cplusplus // The C brace is needed when including this header from an Objective C++ file
extern "C" {
#endif
	#import <Foundation/Foundation.h>

	//Returns the nearest power of two that can accommodate the specified value
	NSInteger fitToPowerOfTwo(NSInteger value);

	//Returns the aspect ratio (width / height) for size. This will be 0 if either dimension was 0.
	CGFloat aspectRatioOfSize(NSSize size);
	//Returns the specified size scaled to match the specified aspect ratio, preserving either width or height.
	//Will return NSZeroSize if the aspect ratio is 0.
	NSSize sizeToMatchRatio(NSSize size, CGFloat aspectRatio, BOOL preserveHeight);

    //Returns the specified point with x and y snapped to the nearest integral values.
    NSPoint integralPoint(NSPoint point);
        
	//Returns the specified size with width and height rounded up to the nearest integral values.
	//Equivalent to NSIntegralRect. Will return NSZeroSize if width or height are 0 or negative.
	NSSize integralSize(NSSize size);

	//Returns whether the inner size is equal to or less than the outer size.
	//An analogue for NSContainsRect.
	BOOL sizeFitsWithinSize(NSSize innerSize, NSSize outerSize);

	//Returns innerSize scaled to fit exactly within outerSize while preserving aspect ratio.
	NSSize sizeToFitSize(NSSize innerSize, NSSize outerSize);

	//Same as sizeToFitSize, but will return innerSize without scaling up if it already fits within outerSize.
	NSSize constrainToFitSize(NSSize innerSize, NSSize outerSize);

	//Resize an NSRect to the target NSSize, using a relative anchor point: 
	//{0,0} is bottom left, {1,1} is top right, {0.5,0.5} is center.
	NSRect resizeRectFromPoint(NSRect theRect, NSSize newSize, NSPoint anchor);

	//Get the relative position ({0,0}, {1,1} etc.) of an NSPoint origin, relative to the specified NSRect.
	NSPoint pointRelativeToRect(NSPoint thePoint, NSRect theRect);

	//Align innerRect within outerRect relative to the specified anchor point: 
	//{0,0} is bottom left, {1,1} is top right, {0.5,0.5} is center.
	NSRect alignInRectWithAnchor(NSRect innerRect, NSRect outerRect, NSPoint anchor);

	//Center innerRect within outerRect. Equivalent to alignRectInRectWithAnchor of {0.5, 0.5}.
	NSRect centerInRect(NSRect innerRect, NSRect outerRect);
		
	//Proportionally resize innerRect to fit inside outerRect, relative to the specified anchor point.
	NSRect fitInRect(NSRect innerRect, NSRect outerRect, NSPoint anchor);
	//Same as fitInRect, but will return alignInRectWithAnchor instead if innerRect already fits within outerRect.
	NSRect constrainToRect(NSRect innerRect, NSRect outerRect, NSPoint anchor);
	//Clamp the specified point so that it fits within the specified rect.
	NSPoint clampPointToRect(NSPoint point, NSRect rect);
	//Calculate the delta between two points.
	NSPoint deltaFromPointToPoint(NSPoint pointA, NSPoint pointB);
	//Add/remove the specified delta from the specified starting point.
	NSPoint pointWithDelta(NSPoint point, NSPoint delta);
	NSPoint pointWithoutDelta(NSPoint point, NSPoint delta);
  	
	//CG implementations of the above functions.
	BOOL CGSizeFitsWithinSize(CGSize innerSize, CGSize outerSize);
	
	CGSize CGSizeToFitSize(CGSize innerSize, CGSize outerSize);
    
  //Returns the specified point with x and y snapped to the nearest integral values.
  CGPoint CGPointIntegral(CGPoint point);
    
	//Returns the specified size with width and height rounded up to the nearest integral values.
	//Equivalent to CGRectIntegral. Will return CGSizeZero if width or height are 0 or negative.
	CGSize CGSizeIntegral(CGSize size);
//    #pragma mark - Debug logging
//    #ifndef NSStringFromCGRect
//    #define NSStringFromCGRect(rect) NSStringFromRect(NSRectFromCGRect(rect))
//    #endif
//    #ifndef NSStringFromCGSize
//    #define NSStringFromCGSize(size) NSStringFromSize(NSSizeFromCGSize(size))
//    #endif
//    #ifndef NSStringFromCGPoint
//    #define NSStringFromCGPoint(point) NSStringFromPoint(NSPointFromCGPoint(point))
//    #endif
    
#if __cplusplus
} //Extern C
#endif


/*
@protocol AZScalar <NSObject>
@required 
_RO NSS *key1, *key2;
@concrete
_RO  CGF   min, max;
@end

@interface AZPoint : NSObject <AZScalar>

@property (NA) NSP point;
@property (NA) CGF x, y;

@end

@interface AZSize : NSObject  <AZScalar>
@property (NA) CGF 	width, height;
@property (NA) NSSZ  size;
@end
*/

//OBJC_EXPORT NSN *iNum (NSI	  i);
//OBJC_EXPORT NSN *uNum (NSUI  ui);
//OBJC_EXPORT NSN *fNum (CGF   	f);
//OBJC_EXPORT NSN *dNum (double d);

//@class AZSize, AZRect, AZGrid, AGMatrix; //  <NSCoding>
//typedef void(^KVOChange)(id _self, id  oldVal);
//@property (CP) KVOChange onMove;

//  AZGeometricFunctions.h Lumumba

//  Created by Benjamin Schüttler on 19.11.09.  Copyright 2011 Rogue Coding. All rights reserved.



/// From AtoZAAPpKit

CGFloat AZDistanceBetweenPoints(NSPoint point1, NSPoint point2);
CGFloat AZDistancePointToLine(NSPoint point, NSPoint lineStartPoint, NSPoint lineEndPoint);
NSPoint AZLineNormal(NSPoint lineStart, NSPoint lineEnd);
NSPoint AZLineMidpoint(NSPoint lineStart, NSPoint lineEnd);

NSPoint FBAddPoint(NSPoint point1, NSPoint point2);
NSPoint FBScalePoint(NSPoint point, CGFloat scale);
NSPoint FBUnitScalePoint(NSPoint point, CGFloat scale);
NSPoint FBSubtractPoint(NSPoint point1, NSPoint point2);
CGFloat FBDotMultiplyPoint(NSPoint point1, NSPoint point2);
CGFloat FBPointLength(NSPoint point);
CGFloat FBPointSquaredLength(NSPoint point);
NSPoint FBNormalizePoint(NSPoint point);
NSPoint FBNegatePoint(NSPoint point);
NSPoint FBRoundPoint(NSPoint point);

BOOL AZArePointsClose(NSPoint point1, NSPoint point2);
BOOL AZArePointsCloseWithOptions(NSPoint point1, NSPoint point2, CGFloat threshold);
BOOL AZAreValuesClose(CGFloat value1, CGFloat value2);
BOOL AZAreValuesCloseWithOptions(CGFloat value1, CGFloat value2, CGFloat threshold);
