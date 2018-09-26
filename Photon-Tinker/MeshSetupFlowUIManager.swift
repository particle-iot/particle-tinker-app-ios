//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation
import UIKit

class MeshSetupFlowUIManager : UIViewController, Storyboardable, MeshSetupFlowManagerDelegate {

    @IBOutlet weak var accountLabel: MeshLabel!

    private var flowManager: MeshSetupFlowManager!
    private var embededNavigationController: UINavigationController!

    private var targetDeviceType: ParticleDeviceType?
    private var targetDeviceDataMatrixString: String!
    private var targetDeviceName:String?

    private var commissionerDeviceType: ParticleDeviceType?
    private var commissionerDeviceDataMatrixString: String!

    private var selectedNetwork: MeshSetupNetworkInfo?
    private var scanInProgress: Bool = false

    private var pairingScreenDone: Bool?
    private var pairingFlowDone: Bool?


    override func awakeFromNib() {
        super.awakeFromNib()

        self.flowManager = MeshSetupFlowManager(delegate: self)
        self.flowManager.startSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.accountLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PlaceHolderTextColor)
        self.accountLabel.text = ParticleCloud.sharedInstance().loggedInUsername ?? ""

        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedNavigation") {
            self.embededNavigationController = segue.destination as! UINavigationController

