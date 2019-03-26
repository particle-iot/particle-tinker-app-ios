//
//  Device.m
//  Particle IOS
//
//  Copyright (c) 2013 Particle Devices. All rights reserved.
//

#import "ParticleDevice+pins.h"
#import "DevicePin.h"
#import <objc/runtime.h>


#define ALL_FUNCTIONS (DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogRead|DevicePinFunctionAnalogWrite)


@implementation ParticleDevice(pins)


- (void)resetPins
{
    for (DevicePin *pin in self.pins) {
        pin.selectedFunction = DevicePinFunctionNone;
        [pin resetValue];
    }
}


@dynamic pins;

- (void)setPins:(NSArray *)pins
{
    objc_setAssociatedObject(self, @selector(pins), pins, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)pins
{
    return objc_getAssociatedObject(self, @selector(pins));
}


- (void)configurePins:(ParticleDeviceType)deviceType
{
    DevicePin *a0, *a1, *a2, *a3, *a4, *a5, *a6, *a7;
    DevicePin *d0, *d1, *d2, *d3, *d4, *d5, *d6, *d7;
    
    switch (deviceType) {
        case ParticleDeviceTypeCore:
            a0 = [[DevicePin alloc] initWithLabel:@"A0" logicalName:@"A0" side:DevicePinSideLeft row:7 availableFunctions:ALL_FUNCTIONS];
            a1 = [[DevicePin alloc] initWithLabel:@"A1" logicalName:@"A1" side:DevicePinSideLeft row:6 availableFunctions:ALL_FUNCTIONS];
            a2 = [[DevicePin alloc] initWithLabel:@"A2" logicalName:@"A2" side:DevicePinSideLeft row:5 availableFunctions:ALL_FUNCTIONS];
            a3 = [[DevicePin alloc] initWithLabel:@"A3" logicalName:@"A3" side:DevicePinSideLeft row:4 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogRead];
            a4 = [[DevicePin alloc] initWithLabel:@"A4" logicalName:@"A4" side:DevicePinSideLeft row:3 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogRead];
            a5 = [[DevicePin alloc] initWithLabel:@"A5" logicalName:@"A5" side:DevicePinSideLeft row:2 availableFunctions:ALL_FUNCTIONS];
            a6 = [[DevicePin alloc] initWithLabel:@"A6" logicalName:@"A6" side:DevicePinSideLeft row:1 availableFunctions:ALL_FUNCTIONS];
            a7 = [[DevicePin alloc] initWithLabel:@"A7" logicalName:@"A7" side:DevicePinSideLeft row:0 availableFunctions:ALL_FUNCTIONS];
            
            d0 = [[DevicePin alloc] initWithLabel:@"D0" logicalName:@"D0" side:DevicePinSideRight row:7 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogWrite];
            d1 = [[DevicePin alloc] initWithLabel:@"D1" logicalName:@"D1" side:DevicePinSideRight row:6 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogWrite];
            d2 = [[DevicePin alloc] initWithLabel:@"D2" logicalName:@"D2" side:DevicePinSideRight row:5 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite];
            d3 = [[DevicePin alloc] initWithLabel:@"D3" logicalName:@"D3" side:DevicePinSideRight row:4 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite];
            d4 = [[DevicePin alloc] initWithLabel:@"D4" logicalName:@"D4" side:DevicePinSideRight row:3 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite];
            d5 = [[DevicePin alloc] initWithLabel:@"D5" logicalName:@"D5" side:DevicePinSideRight row:2 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite];
            d6 = [[DevicePin alloc] initWithLabel:@"D6" logicalName:@"D6" side:DevicePinSideRight row:1 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite];
            d7 = [[DevicePin alloc] initWithLabel:@"D7" logicalName:@"D7" side:DevicePinSideRight row:0 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite];

            break;
            
        default: // Photon
            a0 = [[DevicePin alloc] initWithLabel:@"A0" logicalName:@"A0" side:DevicePinSideLeft row:7 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogRead];
            a1 = [[DevicePin alloc] initWithLabel:@"A1" logicalName:@"A1" side:DevicePinSideLeft row:6 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogRead];
            a2 = [[DevicePin alloc] initWithLabel:@"A2" logicalName:@"A2" side:DevicePinSideLeft row:5 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogRead];
            a3 = [[DevicePin alloc] initWithLabel:@"A3" logicalName:@"A3" side:DevicePinSideLeft row:4 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogRead|DevicePinFunctionAnalogWriteDAC];
            a4 = [[DevicePin alloc] initWithLabel:@"A4" logicalName:@"A4" side:DevicePinSideLeft row:3 availableFunctions:ALL_FUNCTIONS]; // (II) Analog write duplicated to value in D3 (mention in UI)
            a5 = [[DevicePin alloc] initWithLabel:@"A5" logicalName:@"A5" side:DevicePinSideLeft row:2 availableFunctions:ALL_FUNCTIONS]; // (I) Analog write duplicated to value in D2 (mention in UI)
            a6 = [[DevicePin alloc] initWithLabel:@"DAC" logicalName:@"A6" side:DevicePinSideLeft row:1 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogRead|DevicePinFunctionAnalogWriteDAC];
            a7 = [[DevicePin alloc] initWithLabel:@"WKP" logicalName:@"A7" side:DevicePinSideLeft row:0 availableFunctions:ALL_FUNCTIONS];
            
            d0 = [[DevicePin alloc] initWithLabel:@"D0" logicalName:@"D0" side:DevicePinSideRight row:7 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogWrite];
            d1 = [[DevicePin alloc] initWithLabel:@"D1" logicalName:@"D1" side:DevicePinSideRight row:6 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogWrite];
            d2 = [[DevicePin alloc] initWithLabel:@"D2" logicalName:@"D2" side:DevicePinSideRight row:5 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogWrite];
            d3 = [[DevicePin alloc] initWithLabel:@"D3" logicalName:@"D3" side:DevicePinSideRight row:4 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite|DevicePinFunctionAnalogWrite]; // (II) Analog write duplicated to value in A3 (mention in UI)
            d4 = [[DevicePin alloc] initWithLabel:@"D4" logicalName:@"D4" side:DevicePinSideRight row:3 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite]; // (II) Analog write duplicated to value in A4 (mention in UI)
            d5 = [[DevicePin alloc] initWithLabel:@"D5" logicalName:@"D5" side:DevicePinSideRight row:2 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite];
            d6 = [[DevicePin alloc] initWithLabel:@"D6" logicalName:@"D6" side:DevicePinSideRight row:1 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite];
            d7 = [[DevicePin alloc] initWithLabel:@"D7" logicalName:@"D7" side:DevicePinSideRight row:0 availableFunctions:DevicePinFunctionDigitalRead|DevicePinFunctionDigitalWrite];

            break;
    }

    self.pins = @[a0, a1, a2, a3, a4, a5, a6, a7, d0, d1, d2, d3, d4, d5, d6, d7];
}



- (void)updatePin:(NSString *)pin function:(DevicePinFunction)function value:(NSUInteger)value success:(void (^)(NSInteger value))success failure:(void (^)(NSString *error))failure
{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{ @"access_token": self.user.token }];
//    NSMutableString *path = [NSMutableString stringWithFormat:@"v1/devices/%@/", [coreId hexString]];

    NSString *functionName;
    NSMutableArray *args = [NSMutableArray new];
    
    switch (function) {
        case DevicePinFunctionAnalogRead:
            functionName = @"analogread";
            [args addObject:pin];
            break;
        case DevicePinFunctionAnalogWriteDAC:
        case DevicePinFunctionAnalogWrite:
            functionName = @"analogwrite";
            [args addObject:pin];
            [args addObject:@(value)];
            break;
        case DevicePinFunctionDigitalRead:
            functionName = @"digitalread";
            [args addObject:pin];
            break;
        case DevicePinFunctionDigitalWrite:
            functionName = @"digitalwrite";
            [args addObject:pin];
            [args addObject:(value ? @"HIGH" : @"LOW")];
            break;
        default:
            break;
    }
    
//    [self callMethod:@"POST" path:path parameters:params notifyAuthenticationFailure:YES success:^(NSInteger statusCode, id JSON) {
//        NSString *errorMessage = JSON[@"error"];
//        if (!errorMessage && JSON[@"return_value"] != [NSNull null]) {
//            success([JSON[@"return_value"] unsignedIntegerValue]);
//        } else {
//            failure(errorMessage);
//        }
//    } failure:^(NSInteger statusCode, id JSON) {
//        failure([NSString stringWithFormat:@"Unknown error: %d", statusCode]);
//    }];
    
    [self callFunction:functionName withArguments:args completion:^(NSNumber *returnValue, NSError *error) {
        if (!error)
        {
            success([returnValue intValue]);
        }
        else
        {
            failure(error.localizedDescription);
        }
    }];
}

-(BOOL)isRunningTinker
{
    if (self.connected)
    {
        if (([self.functions containsObject:@"digitalread"]) && ([self.functions containsObject:@"digitalwrite"]) && ([self.functions containsObject:@"analogwrite"]) && ([self.functions containsObject:@"analogread"]))
            return YES;
        else
            return NO;
    }
    else
        return NO;
}

- (BOOL)is3rdGen {
    return self.type == ParticleDeviceTypeArgon || self.type == ParticleDeviceTypeBoron || self.type == ParticleDeviceTypeXenon || self.type == ParticleDeviceTypeASeries || self.type == ParticleDeviceTypeBSeries || self.type == ParticleDeviceTypeXSeries;
}

@end
