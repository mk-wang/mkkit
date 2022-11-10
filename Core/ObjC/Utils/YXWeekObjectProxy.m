//
//  YXWeekObjectProxy.m
//  YogaWorkout
//
//  Created by MK on 2021/9/15.
//

#import "YXWeekObjectProxy.h"

@interface YXWeekObjectProxy ()

@property (nonatomic, readwrite, weak) id target;

@end

@implementation YXWeekObjectProxy

- (instancetype)initWithTarget:(id)target
{
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target
{
    return [[self alloc] initWithTarget:target];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return true;
    }
    if ([_target respondsToSelector:aSelector]) {
        return true;
    }
    return false;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return [_target isKindOfClass:aClass];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [[_target class] instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if (![_target respondsToSelector:anInvocation.selector]) {
        return;
    }
    [anInvocation invokeWithTarget:_target];
}

@end
