//
//  Sha256WrapperTests.m
//  mbedTLSWrapperTests
//
//  Created by Raimundas Sakalauskas on 21/08/2018.
//  Copyright © 2018 Particle Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Sha256Wrapper.h"
#import "HmacWrapper.h"

@interface HashWrapperTests : XCTestCase

@end

@implementation HashWrapperTests

- (void)testSha {
    int result;
    
    Sha256Wrapper *hash = [[Sha256Wrapper alloc] init];
    XCTAssertNotNil(hash);
    
    result = [hash updateWithString:@"what"];
    XCTAssertEqual(result, 0);

    NSData *output = [hash finish];
    XCTAssertNotNil(output);

    //hash calculated using other methods
    XCTAssertTrue([output isEqualToData:[self hexStringToData:@"749ab2c0d06c42ae3b841b79e79875f02b3a042e43c92378cd28bd444c04d284"]]);
}

- (void)testMultipleSha {
    int result;

    Sha256Wrapper *hash = [[Sha256Wrapper alloc] init];
    XCTAssertNotNil(hash);

    result = [hash updateWithString:@"whatthe"];
    XCTAssertEqual(result, 0);

    NSData *output1 = [hash finish];
    XCTAssertNotNil(output1);



    hash = [[Sha256Wrapper alloc] init];
    XCTAssertNotNil(hash);

    result = [hash updateWithString:@"what"];
    XCTAssertEqual(result, 0);

    result = [hash updateWithString:@"the"];
    XCTAssertEqual(result, 0);

    NSData *output2 = [hash finish];
    XCTAssertNotNil(output2);
    
    
    XCTAssertTrue([output1 isEqualToData:output2]);
}




- (void)testHmac {
    int result;

    HmacWrapper *hmac = [[HmacWrapper alloc] initWithSeed:[self hexStringToData:@"63727970746969"]];
    XCTAssertNotNil(hmac);

    result = [hmac updateWithString:@"what"];
    XCTAssertEqual(result, 0);

    NSData *output = [hmac finish];
    XCTAssertNotNil(output);

    //hash calculated using other methods
    XCTAssertTrue([output isEqualToData:[self hexStringToData:@"21754b6174ba5ebe4cd2df6bd741f02870e73155fb24cac8a649dd574d6e4420"]]);
}



- (void)testMultipleHmac {
    int result;
    
    HmacWrapper *hmac = [[HmacWrapper alloc] initWithSeed:[self hexStringToData:@"63727970746969"]];
    XCTAssertNotNil(hmac);
    
    result = [hmac updateWithString:@"whatthe"];
    XCTAssertEqual(result, 0);
    
    NSData *output1 = [hmac finish];
    XCTAssertNotNil(output1);
    
    
    
    hmac = [[HmacWrapper alloc] initWithSeed:[self hexStringToData:@"63727970746969"]];
    XCTAssertNotNil(hmac);
    
    result = [hmac updateWithString:@"what"];
    XCTAssertEqual(result, 0);
    
    result = [hmac updateWithString:@"the"];
    XCTAssertEqual(result, 0);
    
    NSData *output2 = [hmac finish];
    XCTAssertNotNil(output2);
    
    XCTAssertTrue([output1 isEqualToData:output2]);
}


- (NSData *)hexStringToData:(NSString *)input {
    input = [input stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSMutableData *output= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [input length]/2; i++) {
        byte_chars[0] = [input characterAtIndex:i*2];
        byte_chars[1] = [input characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [output appendBytes:&whole_byte length:1];
    }
    return output;
}


@end
