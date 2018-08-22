//
// Created by Raimundas Sakalauskas on 14/08/2018.
// Copyright (c) 2018 Particle Inc. All rights reserved.
//

#import "ECJPakeWrapper.h"
#import "ctr_drbg.h"
#import "entropy.h"
#import "ecjpake.h"
#import "ssl.h"

static const mbedtls_ecp_group_id DEFAULT_CURVE_TYPE = MBEDTLS_ECP_DP_SECP256R1;
static const mbedtls_md_type_t DEFAULT_HASH_TYPE = MBEDTLS_MD_SHA256;
static const size_t MAX_BUFFER_SIZE = MBEDTLS_SSL_MAX_CONTENT_LEN;

@implementation ECJPakeWrapper {
    NSString *_lowEntropySharedPassword;
    ECJPakeWrapperRoleType _role;

    mbedtls_ecjpake_context *_jPakeCtx;
    mbedtls_entropy_context *_entropyCtx;
    mbedtls_ctr_drbg_context *_rngCtx;

    BOOL _debug;
}

- (instancetype)initWithRole:(ECJPakeWrapperRoleType)role lowEntropySharedPassword:(NSString *)lowEntropySharedPassword {
    self = [super init];
    if (self) {
        _role = role;
        _lowEntropySharedPassword = lowEntropySharedPassword;

        if ([self setup] != 0){
            return nil;
        }
    }
    return self;
}

- (int)setup {
    _debug = NO;

    //alloc contexts
    _jPakeCtx = malloc(sizeof(mbedtls_ecjpake_context));
    _entropyCtx = malloc(sizeof(mbedtls_entropy_context));
    _rngCtx = malloc(sizeof(mbedtls_ctr_drbg_context));

    //init contexts
    mbedtls_ecjpake_init(_jPakeCtx);
    mbedtls_entropy_init(_entropyCtx);
    mbedtls_ctr_drbg_init(_rngCtx);


    unsigned char* seed = [_lowEntropySharedPassword UTF8String];
    if (_debug) {
        NSLog(@"%@: setup ----------", [self roleString]);
        NSLog(@"sizeof(seed) = %zu", strlen(seed));
    }

    //setup rngContext
    int result = mbedtls_ctr_drbg_seed(_rngCtx, mbedtls_entropy_func, _entropyCtx, seed, strlen(seed));
    if (_debug) {
        NSLog(@"mbedtls_ctr_drbg_seed result = %i", result);
    }
    if (result != 0) {
        return result;
    }

    //setup ecjpakeContext
    result = mbedtls_ecjpake_setup(_jPakeCtx, (_role == ECJPakeWrapperRoleServer) ? MBEDTLS_ECJPAKE_SERVER : MBEDTLS_ECJPAKE_CLIENT, DEFAULT_HASH_TYPE, DEFAULT_CURVE_TYPE, seed, strlen(seed));
    if (_debug) {
        NSLog(@"mbedtls_ecjpake_setup result = %i", result);
    }
    if (result != 0) {
        return result;
    }

    return result;
}

- (NSData *)writeRoundOne {
    size_t bytesWrittenToBuffer = 0;
    unsigned char *buffer = malloc(MAX_BUFFER_SIZE);

    int result = mbedtls_ecjpake_write_round_one(_jPakeCtx, buffer, MAX_BUFFER_SIZE, &bytesWrittenToBuffer, mbedtls_ctr_drbg_random, _rngCtx);
    NSData *data = [NSData dataWithBytes:buffer length:bytesWrittenToBuffer];

    if (_debug) {
        NSLog(@"%@: writeRoundOne ----------", [self roleString]);
        NSLog(@"result = %i", result);
        NSLog(@"bytesWrittenToBuffer = %lu", bytesWrittenToBuffer);
        NSLog(@"data = %@", data);
    }
    free(buffer);

    if (result == 0) {
        return data;
    } else {
        return nil;
    }
}

- (NSData *)writeRoundTwo {
    size_t bytesWrittenToBuffer = 0;
    unsigned char *buffer = malloc(MAX_BUFFER_SIZE);

    int result = mbedtls_ecjpake_write_round_two(_jPakeCtx, buffer, MAX_BUFFER_SIZE, &bytesWrittenToBuffer, mbedtls_ctr_drbg_random, _rngCtx);
    NSData *data = [NSData dataWithBytes:buffer length:bytesWrittenToBuffer];

    if (_debug) {
        NSLog(@"%@: writeRoundTwo ----------", [self roleString]);
        NSLog(@"result = %i", result);
        NSLog(@"bytesWrittenToBuffer = %lu", bytesWrittenToBuffer);
        NSLog(@"data = %@", data);
    }
    free(buffer);

    if (result == 0) {
        return data;
    } else {
        return nil;
    }
}

- (int)readRoundOne:(NSData *)inputData {
    unsigned char *buffer = [inputData bytes];
    size_t bufferSize = [inputData length];

    int result = mbedtls_ecjpake_read_round_one(_jPakeCtx, buffer, bufferSize);
    if (_debug) {
        NSLog(@"%@: readRoundOne ----------", [self roleString]);
        NSLog(@"result = %i", result);
    }

    return result;
}

- (int)readRoundTwo:(NSData *)inputData {
    unsigned char *buffer = [inputData bytes];
    size_t bufferSize = [inputData length];

    int result = mbedtls_ecjpake_read_round_two(_jPakeCtx, buffer, bufferSize);
    if (_debug) {
        NSLog(@"%@: readRoundTwo ----------", [self roleString]);
        NSLog(@"result = %i", result);
    }

    return result;
}

- (NSData *)deriveSharedSecret {
    size_t secretSize = mbedtls_md_get_size(_jPakeCtx->md_info);

    size_t bytesWrittenToBuffer = 0;
    unsigned char *buffer = malloc(secretSize);

    int result = mbedtls_ecjpake_derive_secret(_jPakeCtx, buffer, secretSize, &bytesWrittenToBuffer, mbedtls_ctr_drbg_random, _rngCtx);
    NSData *data = [NSData dataWithBytes:buffer length:bytesWrittenToBuffer];
    if (_debug) {
        NSLog(@"%@: deriveSharedSecret ----------", [self roleString]);
        NSLog(@"result = %i", result);
        NSLog(@"bytesWrittenToBuffer = %lu", bytesWrittenToBuffer);
        NSLog(@"data = %@", data);
    }

    free(buffer);

    if (result == 0) {
        return data;
    } else {
        return nil;
    }
}

- (void)dealloc {
    mbedtls_ecjpake_free(_jPakeCtx);
    mbedtls_entropy_free(_entropyCtx);
    mbedtls_ctr_drbg_free(_rngCtx);
}

- (NSString *)roleString {
    if (_role == ECJPakeWrapperRoleClient) {
        return @"Client";
    } else {
        return @"Server";
    }
}


@end