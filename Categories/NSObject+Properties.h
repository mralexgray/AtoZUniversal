/**	
	NSObject+Properties.h		AQToolkit
	*  Created by Jim Dovey on 10/7/2008. *  Copyright (c) 2008-2009, Jim Dovey *  All rights reserved. */

/** type notes: *//*	I'm not 100% certain what @encode(NSString) would return. @encode(id) returns '@', and the types of properties are actually encoded as such along with a strong-type value following. Therefore, if you want to check for a specific class, you can provide a type string of '@"NSString"'. The following macro will do this for you. */

#define statictype(x)	"@\"" #x "\""

//typedef struct AZKVPair { __UNSF NSS*k; __UNSF id v; } AZKVPair;

// Also, note that the runtime information doesn't include an atomicity hint, so we can't determine that information

@interface NSObject (AQProperties)

- (INST) objectBySettingValuesWithDictionary:(NSD*)d;
- (INST)                objectBySettingValue: v 
                                      forKey:(NSS*)k;
- (INST)               objectBySettingValues:(NSA*)vals 
                                     forKeys:(NSA*)keys;
- (INST)                objectByIncrementing:(NSS*)k 
                                          by:(NSN*)v;
- (INST)        objectBySettingVariadicPairs:(NSA*)vsForKs;
- (INST)                   withValuesForKeys: v,...;
- (INST)                              wVsfKs: v,...;
- _Void_                    setValuesForKeys:(AZKP*)kp,...;
- _Void_                        incrementKey:(NSS*)k 
                                          by:(NSN*)v;

- _Void_  setKVs: firstKey,... NS_REQUIRES_NIL_TERMINATION;

- valueForKey:_Text_ k orKey:_Text_ other;

+ (NSD*) classPropertiesAndTypes;
+ (NSA*) objcPropertiesWithoutSuperclass;
+ (NSA*) objcProperties;
_RO NSD* propertiesPlease, * pp, * propertyNamesAndTypes;
_RO NSS * ppString; // PRIMARY PROPERTY LISTER
                      //* properties;
_RO NSA * propertyNames;
_RO BOOL hasProperties;
- (NSD*) propertiesSans:						(NSS*)someKey;
- (NSD*) propertiesSansKeys: 					(NSA*)someKeys;
+ (BOOL) hasProperties;
+ (BOOL) hasPropertyNamed: 					(NSS*) name;
+ (BOOL) hasPropertyNamed: 					(NSS*) name ofType: (const char *) type;	// an @encode() or statictype() type string
+ (BOOL) hasPropertyForKVCKey: 				(NSS*) key;
+ (const char *) typeOfPropertyNamed: 		(NSS*) name;	// returns an @encode() or statictype() string. Copy to keep
- (Class) classOfPropertyNamed:		 		(NSS*) name;	// returns an @encode() or statictype() string. Copy to keep
+ (SEL) getterForPropertyNamed: 				(NSS*) name;
+ (SEL) setterForPropertyNamed: 				(NSS*) name;
+ (NSS*) retentionMethodOfPropertyNamed: 	(NSS*) name;	// returns one of: copy, retain, assign
+ (NSA*) propertyNames;
+ (NSD*) propertyNamesAndTypes;
- (NSArray*) attributesOfProp:(NSString*)propName;

// instance convenience accessors for above routines (who likes to type [myObj class] all the time ?)
_IT hasPropertyNamed                __Text_ name ___
_IT hasPropertyNamed                __Text_ name ofType: (const char *) type ___
_IT hasPropertyForKVCKey            __Text_ key  ___
- _CChr_ typeOfPropertyNamed        __Text_ name ___
_MH getterForPropertyNamed          __Text_ name ___
_MH setterForPropertyNamed          __Text_ name ___
_TT retentionMethodOfPropertyNamed  __Text_ name ___

+ _List_ az_propertyNames;
+ _Dict_ az_propertyNamesAndTypes;
+ _Text_ az_getPropertyType:(NSS*)attributeString;

_RO _List az_properties
__        objectKeys
__        primitiveKeys
___

@end

@interface NSDictionary  (PropertyMap)

_VD mapPropertiesToObject:	x; ///   USAGE: [someDict mapPropertiesToObject: someObject];

@end

/*! Pure C API addition to the existing API in objc/runtime.h. The functions above are implemented in terms of these.
    @return a static buffer 
    @note copy the string to retain it, as it will be overwritten on the next call to this function
 */
const char * property_getTypeString( objc_property_t property );

/// getter/setter functions: unlike those above, these return NULL unless a getter/setter is EXPLICITLY defined
SEL property_getGetter(objc_property_t p);
SEL property_getSetter(objc_property_t p);

/// this returns a static (data-segment) string, so the caller does not need to call free() on the result
const char * property_getRetentionMethod( objc_property_t property );

/*	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions  are met: Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.	*  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.	*  Neither the name of this project's author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.	* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.	*/

