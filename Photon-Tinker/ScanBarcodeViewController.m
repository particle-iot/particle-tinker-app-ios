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
}
@end

@implementation ScanBarcodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];

    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"Point at SIM ICCID barcode";
    [self.view addSubview:_label];

    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic"]];
    [overlayImageView setFrame:CGRectMake(30, 150, self.view.bounds.size.width-60, self.view.bounds.size.height-300)];
    overlayImageView.image = [overlayImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [overlayImageView setTintColor:[UIColor whiteColor]];
    [[self view] addSubview:overlayImageView];
    
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:@"flashlight"] forState:UIControlStateNormal];
    [overlayButton setFrame:CGRectMake(30, 30, 48, 48)];
    [overlayButton setTintColor:[UIColor whiteColor]];
    [overlayButton addTarget:self action:@selector(toggleTorchButton:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:overlayButton];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(self.view.bounds.size.width-60, self.view.bounds.size.height-44, 60, 48)];
    [cancelButton addTarget:self action:@selector(cancelScan:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:cancelButton];

    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(22, 24, 64, 64)];
    circleView.alpha = 0.5;
    circleView.layer.cornerRadius = 32;
    circleView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:circleView];
    
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
    [self.view bringSubviewToFront:circleView];
    [self.view bringSubviewToFront:overlayButton];
    [self.view bringSubviewToFront:overlayImageView];
    [self.view bringSubviewToFront:cancelButton];

    
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