//
//  SPKTinkerViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKTinkerViewController.h"
#import "Spark-SDK.h"
#import "DevicePin.h"
#import "SparkDevice+pins.h"
#import "PinView.h"
#import "TSMessage.h"
#import "PinValueView.h"
#import "Mixpanel.h"
#import "Particle-Swift.h"




@interface SPKTinkerViewController () <PinViewDelegate, PinFunctionViewDelegate, PinValueViewDelegate, SparkDeviceDelegate>

@property (nonatomic, strong) NSMutableDictionary *pinViews;
//@property (nonatomic, strong) NSMutableDictionary *pinValueViews;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinFunctionViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinFunctionViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinFunctionViewCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinFunctionViewCenterY;

@property (nonatomic, weak) IBOutlet PinFunctionView *pinFunctionView;

@property (nonatomic, weak) IBOutlet UIImageView *tinkerLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *deviceIDLabel;
@property (weak, nonatomic) IBOutlet UIView *chipView;
@property (strong, nonatomic) UIImageView *chipShadowImageView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UIView *deviceView;
@property (nonatomic, strong) PinView *pinViewShowingSlider;
@property (nonatomic) BOOL chipIsShowing;
@property (nonatomic) CGRect originalPinFunctionFrame;
@property (weak, nonatomic) IBOutlet UIImageView *deviceStateIndicatorImageView;
@property (weak, nonatomic) IBOutlet UIButton *inspectButton;

@end


@implementation SPKTinkerViewController

- (void)viewDidLoad
{
    self.chipIsShowing = NO;
    self.chipView.alpha = 0;
    self.pinViews = [NSMutableDictionary dictionaryWithCapacity:16];
//    self.pinValueViews = [NSMutableDictionary dictionaryWithCapacity:16];
    self.pinFunctionView.delegate = self;
    self.pinViewShowingSlider = nil;
    
    
    // background image
    /*
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgTrianglifyBackgroundBlue"]]; // make brown version?
    backgroundImage.frame = [UIScreen mainScreen].bounds;
    backgroundImage.contentMode = UIViewContentModeScaleToFill;
    backgroundImage.alpha = 0.75;
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    */
    
    self.deviceView.alpha = 1;
    
    
    // inititalize pins
    [self.device configurePins:self.device.type];
    
//    self.deviceIDLabel.text = [NSString stringWithFormat:@"ID: %@",[self.device.id uppercaseString]];
    
//    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFunctionView:)];
//    _tap.numberOfTapsRequired = 1;
//    _tap.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:_tap];
}

-(void)sparkDevice:(SparkDevice *)device didReceiveSystemEvent:(SparkDeviceSystemEvent)event
{
    [ParticleUtils animateOnlineIndicatorImageView:self.deviceStateIndicatorImageView online:self.device.connected flashing:self.device.isFlashing];

}


-(void)viewWillAppear:(BOOL)animated
{
    // fill in device name
    self.device.delegate = self;
    
    if ((self.device.name) && (![self.device.name isEqualToString:@""]))
    {
        self.deviceNameLabel.text = self.device.name;
    }
    else
    {
        self.deviceNameLabel.text = @"<no name>";
    }
    
    // animate the deviceStateIndicatorImageView
    [ParticleUtils animateOnlineIndicatorImageView:self.deviceStateIndicatorImageView online:self.device.connected flashing:self.device.isFlashing];
    
    [[Mixpanel sharedInstance] timeEvent:@"Tinker: Tinker screen activity"];
    if (self.chipView.alpha == 0)
        [ParticleSpinner show:self.view];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[Mixpanel sharedInstance] track:@"Tinker: Tinker screen activity"];
}



- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)viewDidLayoutSubviews
{
    // TODO: find a way to do it after layoutSubviews has been called for everything
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
    if (!self.chipIsShowing)
    {
        
        self.tinkerLogoImageView.hidden = NO;
        
        // add chip shadow
        _chipShadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgDeviceShadow"]];
        _chipShadowImageView.frame = self.chipView.bounds;
//        _chipShadowImageView.alpha = 0.85;
        _chipShadowImageView.image = [_chipShadowImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _chipShadowImageView.tintColor = [[UIColor alloc] initWithWhite:0.2 alpha:0.5];
        
        _chipShadowImageView.contentMode = UIViewContentModeScaleToFill;
        [self.chipView addSubview:_chipShadowImageView];
        [self.chipView sendSubviewToBack:_chipShadowImageView];
        
        
        //    CGFloat aspect = [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height; // calculate the screen aspect ratio
        //    CGFloat x_offset = (aspect - (9.0/16.0))*290.0; // this will result in 29 for 3:2 screens and 0 for 16:9 screens (push pins in for old screens) // TODO: calculate for 4:3 (ipads)
        CGFloat x_offset = 6;
        //    if (IS_IPHONE_4_OR_LESS) x_offset = 29;
        //    if (IS_IPHONE_6) x_offset = 8;
        
        //    x_offset = MIN(x_offset, 16); //?
        CGFloat chip_bottom_margin = self.chipView.frame.size.height/14;
        //    if ((IS_IPHONE_6) || (IS_IPHONE_6P))
        //        chip_bottom_margin *= 2;
        
        //    NSLog(@"aspect ratio: %f",aspect);
        
        for (DevicePin *pin in self.device.pins) {
            PinView *v = [[PinView alloc] initWithPin:pin];
            //CGFloat y_spacing = MAX(v.frame.size.height, ((self.chipShadowImageView.bounds.size.height-40) / (self.device.pins.count/2-1))); // assume even amount of pins per row
            CGFloat y_spacing = ((self.chipShadowImageView.frame.size.height-chip_bottom_margin) / (self.device.pins.count/2)); // assume even amount of pins per row
            y_spacing = MAX(y_spacing,v.frame.size.height);
            CGFloat y_offset = self.chipShadowImageView.frame.origin.y+8;//(chip_bottom_margin/3);
            
            //        y_offset = y_offset * (1.0+(((CGFloat)SCREEN_MAX_LENGTH-480.0)/512.0));
            
//            NSLog(@"y spacing %f / y_ofs %f",y_spacing, y_offset);
            
            [self.chipView insertSubview:v aboveSubview:self.chipShadowImageView];
            v.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSLayoutAttribute xPosAttribute = (pin.side == DevicePinSideLeft) ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing;
            CGFloat xConstant = (pin.side == DevicePinSideLeft) ? x_offset : -x_offset;
            
            [self.chipView addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                                      attribute:xPosAttribute
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.chipView
                                                                      attribute:xPosAttribute
                                                                     multiplier:1.0
                                                                       constant:xConstant]];
            
            [self.chipView addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.chipView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:pin.row*y_spacing + y_offset]];
            
            [v addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:v.bounds.size.width]]; //50
            
            [v addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:v.bounds.size.height]]; //50
            
            v.delegate = self;
            self.pinViews[pin.label] = v;
            
            // Pin Value View
            PinValueView *pvv = [[PinValueView alloc] initWithPin:pin];
            [self.chipView insertSubview:pvv aboveSubview:self.chipShadowImageView];
            pvv.translatesAutoresizingMaskIntoConstraints = NO;
            // stick view to right of the pin when positioned in left or exact opposite
            //        NSLayoutAttribute pvvXPosAttribute = (pin.side == DevicePinSideLeft) ? NSLayoutAttributeLeft : NSLayoutAttributeRight; // old
            NSLayoutAttribute pvvXPosAttribute = (pin.side == DevicePinSideLeft) ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing;
            
            //        NSLayoutAttribute inv_pvvXPosAttribute = (pin.side == DevicePinSideLeft) ? NSLayoutAttributeRight : NSLayoutAttributeLeft; // old
            NSLayoutAttribute inv_pvvXPosAttribute = (pin.side == DevicePinSideLeft) ? NSLayoutAttributeTrailing : NSLayoutAttributeLeading;
            
            CGFloat pvvXOffset = (pin.side == DevicePinSideLeft) ? 4 : -4; // distance between value and pin
            
            [self.chipView addConstraint:[NSLayoutConstraint constraintWithItem:pvv
                                                                      attribute:pvvXPosAttribute
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:v
                                                                      attribute:inv_pvvXPosAttribute
                                                                     multiplier:1.0
                                                                       constant:pvvXOffset]]; //pvvXOffset
            
            [self.chipView addConstraint:[NSLayoutConstraint constraintWithItem:pvv
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:v
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0
                                                                       constant:0]]; // Y offset of value-pin
            
            [pvv addConstraint:[NSLayoutConstraint constraintWithItem:pvv
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:pvv.bounds.size.width]];
            
            [pvv addConstraint:[NSLayoutConstraint constraintWithItem:pvv
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:pvv.bounds.size.height]];
            
            v.valueView = pvv;
            //        self.pinValueViews[pin.label] = pvv;
            
            
        }
        
        self.chipView.alpha = 0;
        [ParticleSpinner hide:self.view];
        [UIView animateWithDuration:0.4
                              delay:0
                            options: UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             self.chipView.alpha=1;
                             [self.chipView setNeedsLayout];
                         }
                         completion:^(BOOL finished){
                             [self showTutorial];
                             
                         }];
        self.chipIsShowing = YES;
    }
    self.originalPinFunctionFrame = self.pinFunctionView.frame;
    
}


