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
    @IBOutlet weak var titleLabel: ParticleLabel!
    @IBOutlet weak var textLabel: ParticleLabel!
    @IBOutlet weak var imageView: UIImageView!
    
    internal var callback: ((String) -> ())!

    private var captureSession: AVCaptureSession!
    private var videoCaptureDevice: AVCaptureDevice?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var focusFadeView: FocusRectView!

    func setup(didFindStickerCode: @escaping (String) -> ()) {
        self.callback = didFindStickerCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        evalPermissions()
        addFadableViews()
        addFadeView()
    }

    private func addFadeView() {
        focusFadeView = FocusRectView(frame: .zero)
        focusFadeView.translatesAutoresizingMaskIntoConstraints = false
        focusFadeView.focusRectSize = CGSize(width: 150, height: 150)

        view.addSubview(focusFadeView)
        NSLayoutConstraint.activate([
            focusFadeView.leftAnchor.constraint(equalTo: cameraView.leftAnchor),
            focusFadeView.rightAnchor.constraint(equalTo: cameraView.rightAnchor),
            focusFadeView.topAnchor.constraint(equalTo: cameraView.topAnchor),
            focusFadeView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor)
        ])
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
        let ac = UIAlertController(title: MeshStrings.Prompt.NoCameraPermissionsTitle, message: MeshStrings.Prompt.NoCameraPermissionsText, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: MeshStrings.Action.OpenSettings, style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
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

        NotificationCenter.default.addObserver(self, selector: #selector(startCaptureSession), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopCaptureSession), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewLayer?.frame = self.cameraView.layer.bounds
    }

    func showFailed() {
        let ac = UIAlertController(title: MeshStrings.Prompt.NoCameraTitle, message: MeshStrings.Prompt.NoCameraText, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: MeshStrings.Action.Ok, style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startCaptureSession()
    }

    override func setStyle() {
        if (ScreenUtils.getPhoneScreenSizeClass() > .iPhone4) {
            titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
            textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        } else {
            titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
            textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.PrimaryTextColor)
        }
    }

    override func setContent() {
        titleLabel.text = MeshStrings.ScanSticker.Title
        textLabel.text = MeshStrings.ScanSticker.Text
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


    override func resume(animated: Bool) {
        super.resume(animated: animated)
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
