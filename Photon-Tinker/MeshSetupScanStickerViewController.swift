//
//  MeshSetupScanStickerViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import AVFoundation

class MeshSetupScanStickerViewController: MeshSetupViewController, AVCaptureMetadataOutputObjectsDelegate, Storyboardable {
    @IBOutlet weak var cameraView: UIView!

    @IBOutlet weak var titleLabel: MeshLabel!
    
    @IBOutlet weak var textLabel: MeshLabel!

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    internal var callback: ((String) -> ())!
    internal var deviceType: ParticleDeviceType!

    func setup(didFindStickerCode: @escaping (String) -> (), deviceType: ParticleDeviceType) {
        self.callback = didFindStickerCode
        self.deviceType = deviceType
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
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
        previewLayer.frame = self.cameraView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.cameraView.layer.addSublayer(previewLayer)
        self.cameraView.clipsToBounds = true

        captureSession.startRunning()


        view.backgroundColor = MeshSetupStyle.ViewBackgroundColor

        cameraView.backgroundColor = MeshSetupStyle.VideoBackgroundColor
        cameraView.clipsToBounds = true
        cameraView.layer.cornerRadius = 5
    }



    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }

        setContent()
    }

    open func setContent() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        titleLabel.text = MeshSetupStrings.ScanSticker.Title

        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.text = MeshSetupStrings.ScanSticker.Text

        replaceMeshSetupStringTemplates(view: self.view, deviceType: self.deviceType.description)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.foundDataMatrixString(stringValue)
        }
    }

    func restartCaptureSession() {
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    func foundDataMatrixString(_ dataMatrixString: String) {
        callback(dataMatrixString)
    }
    
}
