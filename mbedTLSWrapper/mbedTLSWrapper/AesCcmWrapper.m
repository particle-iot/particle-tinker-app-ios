//
// Created by Raimundas Sakalauskas on 15/08/2018.
// Copyright (c) 2018 Particle Inc. All rights reserved.
//

#import "AesCcmWrapper.h"
#import "ccm.h"
#import "cipher.h"


@implementation AesCcmWrapper {
    NSData *_key;
    mbedtls_ccm_context *_ccmCtx;
}

- (instancetype)initWithKey:(NSData *)key {
    self = [super init];
    if (self) {
        _key = key;

        if ([self setup] != 0){
            return nil;
        }
    }

    return self;
}

- (int)setup {
    const unsigned char* key = [_key bytes];
    unsigned int keySize = [_key length] * 8;

    _ccmCtx = malloc(sizeof(mbedtls_ccm_context));
    mbedtls_ccm_init(_ccmCtx);
    int result = mbedtls_ccm_setkey(_ccmCtx, MBEDTLS_CIPHER_ID_AES, key, keySize);

    return result;
}
- (NSData *)encryptData:(NSData *)input nonce:(NSData *)nonce add:(NSData *)add tag:(NSData **)tag tagSize:(int)tagSize {
    unsigned char *outputBuffer = malloc(input.length);
    unsigned char *tagBuffer = malloc(tagSize);

    int result = mbedtls_ccm_encrypt_and_tag(_ccmCtx, input.length,
            [nonce bytes], nonce.length,
            [add bytes], add.length,
            [input bytes], outputBuffer,
            tagBuffer, tagSize);

    if (result == 0) {
        *tag = [NSData dataWithBytes:tagBuffer length:tagSize];
        return [NSData dataWithBytes:outputBuffer length:input.length];
    } else {
        *tag = nil;
        return nil;
    }
};

- (NSData *)decryptData:(NSData *)input nonce:(NSData *)nonce add:(NSData *)add tag:(NSData *)tag {
    unsigned char *outputBuffer = malloc(input.length);

    int result = mbedtls_ccm_auth_decrypt(_ccmCtx, input.length,
            [nonce bytes], nonce.length,
            [add bytes], add.length,
            [input bytes], outputBuffer,
            [tag bytes], [tag length]);

    if (result == 0) {
        return [NSData dataWithBytes:outputBuffer length:input.length];
    } else {
        return nil;
    }
}

- (void)dealloc {
    mbedtls_ccm_free(_ccmCtx);
}

@end
