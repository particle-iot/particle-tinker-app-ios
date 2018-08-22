//
// Created by Raimundas Sakalauskas on 14/08/2018.
// Copyright (c) 2018 Particle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ECJPakeWrapperRoleType : NSUInteger {
    ECJPakeWrapperRoleClient,
    ECJPakeWrapperRoleServer
} ECJPakeWrapperRoleType;

@interface ECJPakeWrapper : NSObject

- (instancetype)initWithRole:(ECJPakeWrapperRoleType)role lowEntropySharedPassword:(nonnull NSString *)lowEntropySharedPassword;

- (int)readRoundOne:(nonnull NSData *)inputData;
- (int)readRoundTwo:(nonnull NSData *)inputData;

- (nullable NSData *)writeRoundOne;
- (nullable NSData *)writeRoundTwo;

- (nullable NSData *)deriveSharedSecret;

@end