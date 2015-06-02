//
//  SPKTinkerViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKTinkerViewController.h"
#import "Spark-SDK.h"
#import "SPKCorePin.h"
#import "SparkDevice+pins.h"
#import "PinView.h"
#import "TSMessage.h"
#import "PinValueView.h"
#import "Particle-Swift.h" // thats for SettingsTableViewControllerDelegate which is in Swift file

#define SEEN_FIRST_TIME_VIEW_USERDEFAULTS_KEY   @"seenFirstTimeView"

@interface SPKTinkerViewController () <UITextFieldDelegate, PinViewDelegate, SPKPinFunctionDelegate, PinValueViewDelegate, SettingsTableViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *pinViews;
//@property (nonatomic, strong) NSMutableDictionary *pinValueViews;

@property (nonatomic, weak) IBOutlet SPKPinFunctionView *pinFunctionView;
@property (nonatomic, weak) IBOutlet UIView *firstTimeView;
@property (nonatomic, weak) IBOutlet UIImageView *tinkerLogoImageView;
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *deviceIDLabel;
@property (weak, nonatomic) IBOutlet UIView *chipView;
@property (strong, nonatomic) UIImageView *chipShadowImageView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UIView *deviceView;
@property (nonatomic) BOOL editingDeviceName;
@property (weak, nonatomic) IBOutlet UIButton *editDeviceNameButton;
@property (nonatomic, strong) PinView *pinViewShowingSlider;
@property (nonatomic) BOOL chipIsShowing;
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
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgTrianglifyBackgroundBlue"]]; // make brown version?
    backgroundImage.frame = [UIScreen mainScreen].bounds;
    backgroundImage.contentMode = UIViewContentModeScaleToFill;
    backgroundImage.alpha = 0.75;
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    self.deviceView.alpha = 0.2;
    self.firstTimeView.hidden = NO;
    
    // first time view
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDefaults = [defaults objectForKey:[SparkCloud sharedInstance].loggedInUsername];
    if (userDefaults)
    {
        if ([userDefaults[SEEN_FIRST_TIME_VIEW_USERDEFAULTS_KEY] isEqualToNumber:@1])
        {
            [self dismissFirstTime];
        }
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFirstTime)];
    [self.firstTimeView addGestureRecognizer:tap];

    // fill in device name
    if ((self.device.name) && (![self.device.name isEqualToString:@""]))
    {
        self.deviceNameLabel.text = self.device.name;
    }
    else
    {
        self.deviceNameLabel.text = @"<no name>";
    }

    // inititalize pins
    [self.device configurePins:self.device.type];
    
//    self.deviceIDLabel.text = [NSString stringWithFormat:@"ID: %@",[self.device.id uppercaseString]];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFunctionView:)];
    _tap.numberOfTapsRequired = 1;
    _tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:_tap];

    
    
}


