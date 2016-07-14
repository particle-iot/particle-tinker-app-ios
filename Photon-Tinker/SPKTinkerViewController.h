//
//  SPKTinkerViewController.h
//  Spark Photon Tinker for iOS
//
//  Copyright (c) 2015 Spark Devices. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinView.h"
#import "PinFunctionView.h"
#import "SparkDevice+pins.h"

@class DeviceListViewController;

/*
    This controller manages all aspects of Tinker including sub views via delegates. Any Tinker
    functionallity should following the same delegate pattern.
 */
@interface SPKTinkerViewController : UIViewController 

@property (nonatomic, strong) SparkDevice *device;

@end
