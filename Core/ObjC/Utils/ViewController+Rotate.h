//
//  ViewController+Rotate.h
//
//
//  Created by MK on 2022/8/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^ViewControllerRaotateBlock)(UIViewController *);

typedef NS_ENUM(NSUInteger, YXRotateState) {
    YXRotateStateUnspecified,
    YXRotateStateCanRotate,
    YXRotateStateCannotRotate,
} NS_SWIFT_NAME(RotateState);

@interface UIViewController (YXRotate)

@property (nonatomic, assign, readonly) YXRotateState yxRotateState;

@property (nullable, nonatomic, copy) ViewControllerRaotateBlock yxRotateBlock;

@end

NS_ASSUME_NONNULL_END
