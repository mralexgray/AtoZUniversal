
#import <AtoZUniversal/AtoZUniversal.h>

#define SHOULDBERECTLIKEALREADY if(EQUAL2ANYOF(self.class,CAL.class,NSV.class,nil)) COMPLAIN;
#define SHOULDBESIZEABLE if(EQUAL2ANYOF(self.class,CAL.class,NSV.class,nil)) COMPLAIN;

CONFORM( View,    RectLike )
CONFORM( CAL,     RectLike )

#if MAC_ONLY

@XtraPlan(Pict, RectLike) @dynamic bounds; // /*! @todo */ anchorPoint;
- _Rect_     frame            { return AZRectFromSize(self.size); }
- _Void_  setFrame:_Rect_ f   {/* FIX  [self isSmallerThanRect:f] ? [self scaleToFillSize:f.size] : nil; */ }
- _Void_ setOrigin:_Cord_ o   {}
￭
@XtraPlan(Wind,RectLike) // @dynamic /*! @todo */ anchorPoint frame; Provided by NWINdow
//＜(Wind,RectLike) // @dynamic /*! @todo */ anchorPoint frame; Provided by NWINdow
- _Void_  setFrame:_Rect_ f { [self setContentSize:f.size]; } // display:YES]; } //self.isVisible animate:NO]; }
- _Void_ setBounds:_Rect_ b { [self setFrame:AZRectExceptSize(self.frame, b.size) display:YES animate:YES]; } // setFramesize = AZSizeFromRect(b); }
- _Rect_    bounds          { return AZRectFromSizeOfRect(self.frame); }
￭
@implementation NSIMG (SizeLike)
_VD setBounds:(NSR)b { self.size = AZSizeFromRect(b); }
-  (NSR)    bounds        { return AZRectFromSize(self.size); }
￭
#endif

@concreteprotocol(RectLike) /*! required */ // @dynamic bounds;

- _Rect_ frame { return [NSException raise:@"Unmet <RectLike> protocol requirement!" format:@"y'all need to implement %@",AZSELSTR], NSZeroRect; }

- _Rect_ bounds { return self.frame; }

- _Void_ setSuperframe:_Rect_ r { SAVE(@selector(superframe), AZVrect(r)); }

- _Rect_ superframe { id x = FETCH;  return x ? [x rV] :

  ISA(self,Wind) ? AZScreenFrameUnderMenu()       : ISA(self,View) ? (_View_ self).superview.bounds :
  ISA(self,Layr)  ? (_Layr_ self).superlayer.bounds : self.r; }

-  (CGR)         r          { return self.frame; }
_VD      setR:(NSR)r   { self.frame = r; }

-  (CGF)         w          { GETALIASF(width);           }  // ALIASES
-  (CGF)         h          { GETALIASF(height);          }
_VD      setW:(CGF)w   { SETALIAS(width, @(ABS(w))); }
_VD      setH:(CGF)h   { SETALIAS(height,@(ABS(h))); }

-  (CGF)         x          { return self.r.origin.x; }
-  (CGF)         y          { return self.r.origin.y; }
_VD      setX:(CGF)x   { self.r = AZRectExceptOriginX(self.r, x); }// (NSP){x, self.y}; }
_VD      setY:(CGF)y   { self.r = AZRectExceptOriginX(self.r, y); } // self.position = (NSP){self.x, y}; }


- (NSSZ)      size          {	return self.r.size;          }
-  (CGF)     width          { return self.size.width;    }
-  (CGF)    height          { return self.size.height;   }
_VD   setSize:(NSSZ)sz { self.frame = AZRectExceptSize(self.frame, sz);  }
_VD  setWidth:(CGF)w   { self.frame = AZRectExceptWide(self.frame, w);   }
_VD setHeight:(CGF)h   { self.frame = AZRectExceptHigh(self.frame, h);   }

-  (CGF)      midX        { return self.x + (self.h/2.);            }
-  (CGF)      maxX        { return self.x +  self.w;                }
-  (CGF)      midY        { return self.y + (self.h/2.);            }
-  (CGF)      maxY        { return self.y +  self.h;                }
_VD   setMidX:(CGF)x { self.centerPt = (NSP){x, self.midY};    }
_VD   setMidY:(CGF)y { self.centerPt = (NSP){self.midX, y};    }
_VD   setMaxX:(CGF)w { self.x = w - self.width;                }
_VD   setMaxY:(CGF)h { self.y = h - self.height;               }

-  (CGP)      minXmaxY        { return AZPt(self.x,    self.maxY); }
-  (CGP)      midXmaxY        { return AZPt(self.midX, self.maxY); }
-  (CGP)      maxXmaxY        { return AZPt(self.maxX, self.maxY); }

-  (CGP)      minXmidY        { return AZPt(self.x, self.midY);    }
-  (CGP)      midXmidY        { return AZPt(self.midX, self.midY); }
-  (CGP)      maxXmidY        { return AZPt(self.maxX, self.midY); }

