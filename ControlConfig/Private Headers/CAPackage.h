/* CoreAnimation - CAPackage.h
 
 Copyright (c) 2006-2007 Apple Inc.
 All rights reserved. */

#ifndef CAPACKAGE_H
#define CAPACKAGE_H

#include <QuartzCore/CABase.h>

CA_EXTERN_C_BEGIN

@class CALayer, CAMLWriter, CAMLParser;

@protocol CAMLWriterDelegate <NSObject>

@optional
- (NSURL *)CAMLWriter:(CAMLWriter *)writer URLForResource:(id)resource;
- (NSString *)CAMLWriter:(CAMLWriter *)writer IDForObject:(id)object;
- (NSString *)CAMLWriter:(CAMLWriter *)writer typeForObject:(id)object;

@end

@protocol CAMLParserDelegate <NSObject>

@optional
- (void)CAMLParser:(CAMLParser *)parser formatErrorString:(const char *)format
         arguments:(void *)args lineNumber:(NSUInteger)number;
- (void)CAMLParser:(CAMLParser *)parser formatWarningString:(const char *)format
         arguments:(void *)args lineNumber:(NSUInteger)number;
- (id)CAMLParser:(CAMLParser *)parser evaluateScriptValue:(NSString *)value
       sourceURL:(NSURL *)url lineNumber:(NSInteger)number;
- (void)CAMLParser:(CAMLParser *)parser evaluateScriptElement:(NSString *)element
         sourceURL:(NSURL *)url lineNumber:(NSInteger)number;
- (Class)CAMLParser:(CAMLParser *)parser didFailToFindClassWithName:(NSString *)className;
- (id)CAMLParser:(CAMLParser *)parser didFailToLoadResourceFromURL:(NSURL *)url;
- (void)CAMLParser:(CAMLParser *)parser didLoadResource:(id)resource fromURL:(NSURL *)url;
- (id)CAMLParser:(CAMLParser *)parser resourceForURL:(NSURL *)url;

@end

@interface CAPackage : NSObject

+ (instancetype)packageWithData:(NSData *)data
                           type:(NSString *)type
                        options:(NSDictionary *)options
                          error:(NSError **)error;

+ (instancetype)packageWithContentsOfURL:(NSURL *)url
                                    type:(NSString *)type
                                 options:(NSDictionary *)options
                                   error:(NSError **)error;

@property (readonly, getter=isGeometryFlipped) BOOL geometryFlipped;
@property (readonly) CALayer *rootLayer;

- (instancetype)_initWithData:(NSData *)data
                         type:(NSString *)type
                      options:(NSDictionary *)options
                        error:(NSError **)error;

- (instancetype)_initWithContentsOfURL:(NSURL *)url
                                  type:(NSString *)type
                               options:(NSDictionary *)options
                                 error:(NSError **)error;

- (void)foreachLayer:(void(^)(CALayer *))block;
- (NSArray<NSString *> *)publishedObjectNames;
- (id)publishedObjectWithName:(NSString *)name;
- (void)_addClassSubstitutions:(id)substitutions;
- (id)substitutedClasses;

@end

@interface CAMLWriter : NSObject

+ (instancetype)writerWithData:(id)arg1;

@property (weak) id <CAMLWriterDelegate> delegate;
@property (strong) NSURL *baseURL;

- (instancetype)initWithData:(id)arg1;

- (void)encodeObject:(id)object conditionally:(BOOL)ifExists;
- (void)encodeObject:(id)object;

@end

@interface CAMLParser : NSObject

+ (instancetype)parser;

+ (id)parseContentsOfURL:(NSURL *)url;

@property (readonly) id result;
@property (readonly) NSError *error;
@property (weak) id <CAMLParserDelegate> delegate;
@property (strong) NSURL *baseURL;

- (BOOL)parseContentsOfURL:(NSURL *)url;
- (BOOL)parseData:(NSData *)data;
- (BOOL)parseString:(NSString *)string;
- (BOOL)parseBytes:(const char *)bytes length:(uint64_t)length;

@end

/** Package types. **/

CA_EXTERN NSString * const kCAPackageTypeArchive;
CA_EXTERN NSString * const kCAPackageTypeCAMLBundle;
CA_EXTERN NSString * const kCAPackageTypeCAMLFile;

CA_EXTERN_C_END

#endif // CAPACKAGE_H
