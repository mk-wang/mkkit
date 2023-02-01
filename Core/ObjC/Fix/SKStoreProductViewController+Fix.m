//
//  SKStoreProductViewController+Fix.m
//  MKKit
//
//  Created by MK on 2023/2/1.
//  patch for iOS 15.7.*, except 15.7.1
// https://stackoverflow.com/questions/72907240/skstoreproductviewcontroller-crashes-for-unrecognized-selector-named-scenediscon
//  https://www.jianshu.com/p/c24718152473

#import "SKStoreProductViewController+Fix.h"
#import <objc/runtime.h>

@implementation SKStoreProductViewController (MK_FIX)

+ (void)load
{
    if (@available(iOS 16.0, *)) {
        return;
    }
    if (@available(iOS 15.7, *)) {
    } else {
        return;
    }

    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    if (version.patchVersion == 1) {
        return;
    }

    NSString *selName = @"sceneDisconnected:";
    SEL sel = NSSelectorFromString(selName);
    Method method1 = class_getInstanceMethod([self class], sel);
    if (method1 == nil) {
        class_addMethod([self class], sel, (IMP)mk_custom_sceneDisconnected, "v@:@");
    }

    selName = @"appWillTerminate";
    sel = NSSelectorFromString(selName);
    Method method2 = class_getInstanceMethod([self class], sel);
    if (method2 == nil) {
        class_addMethod([self class], sel, (IMP)mk_custom_appWillTerminate, "v@");
    }
}

void mk_custom_sceneDisconnected(id self, SEL _cmd, id params)
{
    // DoNothing
}

void mk_custom_appWillTerminate(id self, SEL _cmd)
{
    // DoNothing
}

@end
