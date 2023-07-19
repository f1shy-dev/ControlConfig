/* CoreAnimation - CAState.h
 
 Copyright (c) 2006-2007 Apple Inc.
 All rights reserved. */

#ifndef CASTATE_H
#define CASTATE_H

#include <QuartzCore/CABase.h>

CA_EXTERN_C_BEGIN

@class CAStateControllerTransition, CAStateControllerUndo;

@class CAStateElement, CALayer, CAStateController, CAStateTransition;

@protocol CAStateRecorder <NSObject>

@required

- (void)addElement:(CAStateElement *)element;

@optional

- (void)willAddLayer:(CALayer *)layer;

@end

@protocol CAStateControllerDelegate <NSObject>

@optional
- (void)stateController:(CAStateController *)controller didSetStateOfLayer:(CALayer *)layer;
- (void)stateController:(CAStateController *)controller transitionDidStart:(CAStateTransition *)transition speed:(float)speed;
- (void)stateController:(CAStateController *)controller transitionDidStop:(CAStateTransition *)transition completed:(BOOL)completed;

@end

@interface CAState : NSObject <NSSecureCoding, NSCopying>

@property (getter=isInitial) BOOL initial;
@property (nonatomic, getter=isLocked) BOOL locked;
@property double previousDelay;
@property double nextDelay;
@property (getter=isEnabled) BOOL enabled;
@property (copy) NSString *basedOn;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSArray *elements;

- (void)addElement:(CAStateElement *)element;
- (void)removeElement:(CAStateElement *)element;
- (void)foreachLayer:(void(^)(CALayer *))block;

@end

@interface CAStateElement : NSObject <NSCopying, NSSecureCoding>

@property (strong, nonatomic) CAStateElement *source;
@property (nonatomic, weak) CALayer *target;
@property (readonly, copy, nonatomic) NSString *keyPath;

- (void)apply:(id)arg1;
- (BOOL)matches:(id)arg1;
- (void)foreachLayer:(void(^)(CALayer *))block;

- (id)save;
- (id)targetName;

@end

@interface CAStateAddAnimation: CAStateElement

@property (strong, nonatomic) CAAnimation *animation;
@property (copy, nonatomic) NSString *key;

@end

@interface CAStateAddElement : CAStateElement

@property (strong, nonatomic) id beforeObject;
@property (strong, nonatomic) id object;
@property (copy, nonatomic) NSString *keyPath;

@end

@interface CAStateController: NSObject

@property (weak) id<CAStateControllerDelegate> delegate;
@property (readonly) CALayer *layer;

- (instancetype)initWithLayer:(CALayer *)layer;

- (void)_applyTransitionElement:(id)arg1 layer:(CALayer *)layer undo:(id)undo speed:(float)speed;
- (void)_removeTransition:(id)arg1 layer:(CALayer *)layer;
- (void)_applyTransition:(id)arg1 layer:(CALayer *)layer undo:(id)undo speed:(float)speed;
- (void)_addAnimation:(id)arg1 forKey:(NSString *)key target:(id)target undo:(id)undo;
- (void)_nextStateTimer:(id)arg1;
- (void)cancelTimers;
- (void)restoreStateChanges:(id)arg1;
- (id)removeAllStateChanges;
- (void)setInitialStatesOfLayer:(id)arg1;
- (void)setInitialStatesOfLayer:(id)arg1 transitionSpeed:(float)arg2;
- (void)setState:(id)arg1 ofLayer:(id)arg2;
- (void)setState:(id)arg1 ofLayer:(id)arg2 transitionSpeed:(float)arg3;
- (id)stateOfLayer:(id)arg1;

@end

@interface CAStateControllerAnimation : NSObject

@property (readonly, nonatomic) NSString *key;
@property (readonly, nonatomic) CALayer *layer;

- (instancetype)initWithLayer:(CALayer *)layer key:(NSString *)key;

@end

@interface CAStateControllerLayer : NSObject

@property (readonly) CAStateControllerUndo *undoStack;
@property (strong, nonatomic) CAState *currentState;
@property (readonly) CALayer *layer;

- (instancetype)initWithLayer:(CALayer *)layer;

- (void)invalidate;
- (void)removeTransition:(CAStateControllerTransition *)transition;
- (void)addTransition:(CAStateControllerTransition *)transition;

@end

@interface CAStateControllerTransition: NSObject

@property (readonly, nonatomic) float speed;
@property (readonly, nonatomic) double duration;
@property (readonly, nonatomic) double beginTime;
@property (readonly, nonatomic) CAStateTransition *transition;
@property (readonly, nonatomic) CALayer *layer;

- (void)addAnimation:(id)arg1;
- (void)removeAnimationFromLayer:(CALayer *)layer forKey:(NSString *)key;
- (void)invalidate;

@end

@interface CAStateControllerUndo : NSObject <CAStateRecorder>

@property (strong, nonatomic) NSMutableArray *transitions;
@property (strong, nonatomic) NSMutableArray *elements;
@property (strong, nonatomic) CAState *state;
@property (readonly) CAStateControllerUndo *next;

- (void)addElement:(CAStateElement *)element;

@end

@interface CAStateRemoveAnimation : CAStateElement

@property (copy, nonatomic) NSString *key;

@end

@interface CAStateRemoveElement : CAStateElement

@property (strong, nonatomic) id object;
@property (copy, nonatomic) NSString *keyPath;

@end

@interface CAStateSetValue : CAStateElement

@property (strong, nonatomic) id value;
@property (copy, nonatomic) NSString *keyPath;

@end

@interface CAStateTransition : NSObject <NSCopying, NSSecureCoding>

@property (copy, nonatomic) NSArray *elements;
@property (copy, nonatomic) NSString *toState;
@property (copy, nonatomic) NSString *fromState;

- (double)duration;

@end

@interface CAStateTransitionElement : NSObject <NSCopying, NSSecureCoding>

@property (getter=isEnabled) BOOL enabled;
@property (copy, nonatomic) NSString *key;
@property (strong, nonatomic) CAAnimation *animation;
@property (nonatomic, weak) CALayer *target;
@property (nonatomic) double duration;
@property (nonatomic) double beginTime;

@end

@interface CALayer (State)

@property (copy) NSArray *stateTransitions;
@property (copy) NSArray *states;

- (CAStateTransition *)stateTransitionFrom:(CAState *)fromState to:(CAState *)toState;
- (NSArray<__kindof CAState *> *)dependentStatesOfState:(CAState *)state;
- (CAState *)stateWithName:(NSString *)name;
- (void)removeState:(CAState *)state;
- (void)insertState:(CAState *)state atIndex:(uint32_t)idx;
- (void)addState:(CAState *)state;

@end

CA_EXTERN_C_END

#endif // CASTATE_H