- (IBAction)editDeviceNameButtonTapped:(id)sender
{
    if (!self.editingDeviceName)
    {
        self.deviceNameLabel.hidden = YES;
        self.deviceNameTextField.hidden = NO;
        self.editDeviceNameButton.hidden = YES;
        self.deviceNameTextField.text = self.deviceNameLabel.text;
        self.deviceNameTextField.delegate = self;
        self.editingDeviceName = YES;
        [self.deviceNameTextField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if (textField==self.deviceNameTextField)
    {
        [self.deviceNameTextField resignFirstResponder];
        self.editingDeviceName = NO;
        self.device.name = self.deviceNameTextField.text; // TODO: verify correctness
        self.editDeviceNameButton.hidden = NO;
        self.deviceNameLabel.text = self.deviceNameTextField.text;
        self.deviceNameLabel.hidden = NO;
        self.deviceNameTextField.hidden = YES;

    }
    return YES;
}


- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)helpButtonTapped:(id)sender {
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
        _chipShadowImageView.alpha = 0.85;
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
        
        for (SPKCorePin *pin in self.device.pins) {
            PinView *v = [[PinView alloc] initWithPin:pin];
            //CGFloat y_spacing = MAX(v.frame.size.height, ((self.chipShadowImageView.bounds.size.height-40) / (self.device.pins.count/2-1))); // assume even amount of pins per row
            CGFloat y_spacing = ((self.chipShadowImageView.frame.size.height-chip_bottom_margin) / (self.device.pins.count/2)); // assume even amount of pins per row
            y_spacing = MAX(y_spacing,v.frame.size.height);
            CGFloat y_offset = self.chipShadowImageView.frame.origin.y+8;//(chip_bottom_margin/3);
            
            //        y_offset = y_offset * (1.0+(((CGFloat)SCREEN_MAX_LENGTH-480.0)/512.0));
            
            NSLog(@"y spacing %f / y_ofs %f",y_spacing, y_offset);
            
            [self.chipView insertSubview:v aboveSubview:self.chipShadowImageView];
            v.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSLayoutAttribute xPosAttribute = (pin.side == SPKCorePinSideLeft) ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing;
            CGFloat xConstant = (pin.side == SPKCorePinSideLeft) ? x_offset : -x_offset;
            
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
            //        NSLayoutAttribute pvvXPosAttribute = (pin.side == SPKCorePinSideLeft) ? NSLayoutAttributeLeft : NSLayoutAttributeRight; // old
            NSLayoutAttribute pvvXPosAttribute = (pin.side == SPKCorePinSideLeft) ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing;
            
            //        NSLayoutAttribute inv_pvvXPosAttribute = (pin.side == SPKCorePinSideLeft) ? NSLayoutAttributeRight : NSLayoutAttributeLeft; // old
            NSLayoutAttribute inv_pvvXPosAttribute = (pin.side == SPKCorePinSideLeft) ? NSLayoutAttributeTrailing : NSLayoutAttributeLeading;
            
            CGFloat pvvXOffset = (pin.side == SPKCorePinSideLeft) ? 4 : -4; // distance between value and pin
            
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
        [UIView animateWithDuration:0.4
                              delay:0
                            options: UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             self.chipView.alpha=1;
                             [self.chipView setNeedsLayout];
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];
        self.chipIsShowing = YES;
    }
    
}




- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Pin Function Delegate

- (void)pinFunctionSelected:(SPKCorePinFunction)function
{
    SPKCorePin *pin = self.pinFunctionView.pin;
    PinView *pinView = self.pinViews[pin.label];

    if (pin.selectedFunction != function)
    {
        [pinView.pin resetValue];
    }

    pinView.pin.selectedFunction = function;
    if (function == SPKCorePinFunctionNone)
    {
        pinView.active = NO;
    }
    else
    {
        pinView.active = YES;
        switch (function) {
            case SPKCorePinFunctionAnalogWrite:
                self.pinViewShowingSlider = pinView;
                pinView.valueView.delegate = self;
                [pinView.valueView showSlider];
                [self.chipView bringSubviewToFront:pinView.valueView];

                break;

            case SPKCorePinFunctionDigitalWrite:
                [pin adjustValue:0];
            case SPKCorePinFunctionDigitalRead:
            case SPKCorePinFunctionAnalogRead:
                [self pinCallHome:pinView];
                
            default:
                break;
        }
    }
//    [pinView refresh];
}

#pragma mark - Core Pin View Delegate

- (void)pinViewHeld:(PinView *)pinView
{
    NSLog(@"Pin %@ held",pinView.pin.label);
    if (pinView.valueView.sliderShowing)
        self.pinViewShowingSlider = nil;
    [pinView.valueView hideSlider];
    pinView.pin.selectedFunction = SPKCorePinFunctionNone;
    pinView.active = NO;
}


-(void)pinViewTapped:(PinView *)pinView
{
    NSLog(@"Pin %@ tapped",pinView.pin.label);
    // if a slider is showing remove it 
    if ((self.pinViewShowingSlider) && (self.pinViewShowingSlider != pinView))
    {
        [self.pinViewShowingSlider.valueView hideSlider];
        self.pinViewShowingSlider = nil;
    }

    
    // if function view is showing, remove it
    if (!self.pinFunctionView.hidden)
    {
        self.pinFunctionView.hidden = YES;
        for (SPKCorePinView *pv in self.pinViews.allValues)
        {
            pv.alpha = 1.0;
        }
        self.tinkerLogoImageView.hidden = NO;
//        self.deviceNameLabel.hidden = NO;
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
                case SPKCorePinFunctionDigitalRead:
                case SPKCorePinFunctionAnalogRead:
                {
                    [self pinCallHome:pinView];
                    
                    break;
                }

                case SPKCorePinFunctionDigitalWrite:
                {
                    if (pinView.pin.value)
                        [pinView.pin adjustValue:0];
                    else
                        [pinView.pin adjustValue:1];
                    
                    [self pinCallHome:pinView];
                    
                    break;
                }


                case SPKCorePinFunctionAnalogWrite:
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
    NSLog(@"sliderMoved delegate");
    [sender.pin adjustValue:newValue];
    PinView *pv = self.pinViews[sender.pin.label];
    [pv refresh];
    if (touchUp)
    {
        [self pinCallHome:pv];
    }
    
}

#pragma mark - Private Methods

- (void)dismissFirstTime
{
    self.deviceView.alpha = 1;
    self.firstTimeView.hidden = YES;
    // first time view
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDefaults = @{SEEN_FIRST_TIME_VIEW_USERDEFAULTS_KEY : @1};
    [defaults setObject:userDefaults forKey:[SparkCloud sharedInstance].loggedInUsername];
}

- (void)showFunctionView:(PinView *)pinView
{
    if (self.pinFunctionView.hidden) {
        self.tinkerLogoImageView.hidden = YES;
        self.pinFunctionView.pin = pinView.pin;
        self.pinFunctionView.hidden = NO;
        for (PinView *pv in self.pinViews.allValues) {
            if (pv != pinView) {
                pv.alpha = 0.15;
                pv.valueView.alpha = 0.15;
            }
        }
        [self.view bringSubviewToFront:self.pinFunctionView];
    }
}


-(void)hideFunctionView:(id)sender
{
    if (!self.pinFunctionView.hidden)
    {
        self.tinkerLogoImageView.hidden = NO;
        self.pinFunctionView.hidden = YES;
        for (PinView *pv in self.pinViews.allValues) {
            pv.alpha = 1;
            pv.valueView.alpha = 1;
        }
    
    }
}


- (void)pinCallHome:(PinView *)pinView
{
    pinView.userInteractionEnabled = NO;
    pinView.alpha = 0.35;
    
    [self.device updatePin:pinView.pin.logicalName function:pinView.pin.selectedFunction value:pinView.pin.value success:^(NSUInteger result) {
        ///
        dispatch_async(dispatch_get_main_queue(), ^{
            pinView.alpha = 1;
            pinView.userInteractionEnabled = YES;

            self.tinkerLogoImageView.hidden = NO;
            if (pinView.pin.selectedFunction == SPKCorePinFunctionDigitalWrite || pinView.pin.selectedFunction == SPKCorePinFunctionAnalogWrite) {
                if (result == -1) {

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
            pinView.alpha = 1;
            pinView.userInteractionEnabled = YES;
            
            NSString* errorStr = [NSString stringWithFormat:@"Error communicating with device - %@",errorMessage];
            [TSMessage showNotificationWithTitle:@"Device error" subtitle:errorStr type:TSMessageNotificationTypeError];

            [pinView.pin resetValue];
            self.tinkerLogoImageView.hidden = NO;
            [pinView refresh];
        });
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ([segue.identifier isEqualToString:@"settings"])
    {
        UINavigationController *navController = [segue destinationViewController];
        SettingsTableViewController *stvc = navController.viewControllers[0];
        stvc.device = self.device;
        stvc.delegate = self;
    }
}


-(void)resetAllPinFunctions
{
    for (PinView *pinView in self.pinViews.allValues)
    {
        pinView.pin.selectedFunction = SPKCorePinFunctionNone;
        [pinView.pin resetValue];
        pinView.active = NO;
        pinView.valueView.active = NO;
        
        [pinView refresh];
        [pinView.valueView refresh];
    }
    
}

@end