-(void)showTutorial {
    
    if ([ParticleUtils shouldDisplayTutorialForViewController:self]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            if (self.navigationController.visibleViewController == self) {
                // viewController is visible
                
                // 3
                YCTutorialBox* tutorial = [[YCTutorialBox alloc] initWithHeadline:@"Device Inspector" withHelpText:@"Tap Inspect to dig deeper into your device and go to Device Inspector"];
                [tutorial showAndFocusView:self.inspectButton];
                
                // 2
                tutorial = [[YCTutorialBox alloc] initWithHeadline:@"Blink the onboard LED" withHelpText:@"Tap any pin to get started, select a pin function and tinker with the value. Hold a pin for 1 second to reset its function. Start with pin D7 - select 'digitalWrite' and tap the pin, see what happens."];
                [tutorial showAndFocusView:self.pinViews[@"D7"]];

                
                // 1
                tutorial = [[YCTutorialBox alloc] initWithHeadline:@"Welcome to Tinker!" withHelpText:@"Tinker is the fastest and easiest way to prototype and play with your Particle device. You can access the basic input/output functions of the device pins without writing a line of code. Pins can be configured to act as Input or Output, Digital or Analog."];
                [tutorial showAndFocusView:self.chipView];

                
                [ParticleUtils setTutorialWasDisplayedForViewController:self];
            }
            
        });
    }
}



- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Pin Function Delegate

- (void)pinFunctionSelected:(DevicePinFunction)function
{
    [self hideFunctionView:self];
    DevicePin *pin = self.pinFunctionView.pin;
    NSLog(@"function selection for pin %@ is %d",pin.logicalName, function);
    PinView *pinView = self.pinViews[pin.label];

    
    if (pin.selectedFunction != function)
    {
        [pinView.pin resetValue];
    }

    pinView.pin.selectedFunction = function;
    if (function == DevicePinFunctionNone)
    {
        pinView.active = NO;
    }
    else
    {
        pinView.active = YES;
        switch (function) {
            case DevicePinFunctionAnalogWriteDAC:
            case DevicePinFunctionAnalogWrite:
                self.pinViewShowingSlider = pinView;
                pinView.valueView.delegate = self;
                [pinView.valueView showSlider];
//                [self.chipView bringSubviewToFront:pinView.valueView]; // move to end of animation

                break;

            case DevicePinFunctionDigitalWrite:
                [pin adjustValue:0];
            case DevicePinFunctionDigitalRead:
            case DevicePinFunctionAnalogRead:
                [self pinCallHome:pinView];
                
            default:
                break;
        }
    }
//    [pinView refresh];
    
}

