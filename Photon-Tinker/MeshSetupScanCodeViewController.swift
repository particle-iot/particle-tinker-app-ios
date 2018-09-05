//
//  MeshSetupScanCodeViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import AVFoundation

class MeshSetupScanCodeViewController: MeshSetupViewController, AVCaptureMetadataOutputObjectsDelegate, Storyboardable {
    @IBOutlet weak var cameraView: UIView!

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    private var callback: ((MeshSetupDataMatrix) -> ())?

    func setup(didFindStickerCode: @escaping (MeshSetupDataMatrix) -> ()) {
        self.callback = didFindStickerCode
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.cameraView.backgroundColor = UIColor.black
        self.cameraView.layer.borderWidth = 1.0
        self.cameraView.layer.borderColor = UIColor.black.cgColor

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

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func foundDataMatrixString(_ dataMatrixString: String) {
        if let callback = callback {
            callback(processDataMatrix(dataMatrixString: dataMatrixString))
        }

        self.dismiss(animated: true, completion: nil)
    }

    private func processDataMatrix(dataMatrixString: String) -> MeshSetupDataMatrix {
        let arr = dataMatrixString.split(separator: " ")
        let serialNumber = String(arr[0])//"12345678abcdefg"
        let mobileSecret = String(arr[1])//"ABCDEFGHIJKLMN"
        return MeshSetupDataMatrix(serialNumber: serialNumber, mobileSecret: mobileSecret)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    
    
}
