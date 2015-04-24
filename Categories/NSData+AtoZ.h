

_EnumKind(AZChecksumType, AZChecksumTypeMD5, AZChecksumTypeSha512) /*...any CC algo can be used*/

@Xtra(Data,AtoZ) _RO _Text toUTF8String, toUTF16String, toASCIIString;

_RO _ObjC JSONSerialization ___

_TT checksum:(AZChecksumType)type ___

@XtraStop(Data,AtoZ)

@Xtra(Text,FromAtoZ)

+ _Text_ stringFromArray:_List_ l ___
+ _Text_ stringFromArray:_List_ l    withSpaces:_IsIt_ spcs onePerline:_IsIt_ newl ___
+ _Text_ stringFromArray:_List_ l withDelimeter:_Text_ deli       last:_Text_ last ___ // needs blockskit

_RO _IsIt  isIntegerNumber, isFloatNumber ___

- _Text_ withString:_Text_ s ___
- _Text_   withPath:_Text_ p ___
- _Text_    withExt:_Text_ e ___

@XtraStop(Text,FromAtoZ)

@Xtra(NSParagraphStyle,AtoZ)

+ _PStl_ defaultParagraphStyleWithDictionary: _Dict_ d ___

@XtraStop(NSParagraphStyle,AtoZ)

