//
//  YXOSUnfairLock.m
//
//  Created by MK on 2022/5/27.
//

#import "YXOSUnfairLock.h"
#import <os/lock.h>

@implementation YXOSUnfairLock {
    os_unfair_lock _lock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

- (void)lock
{
    os_unfair_lock_lock(&_lock);
}

- (void)unlock
{
    os_unfair_lock_unlock(&_lock);
}

@end
