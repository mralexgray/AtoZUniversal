
#import <AtoZUniversal/AtoZUniversal.h>

@concreteprotocol(Solo)

+ _Kind_ shared {

  static _ObjC shared             ___

  dispatch_uno(

      shared = [self.class alloc] ___
      shared = [shared      init] ___
  )                               ___
  return shared                   ___
}
￭

CONFORM(List,FakeArray)

🅒 (TypedArray)
SYNTHESIZE_ASC_OBJ(objectClass, setObjectClass)
￭

🅒 (Random)
+ _Kind_ random            {

  return [NSException raise:@"YOU need to implement this yo damned self!" format:@"%@",nil], (id)nil;
}
+ _List_ random __UInt_ ct { return [@(ct) mapTimes:^id(_Numb n) { return [self random]; }]; }
￭

@XtraPlan(NObj,Indexed)  // @dynamic backingStore;

_ID backingStore { return FETCH; }
_UT index        { NSAssert(self.backingStore && [self.backingStore count], @""); return [(NSA*)self.backingStore indexOfObject:self]; }
_UT indexMax     { NSAssert(self.backingStore && [self.backingStore count], @""); return [self.backingStore count] -1; }//NSUI max = NSNotFound; id x; return !(x = [self backingStore]) ? max : (!(max = [x count])) ?: max - 1; }

@XtraStop(NObj,Indexed)

🅒 (FakeArray) @dynamic objectEnumerator;

_UT countByEnumeratingWithState:(NSFastEnumerationState*)state
                        objects:(id __unsafe_unretained [])buffer count __UInt_ len {

  return [self.objectEnumerator countByEnumeratingWithState:state objects:buffer count:len];
}

_UT indexOfObject _ x { DEMAND_CONFORMANCE; return NSNotFound; }

//- _Ｐ(Fast) enumerator     { DEMAND_CONFORMANCE; return _ObjC_ nil; }

/// @note @required - (int) idexOfObject:(id)x;

_VD eachWithIndex ＾IDST_ b {

  _SInt idx = 0;       for (id x in self) { b(x,idx) ___ idx++ ___ }
}
_VD            do ＾ObjC_ b {

  for (id z in self) b(z);
}
￭

🅒 (Indexed)  SetKPfVA( IndexMax, @"index"        )
              SetKPfVA(    Index, @"backingStore" )
￭

🅒 (ArrayLike)

_UT countByEnumeratingWithState:(NSFastEnumerationState*)s
                        objects:(id __unsafe_unretained [])b count __UInt_ l {

  return [self.storage countByEnumeratingWithState:s objects:b count:l];
}

- (ListM<Indexed>*) storage {

  return objc_getAssociatedObject(self, _cmd) ?: ({ id x = ListM.new; objc_setAssociatedObject(self, _cmd, x, OBJC_ASSOCIATION_RETAIN_NONATOMIC); x; });
}

_VD     addObject __NObj_ x { __block id storage = self.storage;

  [x.backingStore isEqual:storage] ?: [x triggerKVO:@"backingStore" block:^(id _self) { ASSIGN_WEAK(_self,backingStore,storage); }];
  [self insertObject:x inStorageAtIndex:[storage count]];

}
_UT         count           {

  return self.storage.count;
}
_VD  removeObject _ x       {

  [self removeObjectFromStorageAtIndex:[self.storage indexOfObject:x]];
}
_VD    addObjects __List_ x {

  for (id z in x) [self    addObject:z];
}
_VD removeObjects _mList_ x {

  for (id z in x) [self removeObject:z];
}

_UT                 countOfStorage           {

  return self.storage.count;
}
_ID         objectInStorageAtIndex __UInt_ i {

  return self.storage[i];
}
_VD removeObjectFromStorageAtIndex __UInt_ i {

  [mList_ self.storage removeObjectAtIndex:i];
}
_VD                   insertObject _ x
                  inStorageAtIndex __UInt_ i {

  [mList_ self.storage insertObject:x atIndex:i];
}
_VD  replaceObjectInStorageAtIndex __UInt_ i
                        withObject _ x       {

  [mList_ self.storage replaceObjectAtIndex:i withObject:x];
}

//int ssss() {  [@{@"ss" :@2} recursiveValueForKey:(NSString *)
￭