            let selectDeviceVC = self.embededNavigationController.viewControllers.first! as! MeshSetupSelectDeviceViewController
            selectDeviceVC.setup(didSelectDevice: targetDeviceSelected)
        }
        super.prepare(for: segue, sender: sender)
    }


    private func log(_ message: String) {
        if (MeshSetup.LogUIManager) {
            NSLog("MeshSetupFlowUI: \(message)")
        }
    }


    //MARK: Get Target Device Info
    func meshSetupDidRequestTargetDeviceInfo() {
        //do nothing here
    }

    func targetDeviceSelected(type: ParticleDeviceType) {
        log("target device type selected: \(type)")
        self.targetDeviceType = type

        let getReadyVC = MeshSetupGetReadyViewController.storyboardViewController()
        getReadyVC.setup(didPressReady: targetDeviceReady, deviceType: self.targetDeviceType)
        self.embededNavigationController.pushViewController(getReadyVC, animated: true)
    }

    func targetDeviceReady() {
        log("target device ready")

        let findStickerVC = MeshSetupFindStickerViewController.storyboardViewController()
        findStickerVC.setup(didPressScan: targetDeviceStickerFound, deviceType: self.targetDeviceType)
        self.embededNavigationController.pushViewController(findStickerVC, animated: true)
    }

    func targetDeviceStickerFound() {
        log("sticker found by user")

        let scanVC = MeshSetupScanStickerViewController.storyboardViewController()
        scanVC.setup(didFindStickerCode: targetDeviceCodeFound, deviceType: self.targetDeviceType)
        self.embededNavigationController.pushViewController(scanVC, animated: true)
    }

    //user successfully scanned target code
    func targetDeviceCodeFound(dataMatrixString: String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        self.targetDeviceDataMatrixString = dataMatrixString

        //make sure the scanned device is of the same type as user requested in the first screen
        if let matrix = MeshSetupDataMatrix(dataMatrixString: self.targetDeviceDataMatrixString),
           let type = ParticleDeviceType(serialNumber: matrix.serialNumber),
           self.targetDeviceType == nil || type == self.targetDeviceType {
            self.targetDeviceType = type

            let error = flowManager.setTargetDeviceInfo(dataMatrix: matrix)
            guard error == nil else {
                fatalError("shouldn't happen")
            }

            let pairingVC = MeshSetupPairingProcessViewController.storyboardViewController()
            pairingVC.setup(didFinishScreen: targetDevicePairingScreenDone, deviceType: self.targetDeviceType, deviceName: flowManager.targetDeviceName() ?? self.targetDeviceType!.description)
            self.embededNavigationController.pushViewController(pairingVC, animated: true)
        } else {
            if let vc = self.embededNavigationController.topViewController as? MeshSetupScanStickerViewController {
                vc.restartCaptureSession()
            } else {
                //TODO: problem?
            }
        }
    }



    //MARK: Complete preflow, artifial pause for UI to catch up.
    func meshSetupDidPairWithTargetDevice() {
        pairingFlowDone = true

        if pairingScreenDone == true {
            flowManager.continueWithMainFlow()

            pairingScreenDone = nil
            pairingFlowDone = nil
        }
    }

    func targetDevicePairingScreenDone() {
        pairingScreenDone = true

        if pairingFlowDone == true {
            flowManager.continueWithMainFlow()

            pairingScreenDone = nil
            pairingFlowDone = nil
        }

        //the next thing to happen will be one out of 3:
        // 1)meshSetupDidRequestToLeaveNetwork callback
        // 2)meshSetupDidEnterState: TargetDeviceScanningForNetworks
        // 3)meshSetupDidEnterState: TargetDeviceConnectingToInternet

    }





    //MARK: Leave existing network
    //TODO: For spectra we simply leave the current network. No hard feelings
    func meshSetupDidRequestToLeaveNetwork(network: Particle.MeshSetupNetworkInfo) {
        flowManager.setTargetDeviceLeaveNetwork(leave: true)
    }






    //MARK: Scan networks
    private func showScanNetworks() {
        DispatchQueue.main.async {
            let networksVC = MeshSetupSelectNetworkViewController.storyboardViewController()
            networksVC.setup(didSelectNetwork: self.didSelectNetwork)
            self.embededNavigationController.pushViewController(networksVC, animated: true)
        }
    }


    func didSelectNetwork(network: MeshSetupNetworkInfo) {
        self.selectedNetwork = network

        if (!scanInProgress) {
            flowManager.setSelectedNetwork(selectedNetwork: selectedNetwork!)
        }
    }


    func meshSetupDidRequestToSelectNetwork(availableNetworks: [Particle.MeshSetupNetworkInfo]) {
        NSLog("scan complete")
        self.scanInProgress = false

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let selectedNetwork = self.selectedNetwork {
            flowManager.setSelectedNetwork(selectedNetwork: selectedNetwork)
            return
        } else if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
            vc.setNetworks(networks: availableNetworks)
        }


        //if no networks found = force instant rescan
        if (availableNetworks.count == 0) {
            forceScan()
        } else {
            //rescan in 3seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                [weak self] in
                //only rescan if user hasn't made choice by now

                if self != nil, self!.selectedNetwork == nil {
                    self!.scanInProgress = true
                    self!.forceScan()
                }
            }
        }

    }

    private func forceScan() {
        if (flowManager.rescanNetworks() == nil) {
            self.scanInProgress = true
            if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
                vc.startScanning()
            }
        } else {
            //TODO: remove for prod
            fatalError("something is horribly wrong here 1")
        }
    }


    //MARK: Connect to selected network
    func meshSetupDidRequestCommissionerDeviceInfo() {
        NSLog("requesting commisioner info!!")

        DispatchQueue.main.async {
            let getReadyVC = MeshSetupGetCommissionerReadyViewController.storyboardViewController()
            getReadyVC.setup(didPressReady: self.commissionerDeviceReady, deviceType: self.targetDeviceType, networkName: self.selectedNetwork!.name)
            self.embededNavigationController.pushViewController(getReadyVC, animated: true)
        }
    }

    func commissionerDeviceReady() {
        log("commissioner device ready")

        let findStickerVC = MeshSetupFindCommissionerStickerViewController.storyboardViewController()
        findStickerVC.setup(didPressScan: commissionerDeviceStickerFound, deviceType: self.targetDeviceType, networkName: self.selectedNetwork!.name)
        self.embededNavigationController.pushViewController(findStickerVC, animated: true)
    }

    func commissionerDeviceStickerFound() {
        log("sticker found by user")

        let scanVC = MeshSetupScanCommissionerStickerViewController.storyboardViewController()
        scanVC.setup(didFindStickerCode: commissionerDeviceCodeFound)
        self.embededNavigationController.pushViewController(scanVC, animated: true)
    }

    //user successfully scanned target code
    func commissionerDeviceCodeFound(dataMatrixString: String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        self.commissionerDeviceDataMatrixString = dataMatrixString

        //make sure the scanned device is of the same type as user requested in the first screen
        if let matrix = MeshSetupDataMatrix(dataMatrixString: self.commissionerDeviceDataMatrixString),
            let deviceType = ParticleDeviceType(serialNumber: matrix.serialNumber) {

            self.commissionerDeviceType = deviceType
            flowManager.setCommissionerDeviceInfo(dataMatrix: matrix)


            let pairingVC = MeshSetupPairingCommissionerProcessViewController.storyboardViewController()
            pairingVC.setup(didFinishScreen: commissionerDevicePairingScreenDone, deviceType: deviceType, deviceName: flowManager.commissionerDeviceName() ?? deviceType.description)
            self.embededNavigationController.pushViewController(pairingVC, animated: true)
        } else {
            if let vc = self.embededNavigationController.topViewController as? MeshSetupScanCommissionerStickerViewController {
                vc.restartCaptureSession()
            } else {
                //TODO: problem?
            }
        }
    }

    func meshSetupDidRequestToEnterSelectedNetworkPassword() {
        pairingFlowDone = true

        if pairingScreenDone == true {
            pairingScreenDone = nil
            pairingFlowDone = nil

            showPasswordPrompt()
        }
    }

    func commissionerDevicePairingScreenDone() {
        pairingScreenDone = true

        if pairingFlowDone == true {
            pairingScreenDone = nil
            pairingFlowDone = nil

            showPasswordPrompt()
        }
    }

    private func showPasswordPrompt() {
        let passwordVC = MeshSetupNetworkPasswordViewController.storyboardViewController()
        passwordVC.setup(didEnterPassword: didEnterNetworkPassword, networkName: self.selectedNetwork!.name)
        self.embededNavigationController.pushViewController(passwordVC, animated: true)
    }

    func didEnterNetworkPassword(password: String) {
        flowManager.setSelectedNetworkPassword(password) { error in
            if error == nil {
                //this will happen automatically
            } else if let vc = self.embededNavigationController.topViewController as? MeshSetupNetworkPasswordViewController {
                vc.setWrongInput()
            }
        }
    }

    private func showJoiningNetwork() {
        DispatchQueue.main.async {
            let joiningVC = MeshSetupJoiningNetworkViewController.storyboardViewController()
            joiningVC.setup(didFinishScreen: self.didFinishJoinNetworkScreen, networkName: self.selectedNetwork!.name, deviceType: self.targetDeviceType)
            self.embededNavigationController.pushViewController(joiningVC, animated: true)
        }
    }

    func didFinishJoinNetworkScreen() {
        DispatchQueue.main.async {
            let nameVC = MeshSetupNameDeviceViewController.storyboardViewController()
            nameVC.setup(didEnterPassword: self.didEnterName, deviceType: self.targetDeviceType)
            self.embededNavigationController.pushViewController(nameVC, animated: true)
        }
    }

    func meshSetupDidRequestToEnterDeviceName() {
        //on joiner flow this won't execute, but this will execute on repetead joins & ethernet flow
        guard let topVC = self.embededNavigationController.topViewController as? MeshSetupNameDeviceViewController else {
            let nameVC = MeshSetupNameDeviceViewController.storyboardViewController()
            nameVC.setup(didEnterPassword: self.didEnterName, deviceType: self.targetDeviceType)
            self.embededNavigationController.pushViewController(nameVC, animated: true)

            return
        }
    }


    func didEnterName(name: String) {
        self.targetDeviceName = name
        flowManager.setDeviceName(name: name) { error in
            if error == nil {
                //this will happen automatically
            } else if let vc = self.embededNavigationController.topViewController as? MeshSetupNameDeviceViewController {
                vc.setWrongInput()
            }
        }
    }

    func meshSetupDidRequestToAddOneMoreDevice() {
        DispatchQueue.main.async {
            //flowManager.setAddOneMoreDevice(addOneMoreDevice: true)
            let successVC = MeshSetupSuccessViewController.storyboardViewController()
            successVC.setup(didSelectToAddOneMore: self.didSelectToAddOneMore, deviceName: self.targetDeviceName!)
            self.embededNavigationController.pushViewController(successVC, animated: true)
        }
    }

    func didSelectToAddOneMore(add: Bool) {
        flowManager.setAddOneMoreDevice(addOneMoreDevice: add)

        if (add) {
            targetDeviceType = nil
            targetDeviceDataMatrixString = nil
            targetDeviceName = nil

            let getReadyVC = MeshSetupGetReadyViewController.storyboardViewController()
            getReadyVC.setup(didPressReady: targetDeviceReady, deviceType: self.targetDeviceType)
            self.embededNavigationController.setViewControllers([getReadyVC], animated: true)
        } else {
            //setup done
            self.dismiss(animated: true)
        }
    }



    //MARK: Connect to internet
    private func showConnectToInternet() {
//        DispatchQueue.main.async {
//            let joiningVC = MeshSetupJoiningNetworkViewController.storyboardViewController()
//            joiningVC.setup(didFinishScreen: self.didFinishJoinNetworkScreen, networkName: self.selectedNetwork!.name, deviceType: self.targetDeviceType)
//            self.embededNavigationController.pushViewController(joiningVC, animated: true)
//        }
    }


































    func meshSetupDidRequestToFinishSetupEarly() {
        flowManager.setFinishSetupEarly(finish: false)
    }


    func meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: [Particle.MeshSetupNetworkInfo]) {
        flowManager.setSelectOrCreateNetwork(nil)
    }

    func meshSetupDidRequestToEnterNewNetworkNameAndPassword() {
        flowManager.setNewNetwork(name: "fancynetwork", password: "zxcasd")
    }


    func meshSetupDidEnterState(state: MeshSetupFlowState) {
        log("flow setup entered state: \(state)")
        switch state {
            case .TargetDeviceReady:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupPairingProcessViewController {
                    vc.setSuccess()
                } else {
                    //TODO: remove from prod
                    fatalError("why oh why?")
                }
            case .TargetDeviceScanningForNetworks:
                showScanNetworks()
            case .TargetDeviceConnectingToInternet:
                showConnectToInternet()
            case .TargetDeviceConnectedToInternet, .TargetDeviceConnectedToCloud:
                break;
            case .CommissionerDeviceReady:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupPairingCommissionerProcessViewController {
                    vc.setSuccess()
                } else {
                    //TODO: remove from prod
                    fatalError("why oh why?")
                }

            case .JoiningNetworkStarted:
                showJoiningNetwork()
            case .JoiningNetworkStep1Done, .JoiningNetworkStep2Done, .JoiningNetworkCompleted:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupJoiningNetworkViewController {
                    vc.setState(state)
                } else {
                    //TODO: remove from prod
                    fatalError("why oh why?")
                }

            default:
                break;

        }
    }



    func meshSetupError(error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?) {
        switch (error) {
            case .DeviceTooFar:
                showAlert("DeviceTooFar")
            case .DeviceIsNotAllowedToJoinNetwork:
                showAlert("DeviceIsNotAllowedToJoinNetwork")
            case .DeviceIsUnableToFindNetworkToJoin:
                showAlert("DeviceIsUnableToFindNetworkToJoin")
            default:
                showAlert(error.localizedDescription)
        }
    }

    //TODO refactor this
    func showAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                self.flowManager.retryLastAction()
            })

            self.present(alert, animated: true)
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

    @IBAction func cancelTapped(_ sender: Any) {
        self.flowManager.cancelSetup()
        self.dismiss(animated: true)
    }
}
