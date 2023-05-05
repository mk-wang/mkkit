//
//  YXCipherUtils.m
//  MKKit
//
//  Created by MK on 2023/5/5.
//

#import "YXCipherUtils.h"
#import <CommonCrypto/CommonCryptor.h>

static NSData *_Nullable aesOperation(NSData *contentData, NSData *keyData, NSData *ivData, CCOperation operation, size_t keySize)
{
    NSUInteger dataLength = contentData.length;

    void const *initVectorBytes = ivData.bytes;
    void const *contentBytes = contentData.bytes;
    void const *keyBytes = keyData.bytes;

    size_t operationSize = dataLength + kCCBlockSizeAES128;
    void *operationBytes = malloc(operationSize);
    if (operationBytes == NULL) {
        return nil;
    }
    size_t actualOutSize = 0;

    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyBytes,
                                          keySize,
                                          initVectorBytes,
                                          contentBytes,
                                          dataLength,
                                          operationBytes,
                                          operationSize,
                                          &actualOutSize);

    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
    }
    free(operationBytes);
    operationBytes = NULL;
    return nil;
}

NSData *_Nullable yx_aes128Encrypt(NSData *data, NSString *key, NSString *iv)
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    //    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];

    return aesOperation(data, keyData, ivData, kCCEncrypt, kCCKeySizeAES128);
}

NSData *_Nullable yx_aes128Decrypt(NSData *data, NSString *key, NSString *iv)
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    //    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];

    return aesOperation(data, keyData, ivData, kCCDecrypt, kCCKeySizeAES128);
}
