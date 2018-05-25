//
//  PinFunctionView.m
//  Particle IOS
//
//  Copyright (c) 2013 Particle Devices. All rights reserved.
//

#import "PinFunctionView.h"

#define selectedColor       [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]
#define unselectedColor     [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]

@implementation PinFunctionView

- (void)setPin:(DevicePin *)pin
{
    _pin = pin;

    self.pinLabel.text = _pin.label;

    self.analogReadImageView.hidden = YES;
    self.analogReadButton.backgroundColor = unselectedColor;
    self.analogWriteImageView.hidden = YES;
    self.analogWriteButton.backgroundColor = unselectedColor;
    self.digitalReadImageView.hidden = NO;
    self.digitalReadButton.backgroundColor = unselectedColor;
    self.digitalWriteImageView.hidden = NO;
    self.digitalWriteButton.backgroundColor = unselectedColor;

    if (pin.availableFunctions & DevicePinFunctionAnalogRead)
    {
        self.analogReadButton.hidden = NO;
        self.analogReadImageView.hidden = NO;

    } else {
        self.analogReadButton.hidden = YES;
        self.analogReadImageView.hidden = YES;

    }

    if ((pin.availableFunctions & DevicePinFunctionAnalogWrite) || (pin.availableFunctions & DevicePinFunctionAnalogWriteDAC))
    {
        self.analogWriteButton.hidden = NO;
        self.analogWriteImageView.hidden = NO;
        if (pin.availableFunctions & DevicePinFunctionAnalogWriteDAC)
        {
            self.analogWriteImageView.image = [self.analogWriteImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.analogWriteImageView.tintColor = DevicePinFunctionAnalogWriteDACColor;
        }
        else
        {
            self.analogWriteImageView.image = [self.analogWriteImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }

    } else {
        self.analogWriteButton.hidden = YES;
        self.analogWriteImageView.hidden = YES;

    }

    switch (_pin.selectedFunction) {
        case DevicePinFunctionAnalogRead:
            self.analogReadButton.backgroundColor = selectedColor;
            self.analogReadImageView.hidden = NO;
            break;

        case DevicePinFunctionAnalogWriteDAC:
        case DevicePinFunctionAnalogWrite:
            self.analogWriteButton.backgroundColor = selectedColor;
            self.analogWriteImageView.hidden = NO;
            break;

        case DevicePinFunctionDigitalRead:
            self.digitalReadButton.backgroundColor = selectedColor;
            self.digitalReadImageView.hidden = NO;
            break;

        case DevicePinFunctionDigitalWrite:
            self.digitalWriteButton.backgroundColor = selectedColor;
            self.digitalWriteImageView.hidden = NO;
            break;

        default:
            break;
    }
    
    [self.pinLabel sizeToFit];

}

- (IBAction)functionSelected:(id)sender
{
    DevicePinFunction function = DevicePinFunctionNone;

    if (sender == self.analogReadButton) {
        function = DevicePinFunctionAnalogRead;
    } else if (sender == self.analogWriteButton)
    {
        if (self.pin.availableFunctions & DevicePinFunctionAnalogWriteDAC)
            function = DevicePinFunctionAnalogWriteDAC;
        else
            function = DevicePinFunctionAnalogWrite;

    } else if (sender == self.digitalReadButton) {
        function = DevicePinFunctionDigitalRead;
    } else if (sender == self.digitalWriteButton) {
         function = DevicePinFunctionDigitalWrite;
    }

    [self.delegate pinFunctionSelected:function];
}

@end
