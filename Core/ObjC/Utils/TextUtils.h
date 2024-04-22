//
//  TextUtils.h
//  MKKit
//
//  Created by MK on 2024/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextUtils : NSObject
 
FOUNDATION_EXPORT CGSize calcTextSize(CGSize fitsSize, id text, NSInteger numberOfLines, UIFont *font, NSTextAlignment textAlignment, NSLineBreakMode lineBreakMode, CGFloat minimumScaleFactor, CGSize shadowOffset);

FOUNDATION_EXPORT CGSize calcTextSizeV2(CGSize fitsSize, id text, NSInteger numberOfLines, UIFont *font);

@end

NS_ASSUME_NONNULL_END
