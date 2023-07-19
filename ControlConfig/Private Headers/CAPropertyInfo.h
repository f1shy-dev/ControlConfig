/* CoreAnimation - CAPropertyInfo.h
 
 Copyright (c) 2006-2007 Apple Inc.
 All rights reserved. */

#ifndef CAPROPERTYINFO_H
#define CAPROPERTYINFO_H

#include <QuartzCore/CABase.h>
@import QuartzCore;

CA_EXTERN_C_BEGIN

@protocol CAPropertyInfo

@optional
+ (NSDictionary *)attributesForKey:(NSString *)key;
+ (NSArray *)properties;
- (NSDictionary *)attributesForKeyPath:(NSString *)keyPath;

@end

@interface CAValueFunction ()

- (BOOL)apply:(const CGFloat *)input result:(CGFloat *)output
parameterFunction:(void */*function*/)function context:(void *)context;

- (BOOL)apply:(const CGFloat *)input
       result:(CGFloat *)output;

- (uint64_t)inputCount;
- (uint64_t)outputCount;

@end

/** Atoms. **/

CA_EXTERN NSString *CAAtomGetString(uint32_t atomId);
CA_EXTERN uint32_t CAInternAtom(NSString *key);

/** Attributes and keys. **/

CA_EXTERN NSString * const kCAAttributeType;
CA_EXTERN NSString * const kCAAttributeSubtype;
CA_EXTERN NSString * const kCAAttributeOptional;
CA_EXTERN NSString * const kCAAttributeMin;
CA_EXTERN NSString * const kCAAttributeMax;
CA_EXTERN NSString * const kCAAttributeSliderMin;
CA_EXTERN NSString * const kCAAttributeSliderMax;
CA_EXTERN NSString * const kCAAttributeIncrement;
CA_EXTERN NSString * const kCAAttributeEnumNames;
CA_EXTERN NSString * const kCAAttributeUnitSpace;

/** Value subtypes. **/

CA_EXTERN NSString * const kCASubtypeBool;
CA_EXTERN NSString * const kCASubtypeInt;
CA_EXTERN NSString * const kCASubtypeFloat;
CA_EXTERN NSString * const kCASubtypeDistance;
CA_EXTERN NSString * const kCASubtypeAngle;
CA_EXTERN NSString * const kCASubtypePercentage;
CA_EXTERN NSString * const kCASubtypeTime;
CA_EXTERN NSString * const kCASubtypeTimeInterval;
CA_EXTERN NSString * const kCASubtypeEnum;
CA_EXTERN NSString * const kCASubtypePoint;
CA_EXTERN NSString * const kCASubtypePoint3D;
CA_EXTERN NSString * const kCASubtypeSize;
CA_EXTERN NSString * const kCASubtypeRect;
CA_EXTERN NSString * const kCASubtypeTransform;
CA_EXTERN NSString * const kCASubtypeColorMatrix;

CA_EXTERN_C_END

#endif // CAPROPERTYINFO_H
