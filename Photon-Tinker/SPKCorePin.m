//
//  SPKCorePin.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKCorePin.h"

@interface SPKCorePin ()

@property (nonatomic, assign) BOOL valueSet;
@property (nonatomic, assign) NSUInteger value;

@end

@implementation SPKCorePin

- (id)initWithLabel:(NSString *)label logicalName:(NSString *)name side:(SPKCorePinSide)side row:(NSUInteger)row availableFunctions:(SPKCorePinFunction)availableFunctions
{
    if (self = [super init]) {
        _label = label;
        _side = side;
        _row = row;
        _logicalName = name;
        _availableFunctions = availableFunctions;
        _selectedFunction = SPKCorePinFunctionNone;
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
        case SPKCorePinFunctionDigitalRead:
            return SPKCorePinFunctionDigitalReadColor;
        case SPKCorePinFunctionDigitalWrite:
            return SPKCorePinFunctionDigitalWriteColor;
        case SPKCorePinFunctionAnalogRead:
            return SPKCorePinFunctionAnalogReadColor;
        case SPKCorePinFunctionAnalogWrite:
            return SPKCorePinFunctionAnalogWriteColor;
        default:
            return SPKCorePinFunctionNoneColor;
    }
}

@end
