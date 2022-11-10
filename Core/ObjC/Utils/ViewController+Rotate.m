//
//  ViewController+Rotate.m
//
//
//  Created by MK on 2022/8/17.
//

#import "ViewController+Rotate.h"
#import <objc/runtime.h>

@implementation UIViewController (YXRotate)

@dynamic yxRotateState;
@dynamic yxRotateBlock;

- (YXRotateState)yxRotateState
{
    ViewControllerRaotateBlock block = self.yxRotateBlock;

    if (block == nil) {
        return YXRotateStateUnspecified;
    }

    return block(self) ? YXRotateStateCanRotate : YXRotateStateCannotRotate;
}

- (ViewControllerRaotateBlock)yxRotateBlock
{
    return (ViewControllerRaotateBlock)objc_getAssociatedObject(self, @selector(yxRotateBlock));
}

- (void)setYxRotateBlock:(ViewControllerRaotateBlock)block
{
    objc_setAssociatedObject(self, @selector(yxRotateBlock), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