#pragma mark - Pin View Delegate

- (void)pinViewHeld:(PinView *)pinView
{
    NSLog(@"Pin %@ held",pinView.pin.label);
    if (pinView.valueView.sliderShowing)
        self.pinViewShowingSlider = nil;
    [pinView.valueView hideSlider];
    pinView.pin.selectedFunction = DevicePinFunctionNone;
    pinView.active = NO;
}


-(void)pinViewTapped:(PinView *)pinView
{
    // if a slider is showing remove it 
    if ((self.pinViewShowingSlider) && (self.pinViewShowingSlider != pinView))
    {
        [self.pinViewShowingSlider.valueView hideSlider];
        self.pinViewShowingSlider = nil;
    }

    // if function view is showing, remove it
    if (self.pinFunctionView.hidden == NO)
    {
        [self hideFunctionView:self];
        
        // and show a new one for the new pin (if it's not active yet)
        if ((self.pinFunctionView.pinView != pinView) && (!pinView.active)) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.30 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self showFunctionView:pinView];
            });
            
        }
    } // else if pin is not active then show function view
    else
    {
        if (!pinView.active) // pin is inactive - show pin function view
        {
            [self showFunctionView:pinView];
        }
        else // or else just tinker the pin as 
        {
            switch (pinView.pin.selectedFunction) {
                case DevicePinFunctionDigitalRead:
                case DevicePinFunctionAnalogRead:
                {
                    [self pinCallHome:pinView];
                    
                    break;
                }

                case DevicePinFunctionDigitalWrite:
                {
                    if (pinView.pin.value)
                        [pinView.pin adjustValue:0];
                    else
                        [pinView.pin adjustValue:1];
                    
                    [self pinCallHome:pinView];
                    
                    break;
                }

                case DevicePinFunctionAnalogWriteDAC:
                case DevicePinFunctionAnalogWrite:
                {
                    [pinView.valueView showSlider];
                    [self.chipView bringSubviewToFront:pinView.valueView];
                    self.pinViewShowingSlider = pinView;
                    pinView.valueView.delegate = self;
                    break;
                }

                default:
                {
                    break;
                }
            }
        }
    }
    

}

-(void)pinValueView:(PinValueView *)sender sliderMoved:(float)newValue touchUp:(BOOL)touchUp
{

    [sender.pin adjustValue:(NSUInteger)newValue];
    PinView *pv = self.pinViews[sender.pin.label];
    [pv refresh];
    if (touchUp)
    {
        [self pinCallHome:pv];
    }
    
}

#pragma mark - Private Methods



- (void)showFunctionView:(PinView *)pinView
{
    if (self.pinFunctionView.hidden) {
        self.pinFunctionView.pin = pinView.pin;
        self.pinFunctionView.pinView = pinView;
        
        self.pinFunctionView.hidden = NO;
        
        CGRect pinFrame = pinView.frame;
        pinFrame.size.height = 16;
        pinFrame.size.width = 16;
        [self.pinFunctionView setFrame:pinView.frame];
        [self.pinFunctionView setCenter:CGPointMake(pinView.center.x, pinView.center.y)];
        
        [self.chipView bringSubviewToFront:self.pinFunctionView];
        self.pinFunctionView.alpha = 0;

//        self.pinFunctionViewWidth.constant = 32;
//        self.pinFunctionViewHeight.constant = 32;
//        self.pinFunctionViewCenterX.constant = pinView.frame.origin.x;
//        self.pinFunctionViewCenterY.constant = pinView.frame.origin.y;

//        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.pinFunctionView setFrame:self.originalPinFunctionFrame];
//            self.pinFunctionViewWidth.constant = 204;
//            self.pinFunctionViewHeight.constant = 124;
//            self.pinFunctionViewCenterX.constant = 0;
//            self.pinFunctionViewCenterY.constant = 0;
//            
            self.pinFunctionView.alpha = 1;
            self.tinkerLogoImageView.alpha = 0;
            
            for (PinView *pv in self.pinViews.allValues) {
                if (pv != pinView) {
                    pv.alpha = 0.15;
                    pv.valueView.alpha = 0.15;
                }
            }
            
//            [self.view layoutIfNeeded];

            
        } completion:^(BOOL finished) {
            [self.chipView bringSubviewToFront:self.pinFunctionView];
        }];
        
        
    }
}

