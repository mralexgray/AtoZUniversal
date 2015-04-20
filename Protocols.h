


#import <AtoZUniversal/Rectlike.h>

@Vows TypedArray <NObj> @concrete _AT Class objectClass;
@Stop

@Vows Random   <NObj>

             + _Kind_ random;              // implement random and you get random:ct for free!
@concrete    + _List_ random:_UInt_ ct;     // ie. +[NSColor random:10] -> 10 randos..
@Stop

_Type struct  { _SInt rangeMin; _SInt rangeMax; _SInt currentIndex; } _Indx;

@Vows Indexed   <NSO>

@concrete  _RO Ｐ(NSFastEnumeration) backingStore;
//           _RO                NSUI  indexMax,
//                                    index;
￭

@Vows FakeArray <NObj,Fast>
@Reqd

_RO // Ｐ(Fast)
    NSEnumerator* objectEnumerator ___
_UT             indexOfObject _ x ___

@concrete

_UT countByEnumeratingWithState _ (NSFastEnumerationState*)state
                        objects _ (_ObjC __unsafe_unretained [])buffer
                          count __UInt_ len;

_VD eachWithIndex ＾IDST_ b ___     // Dep's on indexOffObject:
_VD            do ＾ObjC_ b ___      // Dep's on <NSFastEnumeration>
￭

DECLARECONFORMANCE(List,FakeArray)

@Vows ArrayLike <NSO,Fast>

@concrete _AT   List <Indexed> *storage;
          _RO _UInt count;

- _Void_     addObject _ x ___
- _Void_  removeObject _ x ___
- _Void_    addObjects _ _List_ x ___
- _Void_ removeObjects _ _List_ x ___

@Stop


@Vows PrimitiveAccess <NObj>

#define SYNTHESIZE_GET_SET(get,Set,KIND) \
  _VD        set##Set _##KIND##_ x \
               forKey __Ｐ(Code) k ___ \
  - KIND##_ get##ForKey __Ｐ(Code) k ___

SYNTHESIZE_GET_SET(bool,    Bool,    _IsIt)
SYNTHESIZE_GET_SET(integer, Integer, _SInt)
SYNTHESIZE_GET_SET(float,   Float,   _Flot)
SYNTHESIZE_GET_SET(string,  String,  _Text)
SYNTHESIZE_GET_SET(data,    Data,    _Data)


_VD            setObject __ObjC_ v
                  forKey __Ｐ(Code) k ___
- __ObjC_ objectForKey __Ｐ(Code) k ___

￭


//_VD       setBool __IsIt_ b
//           forKey __Text_ k ___
//_IT    boolForKey __Text_ k ___

//_VD    setInteger __SInt_ i
//           forKey __Text_ k ___
//_ST integerForKey __Text_ k ___

//_VD     setDouble __Flot_ f
//           forKey __Text_ k ___
//_FT   floatForKey __Text_ k ___

//_VD     setString __Text_ s
//           forKey __Text_ k ___
//_TT  stringForKey __Text_ k ___

//_VD       setData __Data_ d
//           forKey __Text_ k ___
//_DA    dataForKey __Text_ k ___
