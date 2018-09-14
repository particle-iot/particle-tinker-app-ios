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
            NSLog("MeshSetupFlowUI: \(message)")
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
        setInitialDeviceInfo?(self.selectedDeviceDataMatrix)
    }

    //user successfully scanned initial code
    func commissionerStickerCodeFound(dataMatrix: MeshSetupDataMatrix) {
        log("dataMatrix scanned: \(dataMatrix)")
        self.selectedDeviceDataMatrix = dataMatrix
        setCommissionerDeviceInfo?(self.selectedDeviceDataMatrix)
    }
    
    
    

    //MARK: MeshSetupFlowManagerDelegate
    var setInitialDeviceInfo: MeshSetupSetDevice!
    func meshSetupDidRequestInitialDeviceInfo(setInitialDeviceInfo: @escaping MeshSetupSetDevice) {
        self.setInitialDeviceInfo = setInitialDeviceInfo
    }

    func meshSetupDidRequestToLeaveNetwork(network: Particle.MeshSetupNetworkInfo, setLeaveNetwork: @escaping MeshSetupSetBool) {
        setLeaveNetwork(true)
    }


    func meshSetupDidRequestToSelectNetwork(availableNetworks: [Particle.MeshSetupNetworkInfo], setSelectedNetwork: @escaping MeshSetupSetNetwork) {
        if (availableNetworks.count == 0) {
            flowManager.retryLastAction()
        } else {
            setSelectedNetwork(availableNetworks.first!)
        }
    }

    var setCommissionerDeviceInfo: MeshSetupSetDevice!
    func meshSetupDidRequestCommissionerDeviceInfo(setCommissionerDeviceInfo: @escaping MeshSetupSetDevice) {
        self.setCommissionerDeviceInfo = setCommissionerDeviceInfo

        DispatchQueue.main.async {
            let scanVC = MeshSetupScanCodeViewController.storyboardViewController()
            scanVC.setup(didFindStickerCode: self.commissionerStickerCodeFound)
            self.present(scanVC, animated: true)
        }
    }


    func meshSetupDidRequestToEnterSelectedNetworkPassword(setSelectedNetworkPassword: @escaping MeshSetupSetString) {
        setSelectedNetworkPassword("zxcasd")
    }

    func meshSetupDidRequestToEnterDeviceName(setDeviceName: @escaping MeshSetupSetString) {
        setDeviceName(randomStringWithLength(10))
    }


    func meshSetupDidRequestToAddOneMoreDevice(setAddOneMoreDevice: @escaping MeshSetupSetBool) {
        setAddOneMoreDevice(true)
    }

    func meshSetupDidRequestToFinishSetupEarly(setFinishSetupEarly: @escaping MeshSetupSetBool) {
        setFinishSetupEarly(false)
    }


    func meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: [Particle.MeshSetupNetworkInfo], setSelectedNetwork: @escaping MeshSetupSetNetworkOptional) {
        setSelectedNetwork(nil)
    }

    func meshSetupDidRequestToEnterNewNetworkName(setNewNetworkName: @escaping MeshSetupSetString) {
        setNewNetworkName("fancynetwork")
    }

    func meshSetupDidRequestToEnterNewNetworkPassword(setNewNetworkPassword: @escaping MeshSetupSetString) {
        setNewNetworkPassword("zxcasd")
    }

    func meshSetupDidRequestToChooseBetweenRetryInternetOrSwitchToJoinerFlow(setSwitchToJoiner: @escaping MeshSetupSetBool) {
        setSwitchToJoiner(false)
    }


    func meshSetupDidEnterState(state: MeshSetupFlowState) {
        log("flow setup entered state: \(state)")
    }

    func meshSetupError(error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?) {
        if (error == .DeviceTooFar) {
            //TODO: show prompt and repeat step
        } else {
            //fail...
            log("flow failed: \(error)")
        }
    }




    //MARK: Helpers
    func randomStringWithLength(_ len: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

        var str = ""
        for _ in 0 ..< len {
            var index = letters.index(letters.startIndex, offsetBy: Int(arc4random_uniform(UInt32(letters.count))))
            str.append(letters[index])
        }

        return str
    }


    private func addCancel() {
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        self.topViewController!.navigationItem.rightBarButtonItem = cancelButton
    }

    @objc func cancelButtonTapped() {
        self.flowManager.cancelSetup()
        self.dismiss(animated: true)
    }

}
