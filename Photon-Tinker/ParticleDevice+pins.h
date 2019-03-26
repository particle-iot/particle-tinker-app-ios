//
//  SPKCore.h
//  Particle IOS
//
//  Copyright (c) 2013 Particle Devices. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Particle-SDK.h>
#import "DevicePin.h"

@interface ParticleDevice(pins)

@property (nonatomic, strong) NSArray *pins;

- (void)resetPins;
- (void)configurePins:(ParticleDeviceType)deviceType;
- (void)updatePin:(NSString *)pin function:(DevicePinFunction)function value:(NSUInteger)value success:(void (^)(NSInteger value))success failure:(void (^)(NSString *error))failure;
- (BOOL)isRunningTinker;
- (BOOL)is3rdGen;
@end
