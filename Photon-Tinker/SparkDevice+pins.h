//
//  SPKCore.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spark-SDK.h>
#import "DevicePin.h"

@interface SparkDevice(pins)

@property (nonatomic, strong) NSArray *pins;

- (void)resetPins;
- (void)configurePins:(SparkDeviceType)deviceType;
- (void)updatePin:(NSString *)pin function:(DevicePinFunction)function value:(NSUInteger)value success:(void (^)(NSUInteger value))success failure:(void (^)(NSString *error))failure;
-(BOOL)isRunningTinker;


@end
