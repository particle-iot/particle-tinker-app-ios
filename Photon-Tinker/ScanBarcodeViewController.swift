//
// Created by Raimundas Sakalauskas on 2019-05-02.
// Copyright (c) 2019 Particle. All rights reserved.
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

//    var label: UILabel!
//    var labelBackground: UIView!

    var overlayImageView: UIImageView!

    var flashlightButton: UIButton!
    var flashlightButtonBackground: UIView!

    var cancelButtonBackground: UIView!
    var cancelButton: UIButton!

    var eSeriesSetup: Bool!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        overlayImageView = UIImageView(image: UIImage(named: "ImgOverlayGraphic"))
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.image = overlayImageView.image?.withRenderingMode(.alwaysTemplate)
        overlayImageView.tintColor = UIColor.white
        view.addSubview(overlayImageView)

        NSLayoutConstraint.activate([
            self.overlayImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.overlayImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])

        if (self.eSeriesSetup) {
            NSLayoutConstraint.activate([
                self.overlayImageView.heightAnchor.constraint(equalTo: self.overlayImageView.widthAnchor)
            ])
        }

        flashlightButtonBackground = UIView(frame: .zero)
        flashlightButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        flashlightButtonBackground.alpha = 0.5
        flashlightButtonBackground.layer.cornerRadius = 20
        flashlightButtonBackground.backgroundColor = UIColor.gray
        view.addSubview(flashlightButtonBackground)

        NSLayoutConstraint.activate([
            self.flashlightButtonBackground.widthAnchor.constraint(equalToConstant: 40),
            self.flashlightButtonBackground.heightAnchor.constraint(equalToConstant: 40)
        ])

        flashlightButton = UIButton(type: .custom)
        flashlightButton.translatesAutoresizingMaskIntoConstraints = false
        flashlightButton.setImage(UIImage(named: "ImgFlashlight"), for: .normal)
        flashlightButton.tintColor = UIColor.white
        flashlightButton.addTarget(self, action: #selector(toggleTorchButton), for: .touchUpInside)
        view.addSubview(flashlightButton)

        NSLayoutConstraint.activate([
            self.flashlightButton.centerXAnchor.constraint(equalTo: self.flashlightButtonBackground.centerXAnchor),
            self.flashlightButton.centerYAnchor.constraint(equalTo: self.flashlightButtonBackground.centerYAnchor),
            self.flashlightButton.widthAnchor.constraint(equalTo: self.flashlightButtonBackground.widthAnchor, constant: -16),
            self.flashlightButton.heightAnchor.constraint(equalTo: self.flashlightButtonBackground.heightAnchor, constant: -16)
        ])

        cancelButtonBackground = UIView(frame: .zero)
        cancelButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        cancelButtonBackground.alpha = 0.5
        cancelButtonBackground.layer.cornerRadius = 20
        cancelButtonBackground.backgroundColor = UIColor.gray
        view.addSubview(cancelButtonBackground)

        NSLayoutConstraint.activate([
            self.cancelButtonBackground.widthAnchor.constraint(equalToConstant: 40),
            self.cancelButtonBackground.heightAnchor.constraint(equalToConstant: 40)
        ])

        cancelButton = UIButton(type: .custom)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(named: "IconClose"), for: .normal)
        cancelButton.tintColor = UIColor.white
        cancelButton.addTarget(self, action: #selector(cancelScan), for: .touchUpInside)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            self.cancelButton.centerXAnchor.constraint(equalTo: self.cancelButtonBackground.centerXAnchor),
            self.cancelButton.centerYAnchor.constraint(equalTo: self.cancelButtonBackground.centerYAnchor),
            self.cancelButton.widthAnchor.constraint(equalTo: self.cancelButtonBackground.widthAnchor, constant: -16),
            self.cancelButton.heightAnchor.constraint(equalTo: self.cancelButtonBackground.heightAnchor, constant: -16)
        ])

        if #available(iOS 11, *) {
            NSLayoutConstraint.activate([
                self.overlayImageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75),

                self.flashlightButtonBackground.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -16),
                self.flashlightButtonBackground.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),

                self.cancelButtonBackground.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 16),
                self.cancelButtonBackground.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.overlayImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.75),

                self.flashlightButtonBackground.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                self.flashlightButtonBackground.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 36),

                self.cancelButtonBackground.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                self.cancelButtonBackground.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 36)
            ])
        }



        session = AVCaptureSession()
        device = AVCaptureDevice.default(for: .video)

        guard let device = device else {
            //TODO: fix this?...
            fatalError("no AVCaptureDevice")
        }

        input = try? AVCaptureDeviceInput(device: device)
        guard let input = input else {
            //TODO: fix this?...
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
        view.layer.insertSublayer(prevLayer, at: 0)

        session.startRunning()
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

        prevLayer.frame = view.bounds
    }


    @objc func cancelScan(_ sender: UIButton) {
        delegate.didCancelScanningBarcode(self)
    }


    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var detectionString: String? = nil

        for metadata in metadataObjects {
            if (metadata.type == .code128) {
                guard let barCodeObject = prevLayer.transformedMetadataObject(for: metadata) as? AVMetadataMachineReadableCodeObject else { return }
                detectionString = barCodeObject.stringValue

                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            } else if (metadata.type == .dataMatrix) {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                if (self.eSeriesSetup) {
                    guard let readableObject = prevLayer.transformedMetadataObject(for: metadata) as? AVMetadataMachineReadableCodeObject else {
                        return
                    }
                    detectionString = readableObject.stringValue
                } else {
                    session.stopRunning()
                    let ac = UIAlertController(title: TinkerStrings.ScanBarcode.Error.WrongStickerError.Title, message: TinkerStrings.ScanBarcode.Error.WrongStickerError.Message, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: TinkerStrings.Action.Ok, style: .default) { [weak self] action in
                        if let self = self {
                            self.session.startRunning()
                        }
                    })
                    present(ac, animated: true)
                }
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
