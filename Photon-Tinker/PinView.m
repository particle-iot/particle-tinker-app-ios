//
//  PinView.m
//  Photon-Tinker
//
//  Created by Ido on 4/29/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "PinView.h"
#import "PinValueView.h"
#import "SSPieProgressView.h"

@interface PinView()
@property (nonatomic, strong) UIButton *innerPinButton;
@property (nonatomic, strong) UIButton *outerPinButton;
@property (nonatomic, strong) UILabel *label;
//@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic) BOOL longPressDetected;
@property (nonatomic, strong) SSPieProgressView *outerPieValueView;
@property (nonatomic, strong) SSPieProgressView *outerPieFrameView;

@end

@implementation PinView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id)initWithPin:(DevicePin *)pin
{
    if (self = [super init])
    {
        self.longPressDetected = NO;
        
        _pin = pin;
        _active = NO;
        
        
        CGFloat pinSizingOffset = 6; // TODO: calculate from screensize
        if (IS_IPHONE_4_OR_LESS)
            pinSizingOffset = 0;
        
        [self setFrame:CGRectMake(0,0,38+pinSizingOffset,38+pinSizingOffset)];
        
        self.innerPinButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.innerPinButton setFrame:CGRectMake(4, 4, 30+pinSizingOffset, 30+pinSizingOffset)];
        [self.innerPinButton setImage:[UIImage imageNamed:@"imgCircle"] forState:UIControlStateNormal];
        [self.innerPinButton setTitle:@"" forState:UIControlStateNormal];
//        self.innerPinButton.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.innerPinButton.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.25 alpha:1];

        [self.innerPinButton addTarget:self action:@selector(pinTapped:) forControlEvents:UIControlEventTouchUpInside];

//        self.outerPinButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [self.outerPinButton setFrame:CGRectMake(7, 4, 38, 38)];
//        [self.outerPinButton setImage:[UIImage imageNamed:@"imgCircleHollow"] forState:UIControlStateNormal];
//        [self.outerPinButton setTitle:@"" forState:UIControlStateNormal];
//        self.outerPinButton.tintColor = [UIColor blueColor];
//        self.outerPinButton.userInteractionEnabled = NO;
//        self.outerPinButton.hidden = YES;
        
        self.outerPieValueView = [[SSPieProgressView alloc] initWithFrame:CGRectMake(0, 0, 38+pinSizingOffset, 38+pinSizingOffset)];
        self.outerPieValueView.backgroundColor = [UIColor clearColor];
        self.outerPieValueView.pieBackgroundColor = [UIColor clearColor];
        self.outerPieValueView.progress = 1;
        self.outerPieValueView.pieBorderWidth = 0;
        self.outerPieFrameView.pieFillColor = [UIColor whiteColor]; // will change
        self.outerPieValueView.hidden = YES;

        // just a thin line around the circle to reflect selected function even when analog values = 0 (so pin will look active)
        self.outerPieFrameView = [[SSPieProgressView alloc] initWithFrame:CGRectMake(0, 0, 38+pinSizingOffset, 38+pinSizingOffset)];
        self.outerPieFrameView.backgroundColor = [UIColor clearColor];
        self.outerPieFrameView.pieBackgroundColor = [UIColor clearColor];
        self.outerPieFrameView.progress = 1;
        if ((IS_IPHONE_4_OR_LESS) || (IS_IPHONE_5)) // 3.5" / 4"
            self.outerPieFrameView.pieBorderWidth = 1.0f;
        else // >= 4.7"
            self.outerPieFrameView.pieBorderWidth = 1.5f;
        self.outerPieFrameView.pieBorderColor = [UIColor whiteColor]; // will change
        self.outerPieFrameView.pieFillColor = [UIColor clearColor];
        self.outerPieFrameView.hidden = YES;

        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 30+pinSizingOffset, 30+pinSizingOffset)];
        self.label.center = self.innerPinButton.center;
        self.label.text = self.pin.label;
        if (self.pin.label.length <= 2)
            self.label.font = [UIFont fontWithName:@"Gotham-Medium" size:14.0+(pinSizingOffset/3)];
        else
            self.label.font = [UIFont fontWithName:@"Gotham-Medium" size:10.5+(pinSizingOffset/3)];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        
//        [self addSubview:self.outerPinButton];
        [self addSubview:self.outerPieFrameView];
        [self addSubview:self.outerPieValueView];
        [self addSubview:self.innerPinButton];
        [self addSubview:self.label];
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        _longPressGestureRecognizer.minimumPressDuration = 1.0;
        _longPressGestureRecognizer.cancelsTouchesInView = NO;
        [self.innerPinButton addGestureRecognizer:_longPressGestureRecognizer];

    }
    
    return self;
}

-(void)longPress:(id)sender
{
    if (!self.longPressDetected) // wait for touchup to reset long press state
    {
        self.longPressDetected = YES;
        [self.delegate pinViewHeld:self];
    }
}

-(void)pinTapped:(PinView *)sender
{
    if (!self.longPressDetected) // prevent from long press being reported as tap+long press
        [self.delegate pinViewTapped:self];
    else
        self.longPressDetected = NO;
}


-(void)refresh
{
    if (self.active)
    {
        self.outerPieValueView.hidden = NO;
        self.outerPieFrameView.hidden = NO;
        
        self.outerPieValueView.pieFillColor = self.pin.selectedFunctionColor;
        self.outerPieFrameView.pieBorderColor = self.pin.selectedFunctionColor;

        // LOW color button+label
        self.innerPinButton.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.25 alpha:1];
        self.label.textColor = [UIColor whiteColor];

        switch (self.pin.selectedFunction) {
            case DevicePinFunctionAnalogRead:
                self.outerPieValueView.progress = self.pin.value/PIN_ANALOGREAD_MAX_VALUE;
                break;
                
            case DevicePinFunctionAnalogWrite:
                self.outerPieValueView.progress = self.pin.value/PIN_ANALOGWRITE_MAX_VALUE;
                break;

            case DevicePinFunctionAnalogWriteDAC:
                self.outerPieValueView.progress = self.pin.value/PIN_ANALOGWRITE_DAC_MAX_VALUE;
                break;
                
            case DevicePinFunctionDigitalRead:
            case DevicePinFunctionDigitalWrite:
                self.outerPieValueView.progress = 1.0f;

                if (self.pin.value)
                {
                    // HIGH color button+label
                    self.innerPinButton.tintColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.85 alpha:1];
                    self.label.textColor = [UIColor blackColor];
                }
                
            default: //digital or none
                break;
        }
        
        [self.valueView refresh];
    }
    else
    {
//        self.outerPinButton.hidden = YES;
        self.outerPieValueView.hidden = YES;
        self.outerPieFrameView.hidden = YES;
        
    }
}

-(void)setActive:(BOOL)active
{
    _active = active;
    self.valueView.active = active;
    [self refresh];
}


//-(void)setAlpha:(CGFloat)alpha
//{
//    // propagate alpha changes to value view too
//    super.alpha = alpha;
//    self.valueView.alpha = alpha;
//}

-(void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.valueView.userInteractionEnabled = userInteractionEnabled;
}

@end
