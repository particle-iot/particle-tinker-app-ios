//
//  igViewController.m
//  ScanBarCodes
//
//  Created by Torrey Betts on 10/10/13.
//  Copyright (c) 2013 Infragistics. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ScanBarcodeViewController.h"

@interface ScanBarcodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;

    UIView *_highlightView;
    UILabel *_label;
    UIImageView *_overlayImageView;
    UIButton *_overlayButton;
    UIButton *_cancelButton;
    UIView *_circleView;
}
@end

@implementation ScanBarcodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _highlightView = [[UIView alloc] init];
    //_highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];

    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    //_label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"Point at SIM ICCID barcode";
    [self.view addSubview:_label];

    _overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic"]];
    [_overlayImageView setFrame:CGRectMake(30, 150, self.view.bounds.size.width-60, self.view.bounds.size.height-300)];
    _overlayImageView.image = [_overlayImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_overlayImageView setTintColor:[UIColor whiteColor]];
    [self.view addSubview:_overlayImageView];
    
    _overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_overlayButton setImage:[UIImage imageNamed:@"flashlight"] forState:UIControlStateNormal];
    [_overlayButton setFrame:CGRectMake(30, 30, 48, 48)];
    [_overlayButton setTintColor:[UIColor whiteColor]];
    [_overlayButton addTarget:self action:@selector(toggleTorchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_overlayButton];

    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton setFrame:CGRectMake(self.view.bounds.size.width-60, self.view.bounds.size.height-44, 60, 48)];
    [_cancelButton addTarget:self action:@selector(cancelScan:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];

    
    _circleView = [[UIView alloc] initWithFrame:CGRectMake(22, 24, 64, 64)];
    _circleView.alpha = 0.5;
    _circleView.layer.cornerRadius = 32;
    _circleView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_circleView];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOn];  // use AVCaptureTorchModeOff to turn off
        [_device unlockForConfiguration];
    }
    NSError *error = nil;

    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }

    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];

    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];

    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];

    [_session startRunning];

    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
    [self.view bringSubviewToFront:_circleView];
    [self.view bringSubviewToFront:_overlayButton];
    [self.view bringSubviewToFront:_overlayImageView];
    [self.view bringSubviewToFront:_cancelButton];

    
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    if (@available(iOS 11.0, *)) {
        UIEdgeInsets insets = self.view.safeAreaInsets;


        _label.frame = CGRectMake(0, self.view.bounds.size.height - 40 - insets.bottom, self.view.bounds.size.width, 40);
        _cancelButton.frame = CGRectMake(self.view.bounds.size.width-60, self.view.bounds.size.height - 44 - insets.bottom, 60, 48);

        _overlayButton.frame = CGRectMake(30, 30 + insets.top, 48, 48);
        _circleView.frame = CGRectMake(22, 24 + insets.top, 64, 64);

        _overlayImageView.frame = CGRectMake(30, 150 + insets.top, self.view.bounds.size.width-60, self.view.bounds.size.height - 300 - insets.top - insets.bottom);
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)toggleTorchButton:(id)sender
{
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (_device.torchMode == AVCaptureTorchModeOff)
            [_device setTorchMode:AVCaptureTorchModeOn];
        else
            [_device setTorchMode:AVCaptureTorchModeOff];
        [_device unlockForConfiguration];
    }

}




-(void)cancelScan:(id)sender
{
    [self.delegate didCancelScanningBarcode:self];
}


- (IBAction)test:(id)sender {
    [_session stopRunning];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.55 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate didFinishScanningBarcodeWithResult:self barcodeValue:@"1234567890123456789012"];
    });

}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
//    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
//            AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
//            AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];

    NSArray *barCodeTypes = @[AVMetadataObjectTypeCode128Code]; //ido

    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }

        if (detectionString != nil)
        {
            _label.text = detectionString;
//            [_session removeOutput:_output];
            [_session stopRunning];
            // close session: (IDO)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.55 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate didFinishScanningBarcodeWithResult:self barcodeValue:detectionString];
            });
            break;
        }
        else
            _label.text = @"Point at SIM ICCID barcode";
    }

    _highlightView.frame = highlightViewRect;
}

@end