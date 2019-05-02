//
// Created by Raimundas Sakalauskas on 2019-05-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation
import AVFoundation

protocol ScanBarcodeViewControllerDelegate: class {
    func didFinishScanningBarcode(withResult scanBarcodeViewController: ScanBarcodeViewController, barcodeValue: String)
    func didCancelScanningBarcode(_ scanBarcodeViewController: ScanBarcodeViewController)
}


class ScanBarcodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScanBarcodeViewControllerDelegate!

    var session: AVCaptureSession!
    var output: AVCaptureMetadataOutput!
    var prevLayer: AVCaptureVideoPreviewLayer!

    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?

    var label: UILabel!
    var overlayImageView: UIImageView!
    var overlayButton: UIButton!
    var cancelButton: UIButton!
    var circleView: UIView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        label = UILabel()
        label.frame = CGRect(x: 0, y: self.view.bounds.size.height - 40, width: self.view.bounds.size.width, height: 40);
        label.backgroundColor = UIColor(white: 0.15, alpha: 0.65)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "Point at SIM ICCID barcode"
        self.view.addSubview(label)

        overlayImageView = UIImageView(image: UIImage(named: "overlaygraphic"))
        overlayImageView.frame = CGRect(x: 30, y: 150, width: view.bounds.size.width - 60, height: view.bounds.size.height - 300)
        overlayImageView.image = overlayImageView.image?.withRenderingMode(.alwaysTemplate)
        overlayImageView.tintColor = UIColor.white
        view.addSubview(overlayImageView)


        overlayButton = UIButton(type: .custom)
        overlayButton.setImage(UIImage(named: "flashlight"), for: .normal)
        overlayButton.frame = CGRect(x: 30, y: 30, width: 48, height: 48)
        overlayButton.tintColor = UIColor.white
        overlayButton.addTarget(self, action: #selector(toggleTorchButton), for: .touchUpInside)
        view.addSubview(overlayButton)


        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.frame = CGRect(x: view.bounds.size.width - 60, y: view.bounds.size.height - 44, width: 60, height: 48)
        cancelButton.addTarget(self, action: #selector(cancelScan), for: .touchUpInside)
        view.addSubview(cancelButton)

        circleView = UIView(frame: CGRect(x: 22, y: 24, width: 64, height: 64))
        circleView.alpha = 0.5
        circleView.layer.cornerRadius = 32
        circleView.backgroundColor = UIColor.gray
        view.addSubview(circleView)

        session = AVCaptureSession()
        device = AVCaptureDevice.default(for: .video)

        guard let device = device else {
            fatalError("no AVCaptureDevice")
        }

        input = try? AVCaptureDeviceInput(device: device)
        guard let input = input else {
            fatalError("no AVCaptureDeviceInput")
        }
        session.addInput(input)

        output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: .main)
        session.addOutput(output)

        output.metadataObjectTypes = output.availableMetadataObjectTypes

        prevLayer = AVCaptureVideoPreviewLayer(session: session)
        prevLayer.frame = view.bounds
        prevLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(prevLayer)

        session.startRunning()


        view.bringSubview(toFront:label)
        view.bringSubview(toFront:circleView)
        view.bringSubview(toFront:overlayButton)
        view.bringSubview(toFront:overlayImageView)
        view.bringSubview(toFront:cancelButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let device = device, device.hasTorch {
            do {
                try device.lockForConfiguration()
                try device.setTorchModeOn(level: 1.0)
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        }

    }

    @objc func toggleTorchButton(sender: UIButton) {
        if let device = device, device.hasTorch {

            do {
                try device.lockForConfiguration()

                if device.torchMode == .off {
                    try device.setTorchModeOn(level: 1.0)
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }

        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if #available(iOS 11.0, *) {
            let insets = view.safeAreaInsets

            label.frame = CGRect(x: 0, y: view.bounds.size.height - 40 - insets.bottom, width: view.bounds.size.width, height: 40)
            cancelButton.frame = CGRect(x: view.bounds.size.width - 60, y: view.bounds.size.height - 44 - insets.bottom, width: 60, height: 48)

            overlayButton.frame = CGRect(x: 30, y: 30 + insets.top, width: 48, height: 48)
            circleView.frame = CGRect(x: 22, y: 24 + insets.top, width: 64, height: 64)

            overlayImageView.frame = CGRect(x: 30, y: 150 + insets.top, width: view.bounds.size.width - 60, height: view.bounds.size.height - 300 - insets.top - insets.bottom)
        }
    }


    @objc func cancelScan(_ sender: UIButton) {
        delegate.didCancelScanningBarcode(self)
    }


    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var barCodeObject: AVMetadataMachineReadableCodeObject?
        var detectionString: String? = nil

        let barCodeTypes = [AVMetadataObject.ObjectType.code128]

        for metadata in metadataObjects {
            if (metadata.type == .code128) {
                barCodeObject = prevLayer.transformedMetadataObject(for: metadata) as? AVMetadataMachineReadableCodeObject
                detectionString = barCodeObject!.stringValue
            }
        }

        if detectionString != nil {
            session.stopRunning()

            DispatchQueue.main.async {
                self.delegate.didFinishScanningBarcode(withResult: self, barcodeValue: detectionString!)
            }
        }
    }

}