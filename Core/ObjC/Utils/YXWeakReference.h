//
//  YXWeakReference.h
//
//
//  Created by MK on 2022/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXWeakReference : NSObject

@property (nullable, nonatomic, weak) id object;

+ (YXWeakReference *)referenceWithObject:(id)object;

- (id)initWithObject:(id)object;

@end

NS_ASSUME_NONNULL_END
