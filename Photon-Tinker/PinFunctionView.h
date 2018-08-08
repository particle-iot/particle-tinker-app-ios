//
//  PinFunctionView.h
//  Particle IOS
//
//  Copyright (c) 2013 Particle Devices. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DevicePin.h"
#import "PinView.h"

@protocol PinFunctionViewDelegate <NSObject>

- (void)pinFunctionSelected:(DevicePinFunction)function;

@end

/*
    A view to select a pins function.
 */
@interface PinFunctionView : UIView

@property (weak) IBOutlet UILabel *pinLabel;
@property (weak) IBOutlet UIImageView *analogReadImageView;

@property (weak) IBOutlet UIButton *analogReadButton;
@property (weak) IBOutlet UIImageView *analogWriteImageView;
@property (weak) IBOutlet UIButton *analogWriteButton;
@property (weak) IBOutlet UIImageView *digitalReadImageView;

@property (weak) IBOutlet UIButton *digitalReadButton;
@property (weak) IBOutlet UIImageView *digitalWriteImageView;
@property (weak) IBOutlet UIButton *digitalWriteButton;

@property (nonatomic, strong) DevicePin *pin;
@property (nonatomic, strong) PinView *pinView;
@property (nonatomic, weak) id<PinFunctionViewDelegate> delegate;

- (IBAction)functionSelected:(id)sender;

@end
