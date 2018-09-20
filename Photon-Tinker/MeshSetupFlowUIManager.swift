//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation
import UIKit

class MeshSetupFlowUIManager : UIViewController, Storyboardable, MeshSetupFlowManagerDelegate {

    private var flowManager: MeshSetupFlowManager!
    private var embededNavigationController: UINavigationController!

    @IBOutlet weak var accountLabel: MeshLabel!

    private var initialDeviceType: ParticleDeviceType!
    private var initialDeviceDataMatrixString: String!

    private var isInitialDevicePairingScreenDone: Bool = false
    private var isInitialDevicePairingDone: Bool = false



    var selectedNetwork: MeshSetupNetworkInfo?
    var scanInProgress: Bool = false




    override func awakeFromNib() {
        super.awakeFromNib()

        self.flowManager = MeshSetupFlowManager(delegate: self)
        self.flowManager.startSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.accountLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PlaceHolderTextColor)
        self.accountLabel.text = ParticleCloud.sharedInstance().loggedInUsername ?? ""
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedNavigation") {
            self.embededNavigationController = segue.destination as! UINavigationController

            let selectDeviceVC = self.embededNavigationController.viewControllers.first! as! MeshSetupSelectDeviceViewController
            selectDeviceVC.setup(didSelectDevice: initialDeviceSelected)
        }
        super.prepare(for: segue, sender: sender)
    }


    private func log(_ message: String) {
        if (MeshSetup.LogUIManager) {
            NSLog("MeshSetupFlowUI: \(message)")
        }
    }


    //MARK: Get Initial Device Info
    var setInitialDeviceInfoCallback: MeshSetupSetString!
    func meshSetupDidRequestInitialDeviceInfo(setInitialDeviceInfo: @escaping MeshSetupSetString) {
        self.setInitialDeviceInfoCallback = setInitialDeviceInfo
    }

    func initialDeviceSelected(type: ParticleDeviceType) {
        log("initial device type selected: \(type)")
        self.initialDeviceType = type

        let getReadyVC = MeshSetupGetReadyViewController.storyboardViewController()
        getReadyVC.setup(didPressReady: initialDeviceReady, deviceType: self.initialDeviceType)
        self.embededNavigationController.pushViewController(getReadyVC, animated: true)
    }

    func initialDeviceReady() {
        log("initial device ready")

        let findStickerVC = MeshSetupFindStickerViewController.storyboardViewController()
        findStickerVC.setup(didPressScan: initialDeviceStickerFound, deviceType: self.initialDeviceType)
        self.embededNavigationController.pushViewController(findStickerVC, animated: true)
    }

    func initialDeviceStickerFound() {
        log("sticker found by user")

        let scanVC = MeshSetupScanStickerViewController.storyboardViewController()
        scanVC.setup(didFindStickerCode: initialDeviceCodeFound, deviceType: self.initialDeviceType)
        self.embededNavigationController.pushViewController(scanVC, animated: true)
    }

    //user successfully scanned initial code
    func initialDeviceCodeFound(dataMatrixString: String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        self.initialDeviceDataMatrixString = dataMatrixString

        //make sure the scanned device is of the same type as user requested in the first screen
        if let matrix = self.flowManager.validateDataMatrix(self.initialDeviceDataMatrixString),
           let type = self.flowManager.getDeviceType(serialNumber: matrix.serialNumber),
           type == self.initialDeviceType {

            setInitialDeviceInfoCallback?(self.initialDeviceDataMatrixString)

            let pairingVC = MeshSetupPairingProcessViewController.storyboardViewController()
            pairingVC.setup(didFinishScreen: initialDevicePairingScreenDone, deviceType: self.initialDeviceType, deviceName: flowManager.initialDeviceName() ?? self.initialDeviceType.description)
            self.embededNavigationController.pushViewController(pairingVC, animated: true)
        } else {
            if let vc = self.embededNavigationController.topViewController as? MeshSetupScanStickerViewController {
                vc.restartCaptureSession()
            } else {
                //TODO: problem?
            }
        }
    }

    func initialDevicePairingScreenDone() {
        isInitialDevicePairingScreenDone = true

        evalContinue()
    }




    //MARK: Complete preflow, artifial pause for UI to catch up.
    private var continueFlowCallback:MeshSetupSetVoid?
    func meshSetupDidPairWithInitialDevice(continueFlow: @escaping MeshSetupSetVoid) {
        continueFlowCallback = continueFlow
        isInitialDevicePairingDone = true

        evalContinue()
    }


    //we need this because the check mark has to be visible for at least 2s
    private func evalContinue() {
        if (isInitialDevicePairingScreenDone == true && isInitialDevicePairingDone == true) {
            continueFlowCallback?()
            continueFlowCallback = nil
        }

        //the next thing to happen will be one out of 3:
        // 1)meshSetupDidRequestToLeaveNetwork callback
        // 2)meshSetupDidEnterState: InitialDeviceScanningForNetworks
        // 3)meshSetupDidEnterState: InitialDeviceConnectingToInternet
    }







    //MARK: Leave existing network
    //TODO: For spectra we simply leave the current network. No hard feelings
    //var setLeaveNetworkCallback: MeshSetupSetBool?
    func meshSetupDidRequestToLeaveNetwork(network: Particle.MeshSetupNetworkInfo, setLeaveNetwork: @escaping MeshSetupSetBool) {
        //self.setLeaveNetworkCallback = setLeaveNetwork
        setLeaveNetwork(true)
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
            setSelectedNetworkCallback!(selectedNetwork!)
        }
    }


    var setSelectedNetworkCallback: MeshSetupSetNetwork?
    func meshSetupDidRequestToSelectNetwork(availableNetworks: [Particle.MeshSetupNetworkInfo], setSelectedNetwork: @escaping MeshSetupSetNetwork) {
        setSelectedNetworkCallback = setSelectedNetwork

        if (availableNetworks.count == 0) {
            if (!flowManager.rescanNetworks()) {
                //TODO: remove for prod
                fatalError("something is horribly wrong here 1")
            }

            if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
                vc.setNetworks(networks: [])
                vc.startScanning()
            }
        } else {
            NSLog("scan complete")
            self.scanInProgress = false

            //if by the time this returned, user has already selected the network, ignore the results of last scan
            if let selectedNetwork = self.selectedNetwork {
                setSelectedNetworkCallback!(selectedNetwork)
                return
            } else if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
                vc.setNetworks(networks: availableNetworks)
            }

            //rescan in 3seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                [weak self] in
                //only rescan if user hasn't made choice by now

                if self != nil, self!.selectedNetwork == nil {
                    self!.scanInProgress = true
                    let success = self!.flowManager.rescanNetworks()

                    if let vc = self!.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
                        vc.startScanning()
                    }

                    if (success == false) {
                        //TODO: remove for prod
                        fatalError("something is horribly wrong here 2")
                    }
                }
            }
        }
    }






    //MARK: Connect to selected network
    var setCommissionerDeviceInfoCallback: MeshSetupSetString?
    func meshSetupDidRequestCommissionerDeviceInfo(setCommissionerDeviceInfo: @escaping MeshSetupSetString) {
        self.setCommissionerDeviceInfoCallback = setCommissionerDeviceInfo

        NSLog("requesting commisioner info!!")

        DispatchQueue.main.async {
            let getReadyVC = MeshSetupGetCommissionerReadyViewController.storyboardViewController()
            getReadyVC.setup(didPressReady: self.commissionerDeviceReady, deviceType: self.initialDeviceType, networkName: self.selectedNetwork!.name)
            self.embededNavigationController.pushViewController(getReadyVC, animated: true)
        }
    }

    func commissionerDeviceReady() {
        log("commissioner device ready")

        let findStickerVC = MeshSetupFindCommissionerStickerViewController.storyboardViewController()
        findStickerVC.setup(didPressScan: commissionerDeviceStickerFound, deviceType: self.initialDeviceType, networkName: self.selectedNetwork!.name)
        self.embededNavigationController.pushViewController(findStickerVC, animated: true)
    }

    func commissionerDeviceStickerFound() {
        log("sticker found by user")

//        let scanVC = MeshSetupScanStickerViewController.storyboardViewController()
//        scanVC.setup(didFindStickerCode: initialDeviceCodeFound, deviceType: self.initialDeviceType)
//        self.embededNavigationController.pushViewController(scanVC, animated: true)
    }







    //MARK: Connect to internet
    private func showConnectToInternet() {

    }















    //user successfully scanned initial code
    func commissionerStickerCodeFound(dataMatrixString: String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        self.initialDeviceDataMatrixString = dataMatrixString
        setCommissionerDeviceInfoCallback?(self.initialDeviceDataMatrixString)
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


    func meshSetupDidEnterState(state: MeshSetupFlowState) {
        log("flow setup entered state: \(state)")
        switch state {
            case .InitialDeviceReady:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupPairingProcessViewController {
                    vc.setSuccess()
                } else {
                    //TODO: remove from prod
                    fatalError("why oh why?")
                }
            case .InitialDeviceScanningForNetworks:
                showScanNetworks()
            case .InitialDeviceConnectingToInternet:
                showConnectToInternet()
            case .InitialDeviceConnectedToInternet, .InitialDeviceConnectedToCloud:
                break;
            default:
                break;

        }
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

    @IBAction func cancelTapped(_ sender: Any) {
        self.flowManager.cancelSetup()
        self.dismiss(animated: true)
    }
}
