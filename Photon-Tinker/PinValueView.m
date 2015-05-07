//
//  PinValueView.m
//  Particle
//
//  Created by Ido on 5/6/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "PinValueView.h"

@interface PinValueView()
@property (nonatomic, strong) UILabel *valueLabel;

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
        self.valueLabel.text = @"???";
        
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
            
        default:
            self.valueLabel.text = @"None";
            break;
    }
    self.valueLabel.hidden = self.pin.valueSet;


}

@end
