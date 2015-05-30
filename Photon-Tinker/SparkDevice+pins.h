//
//  SPKCore.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spark-SDK.h>
#import "SPKCorePin.h"

@interface SparkDevice(pins)

@property (nonatomic, strong) NSArray *pins;
@property (nonatomic, strong) NSNumber *flashingTimeLeft;

- (void)resetPins;
- (void)configurePins:(SparkDeviceType)deviceType;
- (void)updatePin:(NSString *)pin function:(SPKCorePinFunction)function value:(NSUInteger)value success:(void (^)(NSUInteger value))success failure:(void (^)(NSString *error))failure;
-(BOOL)isRunningTinker;


@end
