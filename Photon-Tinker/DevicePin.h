//
//  DevicePin.h
//  Particle IOS
//
//  Copyright (c) 2013 Particle Devices. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(uint8_t, DevicePinSide)
{
    DevicePinSideLeft,
    DevicePinSideRight
};

typedef NS_OPTIONS(uint8_t, DevicePinFunction)
{
    DevicePinFunctionNone              = 0,
    DevicePinFunctionDigitalRead       = 1 << 0,
    DevicePinFunctionDigitalWrite      = 1 << 1,
    DevicePinFunctionAnalogRead        = 1 << 2,
    DevicePinFunctionAnalogWrite       = 1 << 3,
    DevicePinFunctionAnalogWriteDAC    = 1 << 4
};

#define DevicePinFunctionNoneColor             [UIColor clearColor]
#define DevicePinFunctionDigitalReadColor      [UIColor colorWithRed:0.0 green:0.67 blue:0.93 alpha:1.0]
#define DevicePinFunctionDigitalWriteColor     [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0]
#define DevicePinFunctionAnalogReadColor       [UIColor colorWithRed:0.18 green:0.8 blue:0.44 alpha:1.0]
#define DevicePinFunctionAnalogWriteColor      [UIColor colorWithRed:0.95 green:0.77 blue:0.06 alpha:1.0]
#define DevicePinFunctionAnalogWriteDACColor   [UIColor colorWithRed:0.95 green:0.6 blue:0.06 alpha:1.0]


#define DevicePinFunctionAnalog(pin)       ((pin.selectedFunction == DevicePinFunctionAnalogRead) || (pin.selectedFunction == DevicePinFunctionAnalogWrite) || || (pin.selectedFunction == DevicePinFunctionAnalogWriteDAC)))
#define DevicePinFunctionDigital(pin)      ((pin.selectedFunction == DevicePinFunctionDigitalRead) || (pin.selectedFunction == DevicePinFunctionDigitalWrite))
#define DevicePinFunctionNothing(pin)      (pin.selectedFunction == DevicePinFunctionNone)

@interface DevicePin : NSObject

@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *logicalName;
@property (nonatomic, readonly) DevicePinSide side;
@property (nonatomic, readonly) NSUInteger row;
@property (nonatomic, readonly) DevicePinFunction availableFunctions;
@property (nonatomic, assign) DevicePinFunction selectedFunction;
@property (nonatomic, readonly) BOOL valueSet;
@property (nonatomic, readonly) NSUInteger value;

- (id)initWithLabel:(NSString *)label logicalName:(NSString *)name side:(DevicePinSide)side row:(NSUInteger)row availableFunctions:(DevicePinFunction)availableFunctions;

- (void)resetValue;
- (void)adjustValue:(NSUInteger)newValue;
- (UIColor *)selectedFunctionColor;

@end
