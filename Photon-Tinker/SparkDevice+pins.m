//
//  SPKCore.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SparkDevice+pins.h"
#import "SPKCorePin.h"
#import <objc/runtime.h>

static const char * const CORE_NAMES[] = { "aardvark", "bacon", "badger", "banjo", "bobcat", "boomer", "captain", "chicken", "cowboy", "cracker", "cranky", "crazy", "dentist", "doctor", "dozen", "easter", "ferret", "gerbil", "hacker", "hamster", "hindu", "hobo", "hoosier", "hunter", "jester", "jetpack", "kitty", "laser", "lawyer", "mighty", "monkey", "morphing", "mutant", "narwhal", "ninja", "normal", "penguin", "pirate", "pizza", "plumber", "power", "puppy", "ranger", "raptor", "robot", "scraper", "scrapple", "station", "tasty", "trochee", "turkey", "turtle", "vampire", "wombat", "zombie" };

static NSUInteger CORE_NAMES_COUNT = 55;

#define ALL_FUNCTIONS (SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite|SPKCorePinFunctionAnalogRead|SPKCorePinFunctionAnalogWrite)


@implementation SparkDevice(pins)


- (void)resetPins
{
    for (SPKCorePin *pin in self.pins) {
        pin.selectedFunction = SPKCorePinFunctionNone;
        [pin resetValue];
    }
}

#pragma mark - Private Methods

@dynamic pins;

- (void)setPins:(NSArray *)pins
{
    objc_setAssociatedObject(self, @selector(pins), pins, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)pins
{
    return objc_getAssociatedObject(self, @selector(pins));
}


- (void)configurePins
{
    SPKCorePin *a0 = [[SPKCorePin alloc] initWithLabel:@"A0" side:SPKCorePinSideLeft row:7 availableFunctions:ALL_FUNCTIONS];
    SPKCorePin *a1 = [[SPKCorePin alloc] initWithLabel:@"A1" side:SPKCorePinSideLeft row:6 availableFunctions:ALL_FUNCTIONS];
    SPKCorePin *a2 = [[SPKCorePin alloc] initWithLabel:@"A2" side:SPKCorePinSideLeft row:5 availableFunctions:ALL_FUNCTIONS];
    SPKCorePin *a3 = [[SPKCorePin alloc] initWithLabel:@"A3" side:SPKCorePinSideLeft row:4 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite|SPKCorePinFunctionAnalogRead];
    SPKCorePin *a4 = [[SPKCorePin alloc] initWithLabel:@"A4" side:SPKCorePinSideLeft row:3 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite|SPKCorePinFunctionAnalogRead];
    SPKCorePin *a5 = [[SPKCorePin alloc] initWithLabel:@"A5" side:SPKCorePinSideLeft row:2 availableFunctions:ALL_FUNCTIONS];
    SPKCorePin *a6 = [[SPKCorePin alloc] initWithLabel:@"A6" side:SPKCorePinSideLeft row:1 availableFunctions:ALL_FUNCTIONS];
    SPKCorePin *a7 = [[SPKCorePin alloc] initWithLabel:@"A7" side:SPKCorePinSideLeft row:0 availableFunctions:ALL_FUNCTIONS];

    SPKCorePin *d0 = [[SPKCorePin alloc] initWithLabel:@"D0" side:SPKCorePinSideRight row:7 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite|SPKCorePinFunctionAnalogWrite];
    SPKCorePin *d1 = [[SPKCorePin alloc] initWithLabel:@"D1" side:SPKCorePinSideRight row:6 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite|SPKCorePinFunctionAnalogWrite];
    SPKCorePin *d2 = [[SPKCorePin alloc] initWithLabel:@"D2" side:SPKCorePinSideRight row:5 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite];
    SPKCorePin *d3 = [[SPKCorePin alloc] initWithLabel:@"D3" side:SPKCorePinSideRight row:4 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite];
    SPKCorePin *d4 = [[SPKCorePin alloc] initWithLabel:@"D4" side:SPKCorePinSideRight row:3 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite];
    SPKCorePin *d5 = [[SPKCorePin alloc] initWithLabel:@"D5" side:SPKCorePinSideRight row:2 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite];
    SPKCorePin *d6 = [[SPKCorePin alloc] initWithLabel:@"D6" side:SPKCorePinSideRight row:1 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite];
    SPKCorePin *d7 = [[SPKCorePin alloc] initWithLabel:@"D7" side:SPKCorePinSideRight row:0 availableFunctions:SPKCorePinFunctionDigitalRead|SPKCorePinFunctionDigitalWrite];

    self.pins = @[a0, a1, a2, a3, a4, a5, a6, a7, d0, d1, d2, d3, d4, d5, d6, d7];
}

- (NSString *)generateName
{
    NSUInteger a = arc4random() % CORE_NAMES_COUNT;
    NSUInteger b = arc4random() % CORE_NAMES_COUNT;
    const char *first = CORE_NAMES[a];
    const char *last = CORE_NAMES[b];

    return [NSString stringWithFormat:@"%s_%s", first, last];
}

@end
