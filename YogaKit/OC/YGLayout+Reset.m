//
//  YGLayout+Reset.m
//  YogaWorkout
//
//  Created by MK on 2021/6/21.
//

#import "YGLayout+Reset.h"
#import <objc/runtime.h>
#import <yoga/Yoga.h>

@interface YGLayout (XX)

@property (nonatomic, assign, readwrite) YGNodeRef node;

@property (nonatomic, weak, readonly) UIView *view;

@end

@implementation YGLayout (YX_RESET)

- (void)setNode:(YGNodeRef)node
{
    Ivar ivar = class_getInstanceVariable([self class], "_node");
    ((void (*)(id, Ivar, YGNodeRef))object_setIvar)(self, ivar, node);
}

- (void)ygReset
{
    [self ygIsolate];

    YGNodeRef node = self.node;

    if (node) {
        void *ctx = YGNodeGetContext(node);
        YGNodeReset(node);
        YGNodeSetContext(node, ctx);
    }
}

- (void)ygIsolate
{
    YGNodeRef node = self.node;
    if (node) {
        YGNodeRef owner = YGNodeGetOwner(node);
        if (owner != NULL) {
            YGNodeRemoveChild(owner, node);
        }
        YGNodeRemoveAllChildren(node);
    }
}

@end
