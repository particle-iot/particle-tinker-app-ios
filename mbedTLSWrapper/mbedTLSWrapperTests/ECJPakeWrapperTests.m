//
//  ECJPakeWrapperTests.m
//  ECJPakeWrapperTests
//
//  Created by Raimundas Sakalauskas on 14/08/2018.
//  Copyright © 2018 Particle Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ECJPakeWrapper.h"

@interface ECJPakeWrapperTests : XCTestCase

@end

@implementation ECJPakeWrapperTests

- (void)testSamePasswordProducesSameSecret {
    XCTAssertTrue([self performHandshake:@"password" serverPassword:@"password"]);
}

- (void)testDifferentPasswordProducesDifferentSecret {
    XCTAssertFalse([self performHandshake:@"password1" serverPassword:@"password2"]);
}

- (bool)performHandshake:(NSString *)clientPassword serverPassword:(NSString *)serverPassword {
    int result;

    ECJPakeWrapper *server = [[ECJPakeWrapper alloc] initWithRole:ECJPakeWrapperRoleServer lowEntropySharedPassword:serverPassword];
    XCTAssertNotNil(server);

    ECJPakeWrapper *client = [[ECJPakeWrapper alloc] initWithRole:ECJPakeWrapperRoleClient lowEntropySharedPassword:clientPassword];
    XCTAssertNotNil(client);

    NSData *c1 = [client writeRoundOne];
    XCTAssertNotNil(c1);
    result = [server readRoundOne:c1];
    XCTAssertEqual(result, 0);

    NSData *s1 = [server writeRoundOne];
    XCTAssertNotNil(s1);
    result = [client readRoundOne:s1];
    XCTAssertEqual(result, 0);

    NSData *c2 = [client writeRoundTwo];
    XCTAssertNotNil(c2);
    result = [server readRoundTwo:c2];
    XCTAssertEqual(result, 0);

    NSData *s2 = [server writeRoundTwo];
    XCTAssertNotNil(s2);
    result = [client readRoundTwo:s2];
    XCTAssertEqual(result, 0);

    NSData *clientResult = [client deriveSharedSecret];
    XCTAssertNotNil(clientResult);
    NSData *serverResult = [server deriveSharedSecret];
    XCTAssertNotNil(serverResult);

    return [clientResult isEqualToData:serverResult];
}




@end
