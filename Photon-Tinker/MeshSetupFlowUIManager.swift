//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation
import UIKit

class MeshSetupFlowUIManager : UINavigationController, Storyboardable, MeshSetupFlowManagerDelegate {

    private var flowManager: MeshSetupFlowManager!
    private var selectedDeviceType: ParticleDeviceType!
    private var selectedDeviceDataMatrix: MeshSetupDataMatrix!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.flowManager = MeshSetupFlowManager(delegate: self)
        self.flowManager.startSetup()
        self.addCancel()

        let selectDeviceVC = self.viewControllers.first! as! MeshSetupSelectDeviceViewController
        selectDeviceVC.setup(didSelectDevice: initialDeviceSelected)
    }

    private func log(_ message: String) {
        if (MeshSetup.LogUIManager) {
            NSLog("MeshSetupFlowUIManager: \(message)")
        }
    }




    //entry to the flow
    func initialDeviceSelected(type: ParticleDeviceType) {
        log("initial device type selected: \(type)")
        self.selectedDeviceType = type

        let getReadyVC = MeshSetupGetReadyViewController.storyboardViewController()
        getReadyVC.setup(didPressReady: initialDeviceReady)
        self.pushViewController(getReadyVC, animated: true)
        self.addCancel()
    }

    //initial device ready, we explain user the sticker concept
    func initialDeviceReady() {
        log("initial device ready")

        let findStickerVC = MeshSetupFindStickerViewController.storyboardViewController()
        findStickerVC.setup(didPressScan: initialDeviceStickerFound)
        self.pushViewController(findStickerVC, animated: true)
        self.addCancel()
    }

    //user wants to scan data matrix
    func initialDeviceStickerFound() {
        log("sticker found by user")

        let scanVC = MeshSetupScanCodeViewController.storyboardViewController()
        scanVC.setup(didFindStickerCode: initialStickerCodeFound)
        self.present(scanVC, animated: true)
    }

    //user successfully scanned initial code
    func initialStickerCodeFound(dataMatrix: MeshSetupDataMatrix) {
        log("dataMatrix scanned: \(dataMatrix)")
        self.selectedDeviceDataMatrix = dataMatrix
        self.flowManager.setInitialDeviceInfo(deviceType: self.selectedDeviceType, dataMatrix: self.selectedDeviceDataMatrix)
    }

    //MARK: MeshSetupFlowManagerDelegate
    func meshSetupDidRequestInitialDeviceInfo() {
        //do nothing
        log("flow manager requested initial device info")
    }

    func meshSetupDidEnterState(state: MeshSetupFlowState) {
        log("flow setup entered state: \(state)")
    }




    //MARK: Helpers
    private func addCancel() {
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        self.topViewController!.navigationItem.rightBarButtonItem = cancelButton
    }

    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

}