-  (CGP)      minXminY        { return AZPt(self.x,    self.y);     }
-  (CGP)      midXminY        { return AZPt(self.midX, self.y);     }
-  (CGP)      maxXminY        { return AZPt(self.maxX, self.y);     }

-  (CGP)     bOrigin          { return self.bounds.origin; }
-  (CGP)      origin          { return self.minXminY; }
_VD  setBOrigin:(NSP)o   { self.bounds = AZRectExceptOrigin(self.bounds,o); }
_VD   setOrigin:(NSP)o   { self.r = AZRectExceptOrigin(self.r,o); }

-  (CGP)      apex            { return self.maxXmaxY; }
-  (CGP)      centerPt        { return self.midXmidY; }
_VD   setCenterPt:(NSP)c { self.r = AZCenterRectOnPoint(self.r, c);  }

      SYNTHESIZE_ASC_PRIMITIVE_KVO( position, setPosition, _Cord)

#if MAC_ONLY
SYNTHESIZE_ASC_PRIMITIVE_BLOCK_KVO( alignment, setAlignment, NSAlignmentOptions, ^{}, ^{ })      

SYNTHESIZE_ASC_PRIMITIVE_BLOCK_KVO( supersize, setSupersize, NSSZ, ^{ if (!AZIsZeroSize(value)) return;

  value = ISA(self,NSW) ?  ((NSW*)self).screen.frame.size : ISA(self,CAL) ? ((CAL*)self).superlayer.size : 
          ISA(self,NSV) ?  ({NSV* x = ((NSV*)self).superview; x ? x.size : value; }) : value;

},^{})
#endif

//_VD setBounds:(NSRect)bounds   { if ([self isKindOfAnyClass:@[CALayer.class, NSView.class]]) YOU_DONT_BELONG;
//
//  self.frame = AZCenterRectOnPoint(AZRectFromSizeOfRect(bounds), self.centerPt); }
//
//-  (NSR)    bounds                  { if ([self isKindOfAnyClass:@[CALayer.class, NSView.class]]) YOU_DONT_BELONG,NSZeroRect;

//  return AZCenterRectOnPoint(self.frame, self.centerPt); }

- (BOOL)  isLargerThan:(id<RectLike>)r { return self.area  >   r.area; }
- (BOOL) isSmallerThan:(id<RectLike>)r { return self.area   <  r.area; }
- (BOOL)     isRectLke:(id<RectLike>)r { return self.area  ==  r.area; }
- (BOOL)  isLargerThanRect:(NSR)r      { return self.area  >   $AZR(r).area; }
- (BOOL) isSmallerThanRect:(NSR)r      { return self.area   <  $AZR(r).area; }
- (BOOL)        isSameRect:(NSR)r      { return self.area  ==  $AZR(r).area; }


SetKPfVA(InsideEdge, @"frame", @"superframe");

- (AZA) insideEdge {

  AZA oldEdge = ({ id x = FETCH; x ? [x uIV] : AZUnset; }),
      newEdge = AZOutsideEdgeOfRectInRect(self.frame, self.superframe);

  if (oldEdge == newEdge) return oldEdge;
  SAVE(_cmd, @(newEdge)); [self triggerChangeForKeys:@[AZSELSTR]]; return newEdge;
}

#if MAC_ONLY
- (NSS*) insideEdgeHex { return AZEnumToBinary(self.insideEdge); }
#endif

//  if (value != AZAlignUnset) return; if (ISA(self,CAL)) value = AZAlignmentInsideRect(((CAL*)self).frame, self.superframe);
//objswitch(self.class)
//
//  objcase(CAL.class)
//    CAL* _self = (id)self;
//    _self.arMASK       = AZPositionToAutoresizingMask(value);
//    _self.anchorPoint  = AZAnchorPtAligned(value);
//    _self.position     = AZAnchorPointOfActualRect(_self.superlayer.bounds, value);
//  endswitch
//-  (CGR) frame            { return (NSR){self.origin,self.size}; }
//_VD setFrame:(CGR)f  { self.bounds = AZRectFromSizeOfRect(f); self.origin = f.origin;  }  //(NSR){self.origin,self.size}; }

+ (INST) withDims:(NSN*)d1, ...     { AZVA_ARRAY(d1,dims); return [self withRect:[NSN rectBy:dims]]; }

+ (INST) rectLike:(NSNumber *)d1, ... {

  AZVA_ARRAY(d1, rectParts);
  return [self.class withRect:[NSNumber rectBy:rectParts]];
}

+ (INST) withRect:(NSR)r            { return [self.class instancesRespondToSelector:@selector(initWithFrame:)] ? [self.alloc initWithFrame:r] : [self.new wVsfKs:V_Rect(r),@"frame", nil]; }
+ (INST)        x:(CGF)x y:(CGF)y
                w:(CGF)w h:(CGF)h   { return [self withRect:(NSR){x,y,w,h}]; }


