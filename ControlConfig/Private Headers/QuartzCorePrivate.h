//
//  QuartzCorePrivate.h
//  Appearance Maker
//
//  Created by Guilherme Rambo on 26/03/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

@import QuartzCore;






@interface CAFilter : NSObject <NSCopying, NSMutableCopying, NSCoding>

+ (instancetype)filterWithType:(NSString *)type;
+ (NSArray <NSString *> *)filterTypes;

- (NSArray <NSString *> *)outputKeys;
- (NSArray <NSString *> *)inputKeys;
- (void)setDefaults;

@property(copy) NSString *name;
@property(readonly) NSString *type;

@property(getter=isEnabled) BOOL enabled;

@end

extern NSData *CAEncodeLayerTree(CALayer *rootLayer);

extern NSString *kCAPackageTypeArchive;
extern NSString *kCAPackageTypeCAMLBundle;

@interface CAPackage : NSObject

+ (id)packageWithData:(NSData *)data type:(NSString *)type options:(id)opts error:(NSError **)outError;
+ (id)packageWithContentsOfURL:(NSURL *)url type:(NSString *)type options:(id)opts error:(NSError **)outError;

- (NSArray <NSString *> *)publishedObjectNames;

@property(readonly, getter=isGeometryFlipped) BOOL geometryFlipped;
@property(readonly) CALayer *rootLayer;

@end


@interface CAState : NSObject <NSCoding, NSCopying> {

    NSString* _name;
    NSString* _basedOn;
    NSMutableArray* _elements;
    double _nextDelay;
    double _previousDelay;
    BOOL _enabled;
    BOOL _locked;
    BOOL _initial;

}

@property (nonatomic,copy) NSString * name;                            //@synthesize name=_name - In the implementation block
@property (copy) NSString * basedOn;                                   //@synthesize basedOn=_basedOn - In the implementation block
@property (getter=isEnabled) BOOL enabled;                             //@synthesize enabled=_enabled - In the implementation block
@property (nonatomic,copy) NSArray * elements;
@property (assign) double nextDelay;                                   //@synthesize nextDelay=_nextDelay - In the implementation block
@property (assign) double previousDelay;                               //@synthesize previousDelay=_previousDelay - In the implementation block
@property (assign,getter=isLocked,nonatomic) BOOL locked;              //@synthesize locked=_locked - In the implementation block
@property (getter=isInitial) BOOL initial;                             //@synthesize initial=_initial - In the implementation block
+(void)CAMLParserStartElement:(id)arg1 ;
-(void)CAMLParser:(id)arg1 setValue:(id)arg2 forKey:(id)arg3 ;
-(id)CAMLTypeForKey:(id)arg1 ;
-(void)encodeWithCAMLWriter:(id)arg1 ;
-(void)removeElement:(id)arg1 ;
-(NSString *)basedOn;
-(void)setBasedOn:(NSString *)arg1 ;
-(double)nextDelay;
-(void)setNextDelay:(double)arg1 ;
-(double)previousDelay;
-(void)setPreviousDelay:(double)arg1 ;
-(BOOL)isInitial;
-(id)init;
-(id)initWithCoder:(id)arg1 ;
-(void)encodeWithCoder:(id)arg1 ;
-(void)dealloc;
-(id)debugDescription;
-(void)setName:(NSString *)arg1 ;
-(NSString *)name;
-(NSArray *)elements;
-(BOOL)isLocked;
-(void)setEnabled:(BOOL)arg1 ;
-(BOOL)isEnabled;
-(id)copyWithZone:(NSZone*)arg1 ;
-(void)setLocked:(BOOL)arg1 ;
-(void)setElements:(NSArray *)arg1 ;
-(void)foreachLayer:(/*^block*/id)arg1 ;
-(void)setInitial:(BOOL)arg1 ;
-(void)addElement:(id)arg1 ;
@end


@interface CALayer (Private)
@property (assign) CGColorRef contentsMultiplyColor;
@property (nonatomic, retain) NSArray *backgroundFilters;
@property (nonatomic, retain) CAFilter *compositingFilter;
@property (assign) CGRect cornerContentsCenter;
@property (nonatomic, retain) NSString *groupName;
@property(getter=isFrozen) BOOL frozen;
@property BOOL hitTestsAsOpaque;
- (void)setAllowsGroupBlending:(BOOL)allowed;
- (CAState *)stateWithName:(NSString *)name;
-(void)setFillMode:(NSString *)arg1 ;
@end


@interface CAStateController : NSObject {
}

@property (readonly) CALayer * layer;
-(void)_removeTransition:(id)arg1 layer:(CALayer *)arg2 ;
-(void)_applyTransition:(id)arg1 layer:(CALayer *)arg2 undo:(id)arg3 speed:(float)arg4 ;
-(void)_nextStateTimer:(id)arg1 ;
-(void)setInitialStatesOfLayer:(CALayer *)arg1 transitionSpeed:(float)arg2 ;
-(void)_applyTransitionElement:(id)arg1 layer:(CALayer *)arg2 undo:(id)arg3 speed:(float)arg4 ;
-(void)_addAnimation:(id)arg1 forKey:(id)arg2 target:(id)arg3 undo:(id)arg4 ;
-(CAState *)stateOfLayer:(CALayer *)arg1 ;
-(void)setInitialStatesOfLayer:(CALayer *)arg1 ;
-(id)removeAllStateChanges;
-(void)restoreStateChanges:(id)arg1 ;
-(void)cancelTimers;
-(CALayer *)layer;
-(id)initWithLayer:(CALayer *)arg1 ;
-(void)setState:(CAState *)arg1 ofLayer:(CALayer *)arg2 transitionSpeed:(float)arg3 ;
-(void)setState:(CAState *)arg1 ofLayer:(CALayer *)arg2 ;
@end


