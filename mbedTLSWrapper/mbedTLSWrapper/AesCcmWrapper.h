//
// Created by Raimundas Sakalauskas on 15/08/2018.
// Copyright (c) 2018 Particle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AesCcmWrapper : NSObject

- (nullable instancetype)initWithKey:(NSData *)key;

- (nullable NSData *)encryptData:(nonnull NSData *)input nonce:(nonnull NSData *)nonce add:(nonnull NSData *)add tag:(NSData **)tag tagSize:(int)tagSize;
- (nullable NSData *)decryptData:(nonnull NSData *)input nonce:(nonnull NSData *)nonce add:(nonnull NSData *)add tag:(nonnull NSData *)tag;

@end
