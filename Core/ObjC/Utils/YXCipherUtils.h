//
//  YXCipherUtils.h
//  MKKit
//
//  Created by MK on 2023/5/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSData *_Nullable yx_aes128Encrypt(NSData *data, NSString *key, NSString *iv);
FOUNDATION_EXPORT NSData *_Nullable yx_aes128Decrypt(NSData *data, NSString *key, NSString *iv);

NS_ASSUME_NONNULL_END
