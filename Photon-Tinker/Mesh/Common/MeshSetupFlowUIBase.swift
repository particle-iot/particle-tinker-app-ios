//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright © 2018 Particle. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import MessageUI

class MeshSetupUIBase : UIViewController, Storyboardable, MeshSetupFlowRunnerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, STPAddCardViewControllerDelegate {

    static var storyboardName: String {
        return "MeshSetup"
    }

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonImage: UIImageView!

    @IBOutlet weak var navigationBarTitle: ParticleLabel!

    internal var flowRunner: MeshSetupFlowRunner!
    internal var embededNavigationController: UINavigationController!

    internal var targetDeviceDataMatrix: MeshSetupDataMatrix?

    internal var alert: UIAlertController?
    internal var lockAlert: Bool = false //when critical alert is shown, this is set to true

    internal var currentStepType: MeshSetupStep.Type?
    {
        didSet {
            self.log("Switching currentStepType: \(currentStepType)")
        }
    }

    internal func log(_ message: String) {
        ParticleLogger.logInfo("MeshSetupFlowUI", format: message, withParameters: getVaList([]))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(isBusyChanged), name: Notification.Name.MeshSetupViewControllerBusyChanged, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        UIApplication.shared.isIdleTimerDisabled = false
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedNavigation") {
            self.embededNavigationController = segue.destination as! UINavigationController
            self.embededNavigationController.delegate = self

            self.setupInitialViewController()
        }
        super.prepare(for: segue, sender: sender)
    }

    //MARK: Helpers
    internal func setupInitialViewController() {
        fatalError("not implemented")
    }

    internal func rewindTo<T>(_ vcType: T.Type) -> Bool {
        //rewinding
        for vc in self.embededNavigationController.viewControllers {
            if type(of: vc) == vcType.self {
                (vc as! MeshSetupViewController).resume(animated: false)
                log("Rewinding to: \(vc)")
                if (vc != self.embededNavigationController.topViewController!) {
                    self.embededNavigationController.popToViewController(vc, animated: true)
                }
                return true
            }
        }
        return false
    }

    internal func hideAlertIfVisible() -> Bool {
        if (self.lockAlert) {
            return false
        }

        if (alert?.viewIfLoaded?.window != nil) {
            alert!.dismiss(animated: false)
            return true
        } else {
            return true
        }
    }

    //MARK: Validate & recover data Matrix
    internal func validateMatrix(_ dataMatrixString: String, targetDevice: Bool, deviceType: ParticleDeviceType? = nil) {
        if let matrix = MeshSetupDataMatrix(dataMatrixString: dataMatrixString, deviceType: deviceType) {
            if (matrix.type != nil && matrix.isMobileSecretValid()) {
                if (targetDevice) {
                    self.setTargetDeviceValidatedMatrix(dataMatrix: matrix)
                } else {
                    self.setCommissionerDeviceValidatedMatrix(dataMatrix: matrix)
                }
            } else if (matrix.type == nil) {
                self.log("Attempting to recover unknown device type")
                recoverUnknownDeviceType(matrix: matrix, targetDevice: targetDevice)
            } else {
                self.log("Attempting to recover incomplete mobile secret")
                recoverIncompleteMobileSecret(matrix: matrix, targetDevice: targetDevice)
            }
        } else {
            showWrongMatrixError(targetDevice: targetDevice)
        }
    }

    internal func recoverUnknownDeviceType(matrix: MeshSetupDataMatrix, targetDevice: Bool) {
        ParticleCloud.sharedInstance().getPlatformId(matrix.serialNumber) { platformId, error in
            if let platformId = platformId, let type = ParticleDeviceType(rawValue: Int(platformId)) {
                self.validateMatrix(matrix.matrixString, targetDevice: targetDevice, deviceType: type)
            } else if let nserror = error as? NSError, nserror.code == 404 {
                self.showWrongMatrixError(targetDevice: targetDevice)
            } else {
                DispatchQueue.main.async {
                    if (self.hideAlertIfVisible()) {
                        self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: MeshSetupFlowError.NetworkError.description, preferredStyle: .alert)

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.CancelSetup, style: .cancel) { action in
                            self.cancelTapped(self)
                        })

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                            self.validateMatrix(matrix.matrixString, targetDevice: targetDevice, deviceType: matrix.type)
                        })

                        self.present(self.alert!, animated: true)
                    }
                }
            }
        }
    }

    internal func recoverIncompleteMobileSecret(matrix: MeshSetupDataMatrix, targetDevice: Bool) {
        ParticleCloud.sharedInstance().getRecoveryMobileSecret(matrix.serialNumber, mobileSecret: matrix.mobileSecret) { mobileSecret, error in
            if let mobileSecret = mobileSecret {
                self.validateMatrix("\(matrix.serialNumber) \(mobileSecret)", targetDevice: targetDevice)
            } else if let nserror = error as? NSError, nserror.code == 200 {
                self.showFailedMatrixRecoveryError(dataMatrix: matrix)
            } else {
                DispatchQueue.main.async {
                    if (self.hideAlertIfVisible()) {
                        self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: MeshSetupFlowError.NetworkError.description, preferredStyle: .alert)

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.CancelSetup, style: .cancel) { action in
                            self.cancelTapped(self)
                        })

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                            self.validateMatrix(matrix.matrixString, targetDevice: targetDevice, deviceType: matrix.type)
                        })

                        self.present(self.alert!, animated: true)
                    }
                }
            }
        }
    }

    internal func showWrongMatrixError(targetDevice: Bool) {
        //show error where selected device type mismatch
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle,
                        message: targetDevice ? MeshSetupFlowError.WrongTargetDeviceType.description : MeshSetupFlowError.WrongCommissionerDeviceType.description,
                        preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
                    self.restartCaptureSession()
                })

                self.present(self.alert!, animated: true)
            }
        }
    }

    internal func showFailedMatrixRecoveryError(dataMatrix: MeshSetupDataMatrix) {
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: MeshSetupFlowError.StickerError.description, preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.CancelSetup, style: .cancel) { action in
                    self.restartCaptureSession()
                })

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.ContactSupport, style: .default) { action in
                    self.openEmailClient(dataMatrix: dataMatrix)
                    self.restartCaptureSession()
                })

                self.present(self.alert!, animated: true)
            }
        }
    }

    internal func openEmailClient(dataMatrix: MeshSetupDataMatrix) {
        if !MFMailComposeViewController.canSendMail() {
            self.log("Mail services are not available")
            return
        }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self

        composeVC.setToRecipients(["hello@particle.io"])
        composeVC.setSubject("3rd generation sticker problem")
        composeVC.setMessageBody("""
                                 -- BEFORE SENDING Please attach a picture of the device sticker! --

                                 Hi Particle! My sticker barcode has an issue.

                                 Serial number: \(dataMatrix.serialNumber)
                                 Full scan results: \(dataMatrix.serialNumber) \(dataMatrix.mobileSecret)
                                 """, isHTML: false)

        self.present(composeVC, animated: true)
    }

    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    internal func restartCaptureSession() {
        if let vc = self.embededNavigationController.topViewController as? MeshSetupScanCommissionerStickerViewController {
            vc.resume(animated: true)
        } else if let vc = self.embededNavigationController.topViewController as? MeshSetupScanStickerViewController {
            vc.resume(animated: true)
        } else {
            self.log("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupScanCommissionerStickerViewController / MeshSetupScanStickerViewController.restartCaptureSession was attempted when it shouldn't be")
        }
    }

    internal func setTargetDeviceValidatedMatrix(dataMatrix: MeshSetupDataMatrix) {
        fatalError("not implemented")
    }


    internal func meshSetupDidRequestTargetDeviceInfo(_ sender: MeshSetupStep) {
        fatalError("not implemented")
    }

    func meshSetupDidRequestToSelectSimDataLimit(_ sender: MeshSetupStep) {
        fatalError("not implemented")
    }

    func meshSetupDidRequestToSelectSimStatus(_ sender: MeshSetupStep) {
        fatalError("not implemented")
    }

    internal func meshSetupDidRequestToSelectEthernetStatus(_ sender: MeshSetupStep) {
        fatalError("not implemented")
    }

    internal func meshSetupDidRequestToLeaveNetwork(_ sender: MeshSetupStep, network: MeshSetupNetworkInfo) {
        fatalError("not implemented")
    }

    internal func meshSetupDidRequestToSwitchToControlPanel(_ sender: MeshSetupStep, device: ParticleDevice) {
        fatalError("not implemented")
    }

    internal func meshSetupDidRequestToSelectStandAloneOrMeshSetup(_ sender: MeshSetupStep) {
        fatalError("not implemented")
    }

    internal func meshSetupDidRequestToShowInfo(_ sender: MeshSetupStep) {
        fatalError("not implemented")
    }

    internal func meshSetupDidRequestToAddOneMoreDevice(_ sender: MeshSetupStep) {
        fatalError("not implemented")
    }

    internal func meshSetupDidCompleteControlPanelFlow(_ sender: MeshSetupStep) {
        fatalError("not implemented")
    }


    //MARK: Pairing
    func showTargetPairingProcessView() {
        self.flowRunner.pauseSetup()
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupPairingProcessViewController.self)) {
                let pairingVC = MeshSetupPairingProcessViewController.loadedViewController()
                pairingVC.allowBack = false
                pairingVC.ownerStepType = self.currentStepType
                pairingVC.setup(didFinishScreen: self.targetPairingProcessViewCompleted, deviceType: self.flowRunner.context.targetDevice.type, deviceName: self.flowRunner.context.targetDevice.bluetoothName ?? self.flowRunner.context.targetDevice.type!.description)
                self.embededNavigationController.pushViewController(pairingVC, animated: true)
            }
        }
    }

    func targetPairingProcessViewCompleted() {
        self.flowRunner.continueSetup()
    }



    //MARK: Firmware update
    internal func meshSetupDidRequestToUpdateFirmware(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)

        self.showFirmwareUpdateView()
    }

    internal func showFirmwareUpdateView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupFirmwareUpdateViewController.self)) {
                let prepareUpdateFirmwareVC = MeshSetupFirmwareUpdateViewController.loadedViewController()
                prepareUpdateFirmwareVC.setup(didPressContinue: self.firmwareUpdateViewCompleted)
                prepareUpdateFirmwareVC.ownerStepType = self.currentStepType
                prepareUpdateFirmwareVC.allowBack = false
                self.embededNavigationController.pushViewController(prepareUpdateFirmwareVC, animated: true)
            }
        }
    }

    internal func firmwareUpdateViewCompleted() {
        self.flowRunner.setTargetPerformFirmwareUpdate(update: true)

        self.showFirmwareUpdateProgressView()
    }

    internal func showFirmwareUpdateProgressView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupFirmwareUpdateProgressViewController.self)) {
                let updateFirmwareVC = MeshSetupFirmwareUpdateProgressViewController.loadedViewController()
                updateFirmwareVC.setup(didFinishScreen: self.firmwareUpdateProgressViewCompleted)
                updateFirmwareVC.allowBack = false
                updateFirmwareVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(updateFirmwareVC, animated: true)
            }
        }
    }

    internal func firmwareUpdateProgressViewCompleted() {
        self.flowRunner.continueSetup()
    }



    //MARK: Device info
    internal func meshSetupDidRequestToEnterDeviceName(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)

        showNameDeviceView()
    }

    internal func showNameDeviceView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupNameDeviceViewController.self)) {
                let nameVC = MeshSetupNameDeviceViewController.loadedViewController()
                nameVC.allowBack = false
                nameVC.ownerStepType = self.currentStepType
                nameVC.setup(didEnterName: self.nameDeviceViewCompleted, deviceType: self.flowRunner.context.targetDevice.type, currentName: self.flowRunner.context.targetDevice.name)
                self.embededNavigationController.pushViewController(nameVC, animated: true)
            }
        }
    }

    internal func nameDeviceViewCompleted(name: String) {
        flowRunner.setDeviceName(name: name) { error in
            if error != nil, let vc = self.embededNavigationController.topViewController as? MeshSetupNameDeviceViewController {
                vc.setWrongInput(message: error!.description)
            }
        }
    }






    //MARK: Pricing info
    internal func meshSetupDidRequestToShowPricingInfo(_ sender: MeshSetupStep, info: ParticlePricingInfo) {
        currentStepType = type(of: sender)

        showPricingInfoView(info: info)
    }

    internal func showPricingInfoView(info: ParticlePricingInfo) {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupPricingInfoViewController.self)) {
                let pricingInfoVC = MeshSetupPricingInfoViewController.loadedViewController()
                pricingInfoVC.ownerStepType = self.currentStepType
                pricingInfoVC.setup(didPressContinue: self.pricingInfoViewCompleted, pricingInfo: info)
                self.embededNavigationController.pushViewController(pricingInfoVC, animated: true)
            }
        }
    }

    internal func pricingInfoViewCompleted() {
        if let error = self.flowRunner.setPricingImpactDone() {
            DispatchQueue.main.async {
                STPTheme.default().emphasisFont = UIFont(name: ParticleStyle.BoldFont, size: CGFloat(ParticleStyle.RegularSize))
                STPTheme.default().font = UIFont(name: ParticleStyle.RegularFont, size: CGFloat(ParticleStyle.RegularSize))
                STPTheme.default().errorColor = ParticleStyle.RedTextColor
                STPTheme.default().accentColor = ParticleStyle.ButtonColor
                STPTheme.default().primaryForegroundColor = ParticleStyle.PrimaryTextColor
                STPTheme.default().secondaryForegroundColor = ParticleStyle.SecondaryTextColor
                STPTheme.default().primaryBackgroundColor = ParticleStyle.TableViewBackgroundColor

                let addCardViewController = STPAddCardViewController()

                let navigationController = UINavigationController(rootViewController: addCardViewController)
                navigationController.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.font: UIFont(name: ParticleStyle.BoldFont, size: CGFloat(ParticleStyle.RegularSize)),
                    NSAttributedString.Key.foregroundColor: ParticleStyle.PrimaryTextColor
                ]

                self.present(navigationController, animated: true)
            }
        }
    }

    //MARK: Collect CC Delegate
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.rewindTo(MeshSetupPricingInfoViewController.self)
        addCardViewController.navigationController!.dismiss(animated:true)
    }

    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        ParticleCloud.sharedInstance().addCard(token.tokenId) { error in
            if (error == nil) {
                completion(nil)

                self.flowRunner.retryLastAction()
                addCardViewController.navigationController!.dismiss(animated:true)
            } else {
                completion(error)
            }
        }
    }



    //MARK: Scan WIFI networks
    internal func showSelectWifiNetworkView() {
        DispatchQueue.main.async {
            if let _ = self.embededNavigationController.topViewController as? MeshSetupSelectWifiNetworkViewController {
                //do nothing
            } else {
                if (!self.rewindTo(MeshSetupSelectWifiNetworkViewController.self)) {
                    let networksVC = MeshSetupSelectWifiNetworkViewController.loadedViewController()
                    networksVC.ownerStepType = self.currentStepType
                    networksVC.setup(didSelectNetwork: self.selectWifiNetworkViewCompleted)
                    self.embededNavigationController.pushViewController(networksVC, animated: true)
                }
            }
        }
    }

    internal func selectWifiNetworkViewCompleted(network: MeshSetupNewWifiNetworkInfo) {
        flowRunner.setSelectedWifiNetwork(selectedNetwork: network)
    }

    internal func meshSetupDidRequestToSelectWifiNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNewWifiNetworkInfo]) {
        self.log("scan complete")

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectWifiNetworkViewController {
            currentStepType = type(of: sender)
            vc.setNetworks(networks: availableNetworks)

            //if no networks found = force instant rescan
            if (availableNetworks.count == 0) {
                rescanWifiNetworks()
            } else {
                //rescan in 3seconds
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    [weak self] in
                    //only rescan if user hasn't made choice by now
                    self?.rescanWifiNetworks()
                }
            }
        }
    }

    internal func rescanWifiNetworks() {
        if self.flowRunner.context.selectedWifiNetworkInfo == nil {
            if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectWifiNetworkViewController {
                if (flowRunner.rescanNetworks() == nil) {
                    vc.startScanning()
                } else {
                    self.log("rescanNetworks was attempted when it shouldn't be")
                }
            }
        }
    }




    //MARK: Wifi network password
    internal func meshSetupDidRequestToEnterSelectedWifiNetworkPassword(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)

        showWifiNetworkPasswordView()
    }

    internal func showWifiNetworkPasswordView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupWifiNetworkPasswordViewController.self)) {
                let passwordVC = MeshSetupWifiNetworkPasswordViewController.loadedViewController()
                passwordVC.ownerStepType = self.currentStepType
                passwordVC.setup(didEnterPassword: self.wifiNetworkPasswordViewCompleted, networkName: self.flowRunner.context.selectedWifiNetworkInfo!.ssid)
                self.embededNavigationController.pushViewController(passwordVC, animated: true)
            }
        }
    }

    internal func wifiNetworkPasswordViewCompleted(password: String) {
        flowRunner.setSelectedWifiNetworkPassword(password) { error in
            if error != nil, let vc = self.embededNavigationController.topViewController as? MeshSetupWifiNetworkPasswordViewController {
                vc.setWrongInput(message: error!.description)
            }
        }
    }







    //MARK: Scan networks
    internal func showSelectNetworkView() {
        DispatchQueue.main.async {
            if let _ = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
                //do nothing
            } else {
                if (!self.rewindTo(MeshSetupSelectNetworkViewController.self)) {
                    let networksVC = MeshSetupSelectNetworkViewController.loadedViewController()
                    networksVC.ownerStepType = self.currentStepType
                    networksVC.setup(didSelectNetwork: self.selectNetworkViewCompleted)
                    self.embededNavigationController.pushViewController(networksVC, animated: true)
                }
            }
        }
    }

    internal func showSelectOrCreateNetworkView() {
        DispatchQueue.main.async {
            if let _ = self.embededNavigationController.topViewController as? MeshSetupSelectOrCreateNetworkViewController {
                //do nothing
            } else {
                if (!self.rewindTo(MeshSetupSelectOrCreateNetworkViewController.self)) {
                    let networksVC = MeshSetupSelectOrCreateNetworkViewController.loadedViewController()
                    networksVC.ownerStepType = self.currentStepType
                    networksVC.setup(didSelectNetwork: self.selectOrCreateNetworkViewCompleted)
                    self.embededNavigationController.pushViewController(networksVC, animated: true)
                }
            }
        }
    }

    internal func selectNetworkViewCompleted(network: MeshSetupNetworkCellInfo?) {
        guard network != nil else {
            log("Selected empty network for joiner flow")
            return
        }

        flowRunner.setSelectedNetwork(selectedNetworkExtPanID: network!.extPanID)
    }


    internal func selectOrCreateNetworkViewCompleted(network: MeshSetupNetworkCellInfo?) {
        flowRunner.setOptionalSelectedNetwork(selectedNetworkExtPanID: network?.extPanID)
    }


    internal func meshSetupDidRequestToSelectNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNetworkCellInfo]) {
        self.log("scan complete")

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
            currentStepType = type(of: sender)
            vc.setNetworks(networks: availableNetworks)

            //if no networks found = force instant rescan
            if (availableNetworks.count == 0) {
                rescanNetworks()
            } else {
                //rescan in 3seconds
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    [weak self] in
                    //only rescan if user hasn't made choice by now
                    self?.rescanNetworks()
                }
            }
        }
    }


    internal func meshSetupDidRequestToSelectOrCreateNetwork(_ sender: MeshSetupStep, availableNetworks: [MeshSetupNetworkCellInfo]) {
        self.log("scan complete")

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectOrCreateNetworkViewController {
            currentStepType = type(of: sender)
            vc.setNetworks(networks: availableNetworks)

            //if no networks found = force instant rescan
            if (availableNetworks.count == 0) {
                rescanNetworks()
            } else {
                //rescan in 3seconds
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    [weak self] in
                    //only rescan if user hasn't made choice by now
                    self?.rescanNetworks()
                }
            }
        }
    }


    internal func rescanNetworks() {
        if self.flowRunner.context.selectedNetworkMeshInfo == nil {
            if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
                if (flowRunner.rescanNetworks() == nil) {
                    vc.startScanning()
                } else {
                    self.log("rescanNetworks was attempted when it shouldn't be")
                }
            } else if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectOrCreateNetworkViewController, self.flowRunner.context.userSelectedToCreateNetwork == nil {
                if (flowRunner.rescanNetworks() == nil) {
                    vc.startScanning()
                } else {
                    self.log("rescanNetworks was attempted when it shouldn't be")
                }
            }
        }
    }





    //MARK: Connect to selected network
    internal func meshSetupDidRequestCommissionerDeviceInfo(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)
        log("requesting commisioner info!!")

        showGetCommissionerReadyView()
    }

    private func showGetCommissionerReadyView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupScanCommissionerStickerViewController.self)) {
                let getReadyVC = MeshSetupGetCommissionerReadyViewController.loadedViewController()
                getReadyVC.ownerStepType = self.currentStepType
                getReadyVC.setup(didPressReady: self.getCommissionerReadyViewCompleted, deviceType: self.flowRunner.context.targetDevice.type, networkName: self.flowRunner.context.selectedNetworkMeshInfo!.name)
                self.embededNavigationController.pushViewController(getReadyVC, animated: true)
            }
        }
    }


    internal func getCommissionerReadyViewCompleted() {
        log("commissioner device ready")

        showFindCommissionerStickerView()
    }

    private func showFindCommissionerStickerView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupFindCommissionerStickerViewController.self)) {
                let findStickerVC = MeshSetupFindCommissionerStickerViewController.loadedViewController()
                findStickerVC.setup(didPressScan: self.findCommissionerStickerViewCompleted, networkName: self.flowRunner.context.selectedNetworkMeshInfo!.name)
                findStickerVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(findStickerVC, animated: true)
            }
        }
    }

    internal func findCommissionerStickerViewCompleted() {
        log("sticker found by user")

        showScanCommissionerStickerView()
    }

    private func showScanCommissionerStickerView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupScanCommissionerStickerViewController.self)) {
                let scanVC = MeshSetupScanCommissionerStickerViewController.loadedViewController()
                scanVC.setup(didFindStickerCode: self.scanCommissionerStickerViewCompleted)
                scanVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(scanVC, animated: true)
            }
        }
    }
    

    internal func scanCommissionerStickerViewCompleted(dataMatrixString:String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        self.validateMatrix(dataMatrixString, targetDevice: false)
    }
    
    internal func setCommissionerDeviceValidatedMatrix(dataMatrix: MeshSetupDataMatrix) {
        //make sure the scanned device is of the same type as user requested in the first screen
        if let deviceType = dataMatrix.type {

            if let error = flowRunner.setCommissionerDeviceInfo(dataMatrix: dataMatrix) {
                DispatchQueue.main.async {
                    if (self.hideAlertIfVisible()) {
                        self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: error.description, preferredStyle: .alert)

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
                            self.restartCaptureSession()
                        })

                        self.present(self.alert!, animated: true)
                    }
                }
            } else {
                self.flowRunner.pauseSetup()

                showPairingCommissionerProcessView(deviceType: deviceType)
            }
        } else {
            restartCaptureSession()
        }
    }

    private func showPairingCommissionerProcessView(deviceType: ParticleDeviceType) {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupPairingCommissionerProcessViewController.self)) {
                let pairingVC = MeshSetupPairingCommissionerProcessViewController.loadedViewController()
                pairingVC.setup(didFinishScreen: self.pairingCommissionerProcessViewCompleted, deviceType: self.flowRunner.context.commissionerDevice?.type, deviceName: self.flowRunner.context.commissionerDevice?.bluetoothName ?? deviceType.description)
                pairingVC.ownerStepType = self.currentStepType
                pairingVC.allowBack = false
                self.embededNavigationController.pushViewController(pairingVC, animated: true)
            }
        }
    }

    internal func pairingCommissionerProcessViewCompleted() {
        self.flowRunner.continueSetup()
    }






    //MARK: Join network
    internal func meshSetupDidRequestToEnterSelectedNetworkPassword(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)

        showNetworkPasswordView()
    }

    private func showNetworkPasswordView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupNetworkPasswordViewController.self)) {
                let passwordVC = MeshSetupNetworkPasswordViewController.loadedViewController()
                passwordVC.allowBack = false
                passwordVC.ownerStepType = self.currentStepType
                passwordVC.setup(didEnterPassword: self.networkPasswordViewCompleted, networkName: self.flowRunner.context.selectedNetworkMeshInfo!.name)
                self.embededNavigationController.pushViewController(passwordVC, animated: true)
            }
        }
    }

    internal func networkPasswordViewCompleted(password: String) {
        flowRunner.setSelectedNetworkPassword(password) { error in
            if error == nil {
                self.showJoiningNetworkView()
            } else if let vc = self.embededNavigationController.topViewController as? MeshSetupNetworkPasswordViewController {
                vc.setWrongInput(message: error!.description)
            }
        }
    }

    internal func showJoiningNetworkView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupJoiningNetworkViewController.self)) {
                let joiningVC = MeshSetupJoiningNetworkViewController.loadedViewController()
                joiningVC.allowBack = false
                joiningVC.ownerStepType = self.currentStepType
                joiningVC.setup(didFinishScreen: self.joiningNetworkViewCompleted, networkName: self.flowRunner.context.selectedNetworkMeshInfo!.name, deviceType: self.flowRunner.context.targetDevice.type)
                self.embededNavigationController.pushViewController(joiningVC, animated: true)
            }
        }
    }


    internal func joiningNetworkViewCompleted() {
        self.flowRunner.continueSetup()
    }








    //MARK: Connecting to internet
    internal func showConnectingToInternetView() {
        switch self.flowRunner.context.targetDevice.activeInternetInterface! {
            case .ethernet:
                DispatchQueue.main.async {
                    if let vc = self.embededNavigationController.topViewController as? MeshSetupConnectingToInternetEthernetViewController {
                        vc.setState(.TargetDeviceConnectingToInternetStarted)
                    } else {
                        if (!self.rewindTo(MeshSetupConnectingToInternetEthernetViewController.self)) {
                            let connectingVC = MeshSetupConnectingToInternetEthernetViewController.loadedViewController()
                            connectingVC.allowBack = false
                            connectingVC.ownerStepType = self.currentStepType
                            connectingVC.setup(didFinishScreen: self.connectingToInternetViewCompleted, deviceType: self.flowRunner.context.targetDevice.type)
                            self.embededNavigationController.pushViewController(connectingVC, animated: true)
                        }
                    }
                }
            case .wifi:
                DispatchQueue.main.async {
                    if let vc = self.embededNavigationController.topViewController as? MeshSetupConnectingToInternetWifiViewController {
                        vc.setState(.TargetDeviceConnectingToInternetStarted)
                    } else {
                        if (!self.rewindTo(MeshSetupConnectingToInternetWifiViewController.self)) {
                            let connectingVC = MeshSetupConnectingToInternetWifiViewController.loadedViewController()
                            connectingVC.allowBack = false
                            connectingVC.ownerStepType = self.currentStepType
                            connectingVC.setup(didFinishScreen: self.connectingToInternetViewCompleted, deviceType: self.flowRunner.context.targetDevice.type)
                            self.embededNavigationController.pushViewController(connectingVC, animated: true)
                        }
                    }
                }
            case .ppp:
                DispatchQueue.main.async {
                    if let vc = self.embededNavigationController.topViewController as? MeshSetupConnectingToInternetCellularViewController {
                        vc.setState(.TargetDeviceConnectingToInternetStarted)
                    } else {
                        if (!self.rewindTo(MeshSetupConnectingToInternetCellularViewController.self)) {
                            let connectingVC = MeshSetupConnectingToInternetCellularViewController.loadedViewController()
                            connectingVC.allowBack = false
                            connectingVC.ownerStepType = self.currentStepType
                            connectingVC.setup(didFinishScreen: self.connectingToInternetViewCompleted, deviceType: self.flowRunner.context.targetDevice.type)
                            self.embededNavigationController.pushViewController(connectingVC, animated: true)
                        }
                    }
                }
            default:
                //others are not interesting
                break
        }
    }

    internal func connectingToInternetViewCompleted() {
        self.flowRunner.continueSetup()
    }





    //MARK: Create network
    internal func meshSetupDidRequestToEnterNewNetworkName(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)

        showCreateNetworkNameView()
    }

    internal func showCreateNetworkNameView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupCreateNetworkNameViewController.self)) {
                let networkNameVC = MeshSetupCreateNetworkNameViewController.loadedViewController()
                networkNameVC.setup(didEnterNetworkName: self.createNetworkNameCompleted)
                networkNameVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(networkNameVC, animated: true)
            }
        }
    }

    internal func createNetworkNameCompleted(networkName: String) {
        if let error = self.flowRunner.setNewNetworkName(name: networkName),
           let vc = self.embededNavigationController.topViewController as? MeshSetupCreateNetworkNameViewController {
            vc.setWrongInput(message: error.description)
        } else {
            showCreateNetworkPasswordView()
        }
    }

    internal func meshSetupDidRequestToEnterNewNetworkPassword(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)

        showCreateNetworkPasswordView()
    }

    internal func showCreateNetworkPasswordView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupCreateNetworkPasswordViewController.self)) {
                let networkPasswordVC = MeshSetupCreateNetworkPasswordViewController.loadedViewController()
                networkPasswordVC.setup(didEnterNetworkPassword: self.createNetworkPasswordViewCompleted)
                networkPasswordVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(networkPasswordVC, animated: true)
            }
        }
    }

    internal func createNetworkPasswordViewCompleted(networkPassword: String) {
        if let error = self.flowRunner.setNewNetworkPassword(password: networkPassword),
           let vc = self.embededNavigationController.topViewController as? MeshSetupCreateNetworkPasswordViewController{
            vc.setWrongInput(message: error.description)
        } else {
            showCreatingNetworkView()
        }
    }


    internal func showCreatingNetworkView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupCreatingNetworkViewController.self)) {
                let createNetworkVC = MeshSetupCreatingNetworkViewController.loadedViewController()
                createNetworkVC.allowBack = false
                createNetworkVC.ownerStepType = self.currentStepType
                createNetworkVC.setup(didFinishScreen: self.creatingNetworkViewCompleted, deviceType: self.flowRunner.context.targetDevice.type, deviceName: self.flowRunner.context.targetDevice.name)
                self.embededNavigationController.pushViewController(createNetworkVC, animated: true)
            }
        }
    }

    internal func meshSetupDidCreateNetwork(_ sender: MeshSetupStep, network: MeshSetupNetworkCellInfo) {
        currentStepType = type(of: sender)

        //nothing needs to be done on ui side
    }

    internal func creatingNetworkViewCompleted() {
        self.flowRunner.continueSetup()

        // simply do nothing. screen will be exited automatically
    }



    internal func meshSetupDidEnterState(_ sender: MeshSetupStep, state: MeshSetupFlowState) {
        log("flow setup entered state: \(state)")
        switch state {
            case .TargetDeviceReady:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupPairingProcessViewController {
                    vc.setSuccess()
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupPairingProcessViewController.setSuccess was attempted when it shouldn't be. If this is happening not during BLE OTA Update, this shouldn't be.")
                }
            case .CommissionerDeviceReady:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupPairingCommissionerProcessViewController {
                    vc.setSuccess()
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupPairingCommissionerProcessViewController.setSuccess was attempted when it shouldn't be")
                }


            case .FirmwareUpdateProgress:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupFirmwareUpdateProgressViewController {
                    vc.setProgress(progress: Int(round(self.flowRunner.context.targetDevice.firmwareUpdateProgress ?? 0)))
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupFirmwareUpdateProgressViewController.setProgress was attempted when it shouldn't be")
                }
                break;
            case .FirmwareUpdateFileComplete:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupFirmwareUpdateProgressViewController {
                    vc.setFileComplete()
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupFirmwareUpdateProgressViewController.setFileComplete was attempted when it shouldn't be")
                }
                break;
            case .FirmwareUpdateComplete:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupFirmwareUpdateProgressViewController {
                    self.flowRunner.pauseSetup()
                    vc.setFirmwareUpdateComplete()
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupFirmwareUpdateProgressViewController.setFirmwareUpdateComplete was attempted when it shouldn't be")
                }
                break;


            case .TargetDeviceScanningForWifiNetworks:
                self.currentStepType = type(of: sender)
                showSelectWifiNetworkView()
            case .TargetDeviceScanningForNetworks:
                self.currentStepType = type(of: sender)
                showSelectNetworkView()
            case .TargetInternetConnectedDeviceScanningForNetworks:
                self.currentStepType = type(of: sender)
                showSelectOrCreateNetworkView()


            case .TargetDeviceConnectingToInternetStarted:
                showConnectingToInternetView()
            case .TargetDeviceConnectingToInternetStep0Done, .TargetDeviceConnectingToInternetStep1Done, .TargetDeviceConnectingToInternetCompleted:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupProgressViewController,
                   self.embededNavigationController.topViewController is MeshSetupConnectingToInternetEthernetViewController ||
                   self.embededNavigationController.topViewController is MeshSetupConnectingToInternetWifiViewController ||
                   self.embededNavigationController.topViewController is MeshSetupConnectingToInternetCellularViewController {
                    if state == .TargetDeviceConnectingToInternetCompleted {
                        self.flowRunner.pauseSetup()
                    }

                    vc.setState(state)
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupConnectToInternetViewController.setState was attempted when it shouldn't be: \(state)")
                }



            case .JoiningNetworkStarted, .JoiningNetworkStep1Done, .JoiningNetworkStep2Done, .JoiningNetworkCompleted:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupJoiningNetworkViewController {
                    if state == .JoiningNetworkCompleted {
                        self.flowRunner.pauseSetup()
                    }
                    vc.setState(state)
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupJoiningNetworkViewController.setState was attempted when it shouldn't be: \(state)")
                }

            case .CreateNetworkStarted, .CreateNetworkStep1Done, .CreateNetworkCompleted:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupCreatingNetworkViewController {
                    if state == .CreateNetworkCompleted {
                        self.flowRunner.pauseSetup()
                    }

                    vc.setState(state)
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupCreatingNetworkViewController.setState was attempted when it shouldn't be: \(state)")
                }

            case .SetupCanceled:
                self.cancelTapped(self)
            default:
                break;
        }
    }

    internal func meshSetupError(_ sender: MeshSetupStep, error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?) {
        DispatchQueue.main.async {

            var message = error.description

            if let apiError = nsError as? NSError {
                message = "\(message) (\(apiError.localizedDescription))"
            }

            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: message, preferredStyle: .alert)

                if (severity == .Fatal) {
                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
                        self.cancelTapped(self)
                    })
                } else {
                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                        self.flowRunner.retryLastAction()
                    })

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Cancel, style: .cancel) { action in
                        self.cancelTapped(self)
                    })
                }

                self.present(self.alert!, animated: true)
            }
        }
    }


    //MARK: Handlers
    @IBAction func backTapped(_ sender: UIButton) {
        //resume previous VC
        let vcs = self.embededNavigationController.viewControllers
        log("Back tapped: \(vcs)")

        if (vcs.last! as! MeshSetupViewController).viewControllerIsBusy {
            log("viewController is busy, not backing")
            //view controller cannot be backed from at this moment
            return
        }

        guard vcs.count > 1, let vcCurr = (vcs[vcs.count-1] as? MeshSetupViewController), let vcPrev = (vcs[vcs.count-2] as? MeshSetupViewController) else {
            log("Back button was pressed when it was not supposed to be pressed. Ignoring.")
            return
        }

        vcPrev.resume(animated: false)

        if (vcs.last! as! MeshSetupViewController).allowBack {
            if vcPrev.ownerStepType != nil, vcCurr.ownerStepType != vcPrev.ownerStepType {
                log("Rewinding flow from: \(vcCurr.ownerStepType) to: \(vcPrev.ownerStepType!)")
                self.flowRunner.rewindTo(step: vcPrev.ownerStepType!)
            } else {
                log("Popping")
                vcPrev.resume(animated: false)
                self.embededNavigationController.popViewController(animated: true)
            }
        } else {
            log("Back button was pressed when it was not supposed to be pressed. Ignoring.")
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        if let _ = sender as? MeshSetupUIBase {
            self.flowRunner.cancelSetup()
            self.dismiss(animated: true)
        } else {
            DispatchQueue.main.async {
                if (self.hideAlertIfVisible()) {
                    self.alert = UIAlertController(title: MeshSetupStrings.Prompt.CancelSetupTitle, message: MeshSetupStrings.Prompt.CancelSetupText, preferredStyle: .alert)

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.CancelSetup, style: .default) { action in
                        self.cancelTapped(self)
                    })

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.ContinueSetup, style: .cancel) { action in
                        //do nothing
                    })

                    self.present(self.alert!, animated: true)
                }
            }
        }
    }

    @objc func isBusyChanged(notification: Notification) {
        self.backButtonImage.alpha = (embededNavigationController.topViewController as! MeshSetupViewController).isBusy ? 0.5 : 1
    }


    //MARK: NavigationController Delegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.backButton.isHidden = !(viewController as! MeshSetupViewController).allowBack
        self.backButtonImage.isHidden = self.backButton.isHidden
        self.backButtonImage.alpha = 1
        self.backButton.isUserInteractionEnabled = false //prevent back button during animation

        self.navigationBarTitle?.text = (viewController as! MeshSetupViewController).customTitle
        log("ViewControllers: \(navigationController.viewControllers)")
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.backButton.isUserInteractionEnabled = !self.backButtonImage.isHidden
    }
}
