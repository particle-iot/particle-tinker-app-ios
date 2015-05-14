//
//  PinValueView.m
//  Particle
//
//  Created by Ido on 5/6/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "PinView.h"
#import "PinValueView.h"
#import "ASValueTrackingSlider.h"

@interface PinValueView()
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) ASValueTrackingSlider *slider;

@end

@implementation PinValueView


-(void)setActive:(BOOL)active
{
    self.hidden = !active;
    _active = active;
}

-(instancetype)initWithPin:(SPKCorePin *)pin
{
    if (self = [super init])
    {
        _pin = pin;
        _active = YES;//NO;
        self.hidden = NO;//YES;
        
        CGFloat width=140, height=44; // unknown "
        
        if (IS_IPHONE_4_OR_LESS) // 3.5"
        {
            height = 38;
        }
        else if (IS_IPHONE_5) // 4"
        {
            width = 140;
        }
        else if (IS_IPHONE_6) // 4.7"
        {
            width = 180;
        }
        else if (IS_IPHONE_6P) // 5.5"
        {
            width = 210;
        }
        
        [self setFrame:CGRectMake(0,0,width,height)];
        
        self.valueLabel = [[UILabel alloc] initWithFrame:self.frame];

        if (pin.side == SPKCorePinSideLeft)
        {
            self.valueLabel.textAlignment = NSTextAlignmentLeft;
        }
        else
        {
            self.valueLabel.textAlignment = NSTextAlignmentRight;
        }

        self.valueLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:15.0];
        self.valueLabel.textColor = [UIColor whiteColor];
        self.valueLabel.text = @"";
        self.valueLabel.hidden = YES;
        
        [self addSubview:self.valueLabel];
        
        
        
        
    }
    
    return self;
}


-(void)refresh
{
    switch (self.pin.selectedFunction) {
        case SPKCorePinFunctionDigitalRead:
        case SPKCorePinFunctionDigitalWrite:
            self.valueLabel.text = self.pin.value ? @"HIGH" : @"LOW";
            break;
            
        case SPKCorePinFunctionAnalogRead:
        case SPKCorePinFunctionAnalogWrite:
            self.valueLabel.text = [NSString stringWithFormat:@"%ld",self.pin.value];
            break;
            
        default:
            self.valueLabel.text = @"";
            break;
    }
    self.valueLabel.hidden = !self.pin.valueSet;
    if (self.slider)
        self.valueLabel.hidden = YES;
}

-(void)sliderMoved:(id)sender
{
    NSLog(@"sliderMoved");
    ASValueTrackingSlider *slider = (ASValueTrackingSlider*)sender;
    if (self.delegate)
    {
        [self.delegate pinValueView:self sliderMoved:slider.value touchUp:NO];
    }
}

-(void)sliderSetValue:(id)sender
{
    NSLog(@"sliderSetValue");

    ASValueTrackingSlider *slider = (ASValueTrackingSlider*)sender;
    if (self.delegate)
    {
        [self.delegate pinValueView:self sliderMoved:slider.value touchUp:YES];
    }
    
}


-(void)showSlider
{
    self.sliderShowing = YES;
    if (!self.slider)
    {
        self.valueLabel.hidden = YES;
        self.hidden = NO;
        _slider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        _slider.bounds = CGRectMake(4, 4, PinValueViewWidth-4, PinValueViewHeight-4);
        [_slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderSetValue:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(sliderSetValue:) forControlEvents:UIControlEventTouchUpOutside];
        
        [_slider setBackgroundColor:[UIColor clearColor]];
        _slider.minimumValue = 0.0;
        _slider.maximumValue = PIN_ANALOGWRITE_MAX_VALUE;
        _slider.continuous = YES;
        _slider.value = self.pin.value;
        _slider.hidden = NO;
        _slider.userInteractionEnabled = YES;
        
        _slider.popUpViewCornerRadius = 3.0;
        [_slider setMaxFractionDigitsDisplayed:0];
        _slider.popUpViewColor = self.pin.selectedFunctionColor;//[UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
        _slider.font = [UIFont fontWithName:@"Gotham-Medium" size:20];
        _slider.textColor = [UIColor darkGrayColor];//[UIColor colorWithHue:0.55 saturation:1.0 brightness:0.4 alpha:1];
        
//        [self addSubview:_slider];
        [self insertSubview:_slider aboveSubview:self.valueLabel];
    }
    
    //debug:
    NSLog(@"valueView.frame: %@",NSStringFromCGRect(self.frame));
    NSLog(@"valueView.bounds: %@",NSStringFromCGRect(self.bounds));

    NSLog(@"slider.frame: %@",NSStringFromCGRect(_slider.frame));
    NSLog(@"slider.bounds: %@",NSStringFromCGRect(_slider.bounds));

    
    [self setNeedsDisplay];
}

-(void)hideSlider
{
    self.sliderShowing = NO;
    if (self.slider)
    {
        [self.slider removeFromSuperview];
        self.slider = nil;
    }
    self.valueLabel.hidden = NO;
    self.hidden = NO;
}

@end
