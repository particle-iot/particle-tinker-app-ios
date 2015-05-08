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
        
        [self setFrame:CGRectMake(0,0,100,50)];
        
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
}

-(void)sliderAction:(id)sender
{
    ASValueTrackingSlider *slider = (ASValueTrackingSlider*)sender;
//    [self.pin adjustValue:slider.value];
    //-- Do further actions
    
    // delegate.sliderVlaueC4hanged...
}


-(void)showSlider
{

    self.valueLabel.hidden = YES;
    self.hidden = NO;
    _slider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [_slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [_slider setBackgroundColor:[UIColor clearColor]];
    _slider.minimumValue = 0.0;
    _slider.maximumValue = PIN_ANALOGWRITE_MAX_VALUE;
    _slider.continuous = NO;
    _slider.value = self.pin.value;
    _slider.hidden = NO;

    _slider.popUpViewCornerRadius = 4.0;
    [_slider setMaxFractionDigitsDisplayed:0];
    _slider.popUpViewColor = self.pin.selectedFunctionColor;//[UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
    _slider.font = [UIFont fontWithName:@"Gotham-Medium" size:20];
    _slider.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.4 alpha:1];
    
    [self addSubview:_slider];
    [self setNeedsDisplay];
}

@end