- (IBAction)pinFunctionCancelButtonTapped:(id)sender {
    [self hideFunctionView:self];
}

-(void)hideFunctionView:(id)sender
{
    PinView *pinView = self.pinFunctionView.pinView;
    CGRect pinViewFrame = pinView.frame;
    pinViewFrame.size.height = 16;
    pinViewFrame.size.width = 16;
    
    if (!self.pinFunctionView.hidden)
    {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.pinFunctionView.alpha = 0.2;
            self.tinkerLogoImageView.alpha = 1;
            for (PinView *pv in self.pinViews.allValues) {
                pv.alpha = 1;
                pv.valueView.alpha = 1;
            }
            [self.pinFunctionView setFrame:pinViewFrame];
            [self.pinFunctionView setCenter:CGPointMake(pinView.center.x, pinView.center.y)];

            
        } completion:^(BOOL finished) {
            self.pinFunctionView.hidden = YES;
            [self.chipView bringSubviewToFront:pinView.valueView]; // otherwise right side sliders do not respond to user touch
        }];
        
        
        
    
    }
}


- (void)pinCallHome:(PinView *)pinView
{
    [pinView beginUpdating];
    
    [self.device updatePin:pinView.pin.logicalName function:pinView.pin.selectedFunction value:pinView.pin.value success:^(NSUInteger result) {
        ///
        dispatch_async(dispatch_get_main_queue(), ^{
            [pinView endUpdating];

            self.tinkerLogoImageView.hidden = NO;
            if (pinView.pin.selectedFunction == DevicePinFunctionDigitalWrite || pinView.pin.selectedFunction == DevicePinFunctionAnalogWrite || pinView.pin.selectedFunction == DevicePinFunctionAnalogWriteDAC) {
                if (result == -1) {

                    [[Mixpanel sharedInstance] track:@"Tinker: error" properties:@{@"type":@"pin write"}];

                    [TSMessage showNotificationWithTitle:@"Device pin error" subtitle:@"There was a problem writing to this pin." type:TSMessageNotificationTypeError];
                    [pinView.pin resetValue];
                    pinView.active = NO;
                }
            }
            else
            {
                [pinView.pin adjustValue:result];
                [pinView refresh];
            }
            [pinView refresh];
        });
    } failure:^(NSString *errorMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [pinView endUpdating];
            
            NSString* errorStr = [NSString stringWithFormat:@"Error communicating with device - %@",errorMessage];
            [[Mixpanel sharedInstance] track:@"Tinker: error" properties:@{@"type":@"communicate with device"}];

            [TSMessage showNotificationWithTitle:@"Device error" subtitle:errorStr type:TSMessageNotificationTypeError];

            [pinView.pin resetValue];
            self.tinkerLogoImageView.hidden = NO;
            [pinView refresh];
        });
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"deviceInspector"])
    {
        DeviceInspectorViewController *divc = segue.destinationViewController;
        divc.device = self.device;
    }

    
}


-(void)resetAllPinFunctions
{
    for (PinView *pinView in self.pinViews.allValues)
    {
        pinView.pin.selectedFunction = DevicePinFunctionNone;
        [pinView.pin resetValue];
        pinView.active = NO;
        pinView.valueView.active = NO;
        
        [pinView refresh];
        [pinView.valueView refresh];
    }
    
}

@end
