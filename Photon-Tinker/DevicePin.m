//
//  DevicePin.m
//  Particle IOS
//
//  Copyright (c) 2013 Particle Devices. All rights reserved.
//

#import "DevicePin.h"

@interface DevicePin ()

@property (nonatomic, assign) BOOL valueSet;
@property (nonatomic, assign) NSUInteger value;

@end

@implementation DevicePin

- (id)initWithLabel:(NSString *)label logicalName:(NSString *)name side:(DevicePinSide)side row:(NSUInteger)row availableFunctions:(DevicePinFunction)availableFunctions
{
    if (self = [super init]) {
        _label = label;
        _side = side;
        _row = row;
        _logicalName = name;
        _availableFunctions = availableFunctions;
        _selectedFunction = DevicePinFunctionNone;
    }

    return self;
}

- (void)resetValue
{
    self.valueSet = NO;
    self.value = 0;
}

- (void)adjustValue:(NSUInteger)newValue
{
    self.value = newValue;
    self.valueSet = YES;
}

- (UIColor *)selectedFunctionColor
{
    switch (self.selectedFunction) {

        case DevicePinFunctionDigitalRead:
            return DevicePinFunctionDigitalReadColor;
        case DevicePinFunctionDigitalWrite:
            return DevicePinFunctionDigitalWriteColor;
        case DevicePinFunctionAnalogRead:
            return DevicePinFunctionAnalogReadColor;
        case DevicePinFunctionAnalogWrite:
            return DevicePinFunctionAnalogWriteColor;
        case DevicePinFunctionAnalogWriteDAC:
            return DevicePinFunctionAnalogWriteDACColor;
        default:
            return DevicePinFunctionNoneColor;
    }
}

@end
