//
//  AesCcmWrappedTests.m
//  mbedTLSWrapperTests
//
//  Created by Raimundas Sakalauskas on 16/08/2018.
//  Copyright © 2018 Particle Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ECJPakeWrapper.h"
#import "AesCcmWrapper.h"

@interface AesCcmWrappedTests : XCTestCase

@end


// Size of the AES key in bytes
const int AES_CCM_KEY_SIZE = 16;

// Size of the fixed part of the nonce
const int AES_CCM_FIXED_NONCE_SIZE = 8;

// Size of the authentication field
const int AES_CCM_TAG_SIZE = 8;



@implementation AesCcmWrappedTests {
    NSData *_sharedSecret;
    NSData *_key;
    NSData *_reqFixedNonce;
    NSData *_respFixedNonce;

    NSData *_add;
    NSData *_data;
}


- (void)setUp {
    [super setUp];

    _sharedSecret = [self getSharedSecret];
    _key = [_sharedSecret subdataWithRange:NSMakeRange(0, AES_CCM_KEY_SIZE)];
    _reqFixedNonce = [_sharedSecret subdataWithRange:NSMakeRange(AES_CCM_KEY_SIZE, AES_CCM_FIXED_NONCE_SIZE)];
    _respFixedNonce = [_sharedSecret subdataWithRange:NSMakeRange(AES_CCM_KEY_SIZE + AES_CCM_FIXED_NONCE_SIZE, AES_CCM_FIXED_NONCE_SIZE)];

    _add = [self getAdd];
    _data = [self getData];

}

- (void)tearDown {
    [super tearDown];

    _sharedSecret = nil;
    _key = nil;
    _reqFixedNonce = nil;
    _respFixedNonce = nil;

    _add = nil;
    _data = nil;
}

- (void)testEncryptionWithCorrectKeys {
    NSData *tag = nil;

    AesCcmWrapper *aes = [[AesCcmWrapper alloc] initWithKey:_key];
    XCTAssertNotNil(aes);

    NSData *encrypted = [aes encryptData:_data nonce:_reqFixedNonce add:_add tag:&tag tagSize:AES_CCM_TAG_SIZE];
    XCTAssertNotNil(tag);
    XCTAssertNotNil(encrypted);

    NSData *decrypted = [aes decryptData:encrypted nonce:_reqFixedNonce add:_add tag:tag];
    XCTAssertNotNil(decrypted);
    XCTAssertTrue([_data isEqualToData:decrypted]);
}

- (void)testEncryptionFailsWithInCorrectKeys {
    NSData *tag = nil;

    AesCcmWrapper *aes = [[AesCcmWrapper alloc] initWithKey:_key];
    XCTAssertNotNil(aes);

    NSData *encrypted = [aes encryptData:_data nonce:_reqFixedNonce add:_add tag:&tag tagSize:AES_CCM_TAG_SIZE];
    XCTAssertNotNil(tag);
    XCTAssertNotNil(encrypted);

    NSData *decrypted;

    //nonce mismatch
    decrypted = [aes decryptData:encrypted nonce:[self reverseData:_respFixedNonce] add:_add tag:tag];
    XCTAssertNil(decrypted);

    //add mismatch
    decrypted = [aes decryptData:encrypted nonce:_respFixedNonce add:[self reverseData:_add] tag:tag];
    XCTAssertNil(decrypted);

    //tag mismatch
    decrypted = [aes decryptData:encrypted nonce:_respFixedNonce add:_add tag:[self reverseData:tag]];
    XCTAssertNil(decrypted);
}


- (NSData *)reverseData:(NSData *)data {
    const char *bytes = [data bytes];
    int idx = [data length] - 1;
    char *reversedBytes = calloc(sizeof(char),[data length]);
    for (int i = 0; i < [data length]; i++) {
        reversedBytes[idx--] = bytes[i];
    }
    NSData *reversedData = [NSData dataWithBytes:reversedBytes length:[data length]];
    free(reversedBytes);
    return reversedData;
}

- (NSData *)getData {
    return [@"secret message?" dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)getAdd {
    return [@"not a secret add" dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)getSharedSecret {
    ECJPakeWrapper *server = [[ECJPakeWrapper alloc] initWithRole:ECJPakeWrapperRoleServer lowEntropySharedPassword:@"password"];
    ECJPakeWrapper *client = [[ECJPakeWrapper alloc] initWithRole:ECJPakeWrapperRoleClient lowEntropySharedPassword:@"password"];

    NSData *c1 = [client writeRoundOne];
    [server readRoundOne:c1];

    NSData *s1 = [server writeRoundOne];
    [client readRoundOne:s1];

    NSData *c2 = [client writeRoundTwo];
    [server readRoundTwo:c2];

    NSData *s2 = [server writeRoundTwo];
    [client readRoundTwo:s2];

    NSData *clientResult = [client deriveSharedSecret];

    return clientResult;
}

@end
