//
// Created by Raimundas Sakalauskas on 21/08/2018.
// Copyright © 2018 Particle Inc. All rights reserved.
//

#import "HmacWrapper.h"
#import "md.h"
#import "md_internal.h"

@implementation HmacWrapper {
    NSData *_seed;
    mbedtls_md_context_t *_ctx;
}

- (instancetype)initWithSeed:(NSData *)seed {
    self = [super init];
    if (self) {
        _seed = seed;

        if ([self setup] != 0){
            return nil;
        }
    }
    return self;
}

- (int)setup {
    _ctx = malloc(sizeof(mbedtls_md_context_t));

    mbedtls_md_init(_ctx);

    int result = mbedtls_md_setup(_ctx, &mbedtls_sha256_info, 1);
    if (result != 0)
        return result;

    result = mbedtls_md_hmac_starts(_ctx, _seed.bytes, _seed.length);
    return result;
}

- (int)updateWithData:(NSData *)data {
    unsigned char *buffer = [data bytes];
    size_t bufferSize = [data length];

    int result = mbedtls_md_hmac_update(_ctx, buffer, bufferSize);
    return result;
}

- (int)updateWithString:(NSString *)string {
    return [self updateWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}


- (NSData *)finish {
    unsigned char *buffer = malloc(32);

    int result = mbedtls_md_hmac_finish(_ctx, buffer);

    if (result == 0){
        return [NSData dataWithBytes:buffer length:32];
    } else {
        return nil;
    }
}

- (void)dealloc {
    mbedtls_md_free(_ctx);
}

@end