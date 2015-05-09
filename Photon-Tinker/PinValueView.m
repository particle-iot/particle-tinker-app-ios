//
//  PinValueView.m
//  Particle
//
//  Created by Ido on 5/6/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "PinValueView.h"
#import "ASValueTrackingSlider.h"

@interface PinValueView()
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) ASValueTrackingSlider *slider;
@end

@implementation PinValueView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
        
        [self setFrame:CGRectMake(0,0,100,40)];
        
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
    if (!self.slider)
    {
        self.valueLabel.hidden = YES;
        self.hidden = NO;
        _slider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(0, 0, 99, 40)];
        [_slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderSetValue:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(sliderSetValue:) forControlEvents:UIControlEventTouchUpOutside];
        
        [_slider setBackgroundColor:[UIColor clearColor]];
        _slider.minimumValue = 0.0;
        _slider.maximumValue = PIN_ANALOGWRITE_MAX_VALUE;
        _slider.continuous = YES;
        _slider.value = self.pin.value;
        _slider.hidden = NO;
        
        _slider.popUpViewCornerRadius = 4.0;
        [_slider setMaxFractionDigitsDisplayed:0];
        _slider.popUpViewColor = self.pin.selectedFunctionColor;//[UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
        _slider.font = [UIFont fontWithName:@"Gotham-Medium" size:20];
        _slider.textColor = [UIColor whiteColor];//[UIColor colorWithHue:0.55 saturation:1.0 brightness:0.4 alpha:1];
        
        [self addSubview:_slider];
    }
    [self setNeedsDisplay];
}

-(void)hideSlider
{
    if (self.slider)
    {
        [self.slider removeFromSuperview];
        self.slider = nil;
    }
    self.valueLabel.hidden = NO;
    self.hidden = NO;
}

@end
