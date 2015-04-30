//
//  PinView.m
//  Photon-Tinker
//
//  Created by Ido on 4/29/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "PinView.h"

@interface PinView()
@property (nonatomic, strong) UIButton *innerPinButton;
@property (nonatomic, strong) UIButton *outerPinButton;
@property (nonatomic, strong) UILabel *label;
//@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic) BOOL longPressDetected;
@end

@implementation PinView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id)initWithPin:(SPKCorePin *)pin
{
    if (self = [super init])
    {
        self.longPressDetected = NO;
        
        _pin = pin;
        _active = NO;
        
        [self setFrame:CGRectMake(0,0,40,40)];
        
        self.innerPinButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.innerPinButton setFrame:CGRectMake(11, 8, 30, 30)];
        [self.innerPinButton setImage:[UIImage imageNamed:@"imgCircle"] forState:UIControlStateNormal];
        [self.innerPinButton setTitle:@"" forState:UIControlStateNormal];
        self.innerPinButton.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [self.innerPinButton addTarget:self action:@selector(pinTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.outerPinButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.outerPinButton setFrame:CGRectMake(7, 4, 38, 38)];
        [self.outerPinButton setImage:[UIImage imageNamed:@"imgCircleHollow"] forState:UIControlStateNormal];
        [self.outerPinButton setTitle:@"" forState:UIControlStateNormal];
        self.outerPinButton.tintColor = [UIColor blueColor];
        self.outerPinButton.userInteractionEnabled = NO;
        self.outerPinButton.hidden = YES;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 16)];
        self.label.center = self.innerPinButton.center;
        self.label.text = self.pin.label;
        if (self.pin.label.length <= 2)
            self.label.font = [UIFont fontWithName:@"Gotham-Medium" size:14.0];
        else
            self.label.font = [UIFont fontWithName:@"Gotham-Medium" size:11.0];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.outerPinButton];
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
        self.outerPinButton.tintColor = self.pin.selectedFunctionColor;
        self.outerPinButton.hidden = NO;
    }
    else
    {
        self.outerPinButton.hidden = YES;
    }
}

-(void)setActive:(BOOL)active
{
    _active = active;
    [self refresh];
}


@end
