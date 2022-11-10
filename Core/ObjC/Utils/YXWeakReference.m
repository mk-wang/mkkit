//
//  YXWeakReference.m
//
//
//  Created by MK on 2022/7/15.
//

#import "YXWeakReference.h"

@implementation YXWeakReference

+ (YXWeakReference *)referenceWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (id)initWithObject:(id)object
{
    self = [super init];
    if (self != nil) {
        _object = object;
    }
    return self;
}

@end
