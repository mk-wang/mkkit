//
//  YXWeekObjectProxy.h
//  YogaWorkout
//
//  Created by MK on 2021/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXWeekObjectProxy : NSObject

@property (nonatomic, readonly, weak) id target;

- (instancetype)initWithTarget:(__nullable id)target;

+ (instancetype)proxyWithTarget:(__nullable id)target;

@end

NS_ASSUME_NONNULL_END
