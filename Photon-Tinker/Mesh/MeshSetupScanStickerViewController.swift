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
        evalPermissions()
        addFadableViews()
    }

    private func evalPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        if status == .authorized {
            if (Thread.isMainThread) {
                initCaptureSession()
            } else {
                DispatchQueue.main.async {
                    self.initCaptureSession()
                }
            }
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (Bool) in
                self.evalPermissions()
            }
        } else {
            showNoPermissionsMessage()
        }
    }
    
    func showNoPermissionsMessage() {
        let ac = UIAlertController(title: MeshSetupStrings.Prompt.NoCameraPermissionsTitle, message: MeshSetupStrings.Prompt.NoCameraPermissionsText, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: MeshSetupStrings.Action.OpenSettings, style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl)
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        }
        ac.addAction(settingsAction)
        present(ac, animated: true)
        captureSession = nil
    }
    
    private func initCaptureSession() {
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
            showFailed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.dataMatrix]
        } else {
            showFailed()
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

    func showFailed() {
        let ac = UIAlertController(title: MeshSetupStrings.Prompt.NoCameraTitle, message: MeshSetupStrings.Prompt.NoCameraText, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default))
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

            self.fade()
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


    func resume(animated: Bool) {
        (self as Fadeable).resume(animated: animated)
        self.startCaptureSession()
    }

    private func addFadableViews() {
        if viewsToFade == nil {
            viewsToFade = [UIView]()
        }

        viewsToFade!.append(titleLabel)
        viewsToFade!.append(textLabel)
        viewsToFade!.append(imageView)
        viewsToFade!.append(cameraView)
    }
}
