//
// Created by Raimundas Sakalauskas on 21/08/2018.
// Copyright (c) 2018 Particle Inc. All rights reserved.
//

#import "Sha256Wrapper.h"
#import "sha256.h"



@implementation Sha256Wrapper {
    mbedtls_sha256_context *_ctx;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self setup] != 0){
            return nil;
        }
    }
    return self;
}

- (int)setup {
    _ctx = malloc(sizeof(mbedtls_sha256_context));

    mbedtls_sha256_init(_ctx);
    int result = mbedtls_sha256_starts_ret(_ctx, 0);

    return result;
}

- (int)updateWithData:(NSData *)data {
    unsigned char *buffer = [data bytes];
    size_t bufferSize = [data length];

    int result = mbedtls_sha256_update_ret(_ctx, buffer, bufferSize);
    return result;
}

- (int)updateWithString:(NSString *)string {

    return [self updateWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData *)finish {
    unsigned char *buffer = malloc(32);

    int result = mbedtls_sha256_finish_ret(_ctx, buffer);
    if (result == 0){
        return [NSData dataWithBytes:buffer length:32];
    } else {
        return nil;
    }
}

- (void)dealloc {
    mbedtls_sha256_free(_ctx);
}


@end
