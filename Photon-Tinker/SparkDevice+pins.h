//
//  SPKCore.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spark-SDK.h>

@interface SparkDevice(pins)

@property (nonatomic, strong) NSArray *pins;

- (void)resetPins;
- (void)configurePins:(SparkDeviceType)deviceType;

@end
