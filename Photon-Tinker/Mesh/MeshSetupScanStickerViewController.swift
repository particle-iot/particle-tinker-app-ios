//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import AVFoundation

class MeshSetupScanStickerViewController: MeshSetupViewController, AVCaptureMetadataOutputObjectsDelegate, Storyboardable {

    static var nibName: String {
        return "MeshSetupScanStickerView"
    }

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var textLabel: MeshLabel!
    @IBOutlet weak var imageView: UIImageView!
    
    internal var callback: ((String) -> ())!

    private var captureSession: AVCaptureSession!
    private var videoCaptureDevice: AVCaptureDevice?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func setup(didFindStickerCode: @escaping (String) -> ()) {
        self.callback = didFindStickerCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession = AVCaptureSession()
        guard let vcd = AVCaptureDevice.default(for: AVMediaType.video) else { return }

        videoCaptureDevice = vcd
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.dataMatrix]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.frame = self.cameraView.layer.bounds
        previewLayer!.videoGravity = .resizeAspectFill

        cameraView.layer.addSublayer(previewLayer!)
        cameraView.clipsToBounds = true

        startCaptureSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(startCaptureSession), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopCaptureSession), name: .UIApplicationDidEnterBackground, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewLayer?.frame = self.cameraView.layer.bounds
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startCaptureSession()
    }

    override func setStyle() {
        if (MeshScreenUtils.getPhoneScreenSizeClass() > .iPhone4) {
            titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
            textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        } else {
            titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
            textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
        }
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ScanSticker.Title
        textLabel.text = MeshSetupStrings.ScanSticker.Text
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopCaptureSession()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            showSpinner()
            callback(stringValue)
        }
    }

    @objc
    private func stopCaptureSession() {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }

        if videoCaptureDevice?.hasTorch == true {
            do {
                try? videoCaptureDevice?.lockForConfiguration()
                videoCaptureDevice?.torchMode = .off
                try? videoCaptureDevice?.unlockForConfiguration()
            }
        }
    }

    @objc
    func startCaptureSession() {
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }

        if videoCaptureDevice?.hasTorch == true {
            do {
                try? videoCaptureDevice?.lockForConfiguration()
                videoCaptureDevice?.torchMode = .auto
                try? videoCaptureDevice?.unlockForConfiguration()
            }
        }
    }

    override func resume(animated: Bool) {
        super.resume(animated: animated)

        self.startCaptureSession()

        unfadeContent(animated: animated)
        ParticleSpinner.hide(view, animated: animated)
        isBusy = false
    }

    func showSpinner() {
        fadeContent()
        ParticleSpinner.show(view)
    }

    internal func fadeContent() {
        self.isBusy = true
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.titleLabel.alpha = 0.5
            self.textLabel.alpha = 0.5
            self.imageView.alpha = 0.5
            self.cameraView.alpha = 0.5
        }
    }

    internal func unfadeContent(animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.titleLabel.alpha = 1
                self.textLabel.alpha = 1
                self.imageView.alpha = 1
                self.cameraView.alpha = 1
            }
        } else {
            self.titleLabel.alpha = 1
            self.textLabel.alpha = 1
            self.imageView.alpha = 1
            self.cameraView.alpha = 1

            self.view.setNeedsDisplay()
        }
    }


}