-  (CGF)           area    { return self.w * self.h; }
-  (CGF)      perimeter    { return (self.h + self.w) * 2; }
- (NSSZ)  scaleWithSize:(NSSZ)z { self.w *= z.width; self.h *= z.height; return self.size; }
- (NSSZ) resizeWithSize:(NSSZ)z { self.w += z.width; self.h += z.height; return self.size; }


- _Void_ iterate:(CordBlk)b {

  [[@(self.x) to:@(self.maxX-1)] each:^(_Numb r) {
    [[@(self.y) to:@(self.maxY-1)] each:^(_Numb c) { b(_Cord_{ r.iV, c.iV }); }]; }];
}

￭

//-(id) valueForUndefinedKey:(NSS*)key{ printf("requested %s's undefined key:%s", self.cDesc,key.UTF8String); return nil; }
//SetKPfVA(Origin, @"x", @"y") SetKPfVA(X,@"origin") SetKPfVA(Y,@"origin")
//SetKPfVA(Size, @"bounds", @"width", @"height") SetKPfVA(Width, @"size") SetKPfVA(Height, @"size")

//  NSSZ superRect = NSZeroSize;
//  if (!SameChar([sizes.lastObject objCType], @encode(NSSZ))) {

//        superRect = [sizes.lastObject sizeValue]; [sizes removeLastObject];
//  }
//  id new =
//  if (!AZIsZeroSize(superRect)) [new setSize:superRect forKey:@"supersize"];  return (id)new;

//@pcategoryimplementation(SizeLike, Aliases)
//
//-  (CGF)           w  { GETALIAS(width);      }  // ALIASES
//_VD setW:(CGF)w  { SETALIAS(width, @(w));  }
//-  (CGF)           h  { GETALIAS(height);     }
//_VD setH:(CGF)h  { SETALIAS(height,@(h));  }
//@end


//@property         NSP   origin,       // This is inherited, but can be affected by superframe, alignment.
//                        apex;         // origin + size (same as size unless effected)
                        
//@property        NSSZ   size;         // This is inherited, but supplies a ddefault implementation.                                    
//_VD setMinX:(CGF)x  {	self.frame = AZRectExceptOriginX(self.frame,x); }
//_VD setMinY:(CGF)y  {	self.frame = AZRectExceptOriginY(self.frame,y); }
//_VD setBoundsCenter:(NSP)p { self.bounds = AZCenterRectOnPoint(self.bounds,p); }
//_VD  setFrameCenter:(NSP)p { self.frame  = AZCenterRectOnPoint(self.frame, p); }
//_VD moveBy:(NSP)distance { if (ISA(self,CAL)||ISA(self,NSV)) self.frame = AZRectOffset(self.frame,distance);   }

//SetKPfVA( Frame,      @"center", @"size", @"position")
//SetKPfVA( Center,     @"frame", @"origin")
//SetKPfVA( Alignment,  @"position", @"frame", @"bounds", @"size", @"orientation")



@implementation AZRect // { NSR _rect; } // @synthesize rect =
@synthesize frame;// = _rect;
// STOPGAP  BELOW
- (NSR) bounds { return AZRectFromSizeOfRect(frame); }
_VD setBounds:(NSR)bounds { self.frame = AZRectExceptSize(frame,bounds.size); }

//- (NSR) frame { return _rect; }
//_VD setFrame:(NSR)frame { _rect = frame; }

// STOPGAP  END



// @synthesize bounds, origin; position, orient, anchor;

-(INST) shiftedX:(CGF)xx y:(CGF)yy w:(CGF)w h:(CGF)h {

	NSR r = self.frame;
	r.origin.x +=xx;
	r.origin.y +=yy;
	r.size.width +=w;
	r.size.height+=h;
	return [self.class withRect:r];
}
+ (AZRect*)screnFrameUnderMenu { return [AZRect withRect:AZScreenFrameUnderMenu()]; }
@Stop



//-  (NSP)    position            { return AZCenter(self.frame); }  // (NSP){self.originX + (self.width/2), self.originY + (self.height/2));
//_VD setPosition:(NSP)p     { /*! @todo */ NSAssertFail(@"neeed to fix");  }        //	frame.origin = NSMakePoint(midpoint.x - (frame.size.width/2), midpoint.y - (frame.size.height/2));
//@XtraPlan(CALayer,RectLike) //@dynamic alignment;
//-  (NSP)     origin {return self.frame.origin; }
//_VD setOrigin:(NSP)p { self.frame = (NSR){p, self.bounds.size}; }
//￭
//@implementation NSV   (RectLike) //@dynamic alignment, position,anchorPoint;
//-  (NSP)    origin        {return self.frame.origin; }
//_VD setOrigin:(NSP)p { self.frame = (NSR){p, self.bounds.size}; }
//-  (NSR) superframe       { return self.superview.bounds; }
//￭


//+ (void) initialize {
//
//  unsigned count = 0;
//  Class *classes = ext_copyClassListConformingToProtocol (@protocol(RectLike),&count);
//  NSLog(@"what a delight.. there are %u RectLike Classes!", count);
//  free(classes);
////  for (int i = 0; i < count; i++ ) {
////    Class c = classes[i];
////
//}
