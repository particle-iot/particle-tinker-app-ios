//
//  igViewController.h
//  ScanBarCodes
//
//  Created by Torrey Betts on 10/10/13.
//  Copyright (c) 2013 Infragistics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScanBarcodeViewController;

@protocol ScanBarcodeViewControllerDelegate <NSObject>

-(void)didFinishScanningBarcodeWithResult:(ScanBarcodeViewController *)scanBarcodeViewController barcodeValue:(NSString *)barcodeValue;
-(void)didCancelScanningBarcode:(ScanBarcodeViewController *)scanBarcodeViewController;

@end

@interface ScanBarcodeViewController : UIViewController
@property (nonatomic, strong) id<ScanBarcodeViewControllerDelegate> delegate;
@end