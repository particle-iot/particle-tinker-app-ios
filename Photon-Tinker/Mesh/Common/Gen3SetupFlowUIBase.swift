//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright (c) 2018 Particle. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

public enum Gen3SetupFlowResult: CustomStringConvertible {
    case success
    case error
    case canceled
    case switchToControlPanel
    case unclaimed

    public var description: String {
        switch self {
            case .success:
                return "success"
            case .error:
                return "error"
            case .canceled:
                return "canceled"
            case .switchToControlPanel:
                return "switchToControlPanel"
            case .unclaimed:
                return "unclaimed"
        }
    }
}

typealias Gen3SetupFlowCallback = (Gen3SetupFlowResult, [AnyObject]?) -> ()

class Gen3SetupUIBase : UIViewController, Storyboardable, Gen3SetupFlowRunnerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, STPAddCardViewControllerDelegate {

    static var storyboardName: String {
        return "Gen3Setup"
    }

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonImage: UIImageView!

    @IBOutlet weak var navigationBarTitle: ParticleLabel!

    internal var flowRunner: Gen3SetupFlowRunner!
    internal var embededNavigationController: UINavigationController!

    internal var targetDeviceDataMatrix: Gen3SetupDataMatrix?

    internal var alert: UIAlertController?
    internal var lockAlert: Bool = false //when critical alert is shown, this is set to true

    internal var currentStepType: Gen3SetupStep.Type?
    {
        didSet {
            self.log("Switching currentStepType: \(currentStepType)")
        }
    }

    internal var callback: Gen3SetupFlowCallback?

    func setCallback(_ callback: @escaping Gen3SetupFlowCallback) {
        self.callback = callback
    }

    internal func log(_ message: String) {
        ParticleLogger.logInfo("Gen3SetupFlowUI", format: message, withParameters: getVaList([]))
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 13.0, *) {
            if self.responds(to: Selector("overrideUserInterfaceStyle")) {
                self.setValue(UIUserInterfaceStyle.light.rawValue, forKey: "overrideUserInterfaceStyle")
            }
        }
        
        self.modalPresentationStyle = .fullScreen
    }



    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(isBusyChanged), name: Notification.Name.Gen3SetupViewControllerBusyChanged, object: nil)
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
                (vc as! Gen3SetupViewController).resume(animated: false)
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

    internal func showMatrixNetworkError(onRetry: @escaping () -> ()) {
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: Gen3SetupStrings.Prompt.ErrorTitle, message: Gen3SetupFlowError.NetworkError.description, preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.CancelSetup, style: .cancel) { action in
                    self.cancelTapped(self)
                })

                self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.Retry, style: .default) { action in
                    onRetry()
                })

                self.present(self.alert!, animated: true)
            }
        }
    }

    internal func showWrongMatrixError(targetDevice: Bool) {
        //show error where selected device type mismatch
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: Gen3SetupStrings.Prompt.ErrorTitle,
                        message: targetDevice ? Gen3SetupFlowError.WrongTargetDeviceType.description : Gen3SetupFlowError.WrongCommissionerDeviceType.description,
                        preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.Ok, style: .default) { action in
                    self.restartCaptureSession()
                })

                self.present(self.alert!, animated: true)
            }
        }
    }

    internal func showFailedMatrixRecoveryError(dataMatrix: Gen3SetupDataMatrix) {
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: Gen3SetupStrings.Prompt.ErrorTitle, message: Gen3SetupFlowError.StickerError.description, preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.Ok, style: .cancel) { action in
                    self.restartCaptureSession()
                })

                self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.ContactSupport, style: .default) { action in
                    self.openEmailClient(dataMatrix: dataMatrix)
                    self.restartCaptureSession()
                })

                self.present(self.alert!, animated: true)
            }
        }
    }

    internal func openEmailClient(dataMatrix: Gen3SetupDataMatrix) {
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
        if let vc = self.embededNavigationController.topViewController as? Gen3SetupScanCommissionerStickerViewController {
            vc.resume(animated: true)
        } else if let vc = self.embededNavigationController.topViewController as? Gen3SetupScanStickerViewController {
            vc.resume(animated: true)
        } else {
            self.log("!!!!!!!!!!!!!!!!!!!!!!! Gen3SetupScanCommissionerStickerViewController / Gen3SetupScanStickerViewController.restartCaptureSession was attempted when it shouldn't be")
        }
    }

    internal func gen3SetupDidRequestTargetDeviceInfo(_ sender: Gen3SetupStep) {
        fatalError("not implemented")
    }

    internal func gen3SetupDidRequestToSelectSimDataLimit(_ sender: Gen3SetupStep) {
        fatalError("not implemented")
    }

    internal func gen3SetupDidRequestToSelectSimStatus(_ sender: Gen3SetupStep) {
        fatalError("not implemented")
    }

    internal func gen3SetupDidRequestToSelectEthernetStatus(_ sender: Gen3SetupStep) {
        fatalError("not implemented")
    }

    internal func gen3SetupDidRequestToLeaveNetwork(_ sender: Gen3SetupStep, network: Gen3SetupNetworkInfo) {
        fatalError("not implemented")
    }

    internal func gen3SetupDidRequestToSwitchToControlPanel(_ sender: Gen3SetupStep, device: ParticleDevice) {
        fatalError("not implemented")
    }

    internal func gen3SetupDidRequestToSelectStandAloneOrMeshSetup(_ sender: Gen3SetupStep) {
        fatalError("not implemented")
    }

    internal func gen3SetupDidRequestToShowInfo(_ sender: Gen3SetupStep) {
        fatalError("not implemented")
    }

    internal func gen3SetupDidRequestToAddOneMoreDevice(_ sender: Gen3SetupStep) {
        fatalError("not implemented")
    }

    internal func gen3SetupDidCompleteControlPanelFlow(_ sender: Gen3SetupStep) {
        fatalError("not implemented")
    }


    //MARK: Pairing
    func showTargetPairingProcessView() {
        self.flowRunner.pauseSetup()
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupPairingProcessViewController.self)) {
                let pairingVC = Gen3SetupPairingProcessViewController.loadedViewController()
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
    internal func gen3SetupDidRequestToUpdateFirmware(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        self.showFirmwareUpdateView()
    }

    internal func showFirmwareUpdateView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupFirmwareUpdateViewController.self)) {
                let prepareUpdateFirmwareVC = Gen3SetupFirmwareUpdateViewController.loadedViewController()
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
            if (!self.rewindTo(Gen3SetupFirmwareUpdateProgressViewController.self)) {
                let updateFirmwareVC = Gen3SetupFirmwareUpdateProgressViewController.loadedViewController()
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
    internal func gen3SetupDidRequestToEnterDeviceName(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        showNameDeviceView()
    }

    internal func showNameDeviceView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupNameDeviceViewController.self)) {
                let nameVC = Gen3SetupNameDeviceViewController.loadedViewController()
                nameVC.allowBack = false
                nameVC.ownerStepType = self.currentStepType
                nameVC.setup(didEnterName: self.nameDeviceViewCompleted, deviceType: self.flowRunner.context.targetDevice.type, currentName: self.flowRunner.context.targetDevice.name)
                self.embededNavigationController.pushViewController(nameVC, animated: true)
            }
        }
    }

    internal func nameDeviceViewCompleted(name: String) {
        flowRunner.setDeviceName(name: name) { error in
            if error != nil, let vc = self.embededNavigationController.topViewController as? Gen3SetupNameDeviceViewController {
                vc.setWrongInput(message: error!.description)
            }
        }
    }






    //MARK: Pricing info
    internal func gen3SetupDidRequestToShowPricingInfo(_ sender: Gen3SetupStep, info: ParticlePricingInfo) {
        currentStepType = type(of: sender)

        showPricingInfoView(info: info)
    }

    internal func showPricingInfoView(info: ParticlePricingInfo) {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupPricingInfoViewController.self)) {
                let pricingInfoVC = Gen3SetupPricingInfoViewController.loadedViewController()
                pricingInfoVC.ownerStepType = self.currentStepType
                pricingInfoVC.allowBack = self.flowRunner.context.targetDevice.supportsMesh!
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
                addCardViewController.delegate = self

                let navigationController = UINavigationController(rootViewController: addCardViewController)
                navigationController.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.font: UIFont(name: ParticleStyle.BoldFont, size: CGFloat(ParticleStyle.RegularSize)),
                    NSAttributedString.Key.foregroundColor: ParticleStyle.PrimaryTextColor
                ]

                if #available(iOS 13.0, *) {
                    addCardViewController.overrideUserInterfaceStyle = .light
                    navigationController.overrideUserInterfaceStyle = .light
                }

                self.present(navigationController, animated: true)
            }
        }
    }

    //MARK: Collect CC Delegate
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.rewindTo(Gen3SetupPricingInfoViewController.self)
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
            if let _ = self.embededNavigationController.topViewController as? Gen3SetupSelectWifiNetworkViewController {
                //do nothing
            } else {
                if (!self.rewindTo(Gen3SetupSelectWifiNetworkViewController.self)) {
                    let networksVC = Gen3SetupSelectWifiNetworkViewController.loadedViewController()
                    networksVC.ownerStepType = self.currentStepType
                    networksVC.setup(didSelectNetwork: self.selectWifiNetworkViewCompleted)
                    self.embededNavigationController.pushViewController(networksVC, animated: true)
                }
            }
        }
    }

    internal func selectWifiNetworkViewCompleted(network: Gen3SetupNewWifiNetworkInfo) {
        flowRunner.setSelectedWifiNetwork(selectedNetwork: network)
    }

    internal func gen3SetupDidRequestToSelectWifiNetwork(_ sender: Gen3SetupStep, availableNetworks: [Gen3SetupNewWifiNetworkInfo]) {
        self.log("scan complete")

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let vc = self.embededNavigationController.topViewController as? Gen3SetupSelectWifiNetworkViewController {
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
            if let vc = self.embededNavigationController.topViewController as? Gen3SetupSelectWifiNetworkViewController {
                if (flowRunner.rescanNetworks() == nil) {
                    vc.startScanning()
                } else {
                    self.log("rescanNetworks was attempted when it shouldn't be")
                }
            }
        }
    }




    //MARK: Wifi network password
    internal func gen3SetupDidRequestToEnterSelectedWifiNetworkPassword(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        showWifiNetworkPasswordView()
    }

    internal func showWifiNetworkPasswordView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupWifiNetworkPasswordViewController.self)) {
                let passwordVC = Gen3SetupWifiNetworkPasswordViewController.loadedViewController()
                passwordVC.ownerStepType = self.currentStepType
                passwordVC.setup(didEnterPassword: self.wifiNetworkPasswordViewCompleted, networkName: self.flowRunner.context.selectedWifiNetworkInfo!.ssid)
                self.embededNavigationController.pushViewController(passwordVC, animated: true)
            }
        }
    }

    internal func wifiNetworkPasswordViewCompleted(password: String) {
        flowRunner.setSelectedWifiNetworkPassword(password) { error in
            if error != nil, let vc = self.embededNavigationController.topViewController as? Gen3SetupWifiNetworkPasswordViewController {
                vc.setWrongInput(message: error!.description)
            }
        }
    }







    //MARK: Scan networks
    internal func showSelectNetworkView() {
        DispatchQueue.main.async {
            if let _ = self.embededNavigationController.topViewController as? Gen3SetupSelectNetworkViewController {
                //do nothing
            } else {
                if (!self.rewindTo(Gen3SetupSelectNetworkViewController.self)) {
                    let networksVC = Gen3SetupSelectNetworkViewController.loadedViewController()
                    networksVC.ownerStepType = self.currentStepType
                    networksVC.setup(didSelectNetwork: self.selectNetworkViewCompleted)
                    self.embededNavigationController.pushViewController(networksVC, animated: true)
                }
            }
        }
    }

    internal func showSelectOrCreateNetworkView() {
        DispatchQueue.main.async {
            if let _ = self.embededNavigationController.topViewController as? Gen3SetupSelectOrCreateNetworkViewController {
                //do nothing
            } else {
                if (!self.rewindTo(Gen3SetupSelectOrCreateNetworkViewController.self)) {
                    let networksVC = Gen3SetupSelectOrCreateNetworkViewController.loadedViewController()
                    networksVC.ownerStepType = self.currentStepType
                    networksVC.setup(didSelectNetwork: self.selectOrCreateNetworkViewCompleted)
                    self.embededNavigationController.pushViewController(networksVC, animated: true)
                }
            }
        }
    }

    internal func selectNetworkViewCompleted(network: Gen3SetupNetworkCellInfo?) {
        guard network != nil else {
            log("Selected empty network for joiner flow")
            return
        }

        //in control panel it's possible that this screen is shown to disable network creation
        if let currentStep = flowRunner.currentStep, type(of: currentStep) == StepOfferSelectOrCreateNetwork.self {
            flowRunner.setOptionalSelectedNetwork(selectedNetworkExtPanID: network?.extPanID)
        } else {
            flowRunner.setSelectedNetwork(selectedNetworkExtPanID: network!.extPanID)
        }
    }


    internal func selectOrCreateNetworkViewCompleted(network: Gen3SetupNetworkCellInfo?) {
        flowRunner.setOptionalSelectedNetwork(selectedNetworkExtPanID: network?.extPanID)
    }


    internal func gen3SetupDidRequestToSelectNetwork(_ sender: Gen3SetupStep, availableNetworks: [Gen3SetupNetworkCellInfo]) {
        self.log("scan complete")

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let vc = self.embededNavigationController.topViewController as? Gen3SetupSelectNetworkViewController {
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


    internal func gen3SetupDidRequestToSelectOrCreateNetwork(_ sender: Gen3SetupStep, availableNetworks: [Gen3SetupNetworkCellInfo]) {
        self.log("scan complete")

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let vc = self.embededNavigationController.topViewController as? Gen3SetupSelectNetworkViewController {
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
            if let vc = self.embededNavigationController.topViewController as? Gen3SetupSelectNetworkViewController {
                if (flowRunner.rescanNetworks() == nil) {
                    vc.startScanning()
                } else {
                    self.log("rescanNetworks was attempted when it shouldn't be")
                }
            } else if let vc = self.embededNavigationController.topViewController as? Gen3SetupSelectOrCreateNetworkViewController, self.flowRunner.context.userSelectedToCreateNetwork == nil {
                if (flowRunner.rescanNetworks() == nil) {
                    vc.startScanning()
                } else {
                    self.log("rescanNetworks was attempted when it shouldn't be")
                }
            }
        }
    }





    //MARK: Connect to selected network
    internal func gen3SetupDidRequestCommissionerDeviceInfo(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)
        log("requesting commisioner info!!")

        showGetCommissionerReadyView()
    }

    private func showGetCommissionerReadyView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupScanCommissionerStickerViewController.self)) {
                let getReadyVC = Gen3SetupGetCommissionerReadyViewController.loadedViewController()
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
            if (!self.rewindTo(Gen3SetupFindCommissionerStickerViewController.self)) {
                let findStickerVC = Gen3SetupFindCommissionerStickerViewController.loadedViewController()
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
            if (!self.rewindTo(Gen3SetupScanCommissionerStickerViewController.self)) {
                let scanVC = Gen3SetupScanCommissionerStickerViewController.loadedViewController()
                scanVC.setup(didFindStickerCode: self.scanCommissionerStickerViewCompleted)
                scanVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(scanVC, animated: true)
            }
        }
    }
    

    internal func scanCommissionerStickerViewCompleted(dataMatrixString:String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        Gen3SetupDataMatrix.getMatrix(fromString: dataMatrixString, onComplete: setCommissionerDeviceValidatedMatrix)
    }

    internal func setCommissionerDeviceValidatedMatrix(dataMatrix: Gen3SetupDataMatrix?, error: DataMatrixError?) {
        if let error: DataMatrixError = error {
            switch error {
            case .InvalidMatrix:
                self.showWrongMatrixError(targetDevice: true)
            case .UnableToRecoverMobileSecret:
                self.showFailedMatrixRecoveryError(dataMatrix: dataMatrix!)
            case .NetworkError:
                self.showMatrixNetworkError { [weak self] in
                    if let self = self {
                        Gen3SetupDataMatrix.getMatrix(fromString: dataMatrix!.matrixString, onComplete: self.setCommissionerDeviceValidatedMatrix)
                    }
                }
            }
        } else if let dataMatrix = dataMatrix {
            if let flowError = flowRunner.setCommissionerDeviceInfo(dataMatrix: dataMatrix) {
                DispatchQueue.main.async {
                    if (self.hideAlertIfVisible()) {
                        self.alert = UIAlertController(title: Gen3SetupStrings.Prompt.ErrorTitle, message: flowError.description, preferredStyle: .alert)

                        self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.Ok, style: .default) { action in
                            self.restartCaptureSession()
                        })

                        self.present(self.alert!, animated: true)
                    }
                }
            } else {
                self.flowRunner.pauseSetup()
                showPairingCommissionerProcessView(deviceType: dataMatrix.type!)
            }
        }
    }

    private func showPairingCommissionerProcessView(deviceType: ParticleDeviceType) {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupPairingCommissionerProcessViewController.self)) {
                let pairingVC = Gen3SetupPairingCommissionerProcessViewController.loadedViewController()
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
    internal func gen3SetupDidRequestToEnterSelectedNetworkPassword(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        showNetworkPasswordView()
    }

    private func showNetworkPasswordView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupNetworkPasswordViewController.self)) {
                let passwordVC = Gen3SetupNetworkPasswordViewController.loadedViewController()
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
                //self.showJoiningNetworkView()
                //this will trigger based on JoiningNetworkStarted event
            } else if let vc = self.embededNavigationController.topViewController as? Gen3SetupNetworkPasswordViewController {
                vc.setWrongInput(message: error!.description)
            }
        }
    }

    internal func showJoiningNetworkView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupJoiningNetworkViewController.self)) {
                let joiningVC = Gen3SetupJoiningNetworkViewController.loadedViewController()
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
                    if let vc = self.embededNavigationController.topViewController as? Gen3SetupConnectingToInternetEthernetViewController {
                        vc.setState(.TargetDeviceConnectingToInternetStarted)
                    } else {
                        if (!self.rewindTo(Gen3SetupConnectingToInternetEthernetViewController.self)) {
                            let connectingVC = Gen3SetupConnectingToInternetEthernetViewController.loadedViewController()
                            connectingVC.allowBack = false
                            connectingVC.ownerStepType = self.currentStepType
                            connectingVC.setup(didFinishScreen: self.connectingToInternetViewCompleted, deviceType: self.flowRunner.context.targetDevice.type)
                            self.embededNavigationController.pushViewController(connectingVC, animated: true)
                        }
                    }
                }
            case .wifi:
                DispatchQueue.main.async {
                    if let vc = self.embededNavigationController.topViewController as? Gen3SetupConnectingToInternetWifiViewController {
                        vc.setState(.TargetDeviceConnectingToInternetStarted)
                    } else {
                        if (!self.rewindTo(Gen3SetupConnectingToInternetWifiViewController.self)) {
                            let connectingVC = Gen3SetupConnectingToInternetWifiViewController.loadedViewController()
                            connectingVC.allowBack = false
                            connectingVC.ownerStepType = self.currentStepType
                            connectingVC.setup(didFinishScreen: self.connectingToInternetViewCompleted, deviceType: self.flowRunner.context.targetDevice.type)
                            self.embededNavigationController.pushViewController(connectingVC, animated: true)
                        }
                    }
                }
            case .ppp:
                DispatchQueue.main.async {
                    if let vc = self.embededNavigationController.topViewController as? Gen3SetupConnectingToInternetCellularViewController {
                        vc.setState(.TargetDeviceConnectingToInternetStarted)
                    } else {
                        if (!self.rewindTo(Gen3SetupConnectingToInternetCellularViewController.self)) {
                            let connectingVC = Gen3SetupConnectingToInternetCellularViewController.loadedViewController()
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
    internal func gen3SetupDidRequestToEnterNewNetworkName(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        showCreateNetworkNameView()
    }

    internal func showCreateNetworkNameView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupCreateNetworkNameViewController.self)) {
                let networkNameVC = Gen3SetupCreateNetworkNameViewController.loadedViewController()
                networkNameVC.setup(didEnterNetworkName: self.createNetworkNameCompleted)
                networkNameVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(networkNameVC, animated: true)
            }
        }
    }

    internal func createNetworkNameCompleted(networkName: String) {
        if let error = self.flowRunner.setNewNetworkName(name: networkName),
           let vc = self.embededNavigationController.topViewController as? Gen3SetupCreateNetworkNameViewController {
            vc.setWrongInput(message: error.description)
        } else {
            showCreateNetworkPasswordView()
        }
    }

    internal func gen3SetupDidRequestToEnterNewNetworkPassword(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        showCreateNetworkPasswordView()
    }

    internal func showCreateNetworkPasswordView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupCreateNetworkPasswordViewController.self)) {
                let networkPasswordVC = Gen3SetupCreateNetworkPasswordViewController.loadedViewController()
                networkPasswordVC.setup(didEnterNetworkPassword: self.createNetworkPasswordViewCompleted)
                networkPasswordVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(networkPasswordVC, animated: true)
            }
        }
    }

    internal func createNetworkPasswordViewCompleted(networkPassword: String) {
        if let error = self.flowRunner.setNewNetworkPassword(password: networkPassword),
           let vc = self.embededNavigationController.topViewController as? Gen3SetupCreateNetworkPasswordViewController{
            vc.setWrongInput(message: error.description)
        } else {
            showCreatingNetworkView()
        }
    }


    internal func showCreatingNetworkView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupCreatingNetworkViewController.self)) {
                let createNetworkVC = Gen3SetupCreatingNetworkViewController.loadedViewController()
                createNetworkVC.allowBack = false
                createNetworkVC.ownerStepType = self.currentStepType
                createNetworkVC.setup(didFinishScreen: self.creatingNetworkViewCompleted, deviceType: self.flowRunner.context.targetDevice.type, deviceName: self.flowRunner.context.targetDevice.name)
                self.embededNavigationController.pushViewController(createNetworkVC, animated: true)
            }
        }
    }

    internal func gen3SetupDidCreateNetwork(_ sender: Gen3SetupStep, network: Gen3SetupNetworkCellInfo) {
        currentStepType = type(of: sender)

        //nothing needs to be done on ui side
    }

    internal func creatingNetworkViewCompleted() {
        self.flowRunner.continueSetup()

        // simply do nothing. screen will be exited automatically
    }



    internal func gen3SetupDidEnterState(_ sender: Gen3SetupStep, state: Gen3SetupFlowState) {
        log("flow setup entered state: \(state)")
        switch state {
            case .TargetDeviceReady:
                if let vc = self.embededNavigationController.topViewController as? Gen3SetupPairingProcessViewController {
                    vc.setSuccess()
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! Gen3SetupPairingProcessViewController.setSuccess was attempted when it shouldn't be. If this is happening not during BLE OTA Update, this shouldn't be.")
                }
            case .CommissionerDeviceReady:
                if let vc = self.embededNavigationController.topViewController as? Gen3SetupPairingCommissionerProcessViewController {
                    vc.setSuccess()
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! Gen3SetupPairingCommissionerProcessViewController.setSuccess was attempted when it shouldn't be")
                }


            case .FirmwareUpdateProgress:
                if let vc = self.embededNavigationController.topViewController as? Gen3SetupFirmwareUpdateProgressViewController {
                    vc.setProgress(progress: Int(round(self.flowRunner.context.targetDevice.firmwareUpdateProgress ?? 0)))
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! Gen3SetupFirmwareUpdateProgressViewController.setProgress was attempted when it shouldn't be")
                }
                break;
            case .FirmwareUpdateFileComplete:
                if let vc = self.embededNavigationController.topViewController as? Gen3SetupFirmwareUpdateProgressViewController {
                    vc.setFileComplete()
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! Gen3SetupFirmwareUpdateProgressViewController.setFileComplete was attempted when it shouldn't be")
                }
                break;
            case .FirmwareUpdateComplete:
                if let vc = self.embededNavigationController.topViewController as? Gen3SetupFirmwareUpdateProgressViewController {
                    self.flowRunner.pauseSetup()
                    vc.setFirmwareUpdateComplete()
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! Gen3SetupFirmwareUpdateProgressViewController.setFirmwareUpdateComplete was attempted when it shouldn't be")
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
                if let vc = self.embededNavigationController.topViewController as? Gen3SetupProgressViewController,
                   self.embededNavigationController.topViewController is Gen3SetupConnectingToInternetEthernetViewController ||
                   self.embededNavigationController.topViewController is Gen3SetupConnectingToInternetWifiViewController ||
                   self.embededNavigationController.topViewController is Gen3SetupConnectingToInternetCellularViewController {
                    if state == .TargetDeviceConnectingToInternetCompleted {
                        self.flowRunner.pauseSetup()
                    }

                    vc.setState(state)
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! Gen3SetupConnectToInternetViewController.setState was attempted when it shouldn't be: \(state)")
                }



            case .JoiningNetworkStarted, .JoiningNetworkStep1Done, .JoiningNetworkStep2Done, .JoiningNetworkCompleted:

                if let vc = self.embededNavigationController.topViewController as? Gen3SetupJoiningNetworkViewController {
                    if state == .JoiningNetworkCompleted {
                        self.flowRunner.pauseSetup()
                    }
                    vc.setState(state)
                } else if state == .JoiningNetworkStarted {
                    self.showJoiningNetworkView()
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! Gen3SetupJoiningNetworkViewController.setState was attempted when it shouldn't be: \(state)")
                }

            case .CreateNetworkStarted, .CreateNetworkStep1Done, .CreateNetworkCompleted:
                if let vc = self.embededNavigationController.topViewController as? Gen3SetupCreatingNetworkViewController {
                    if state == .CreateNetworkCompleted {
                        self.flowRunner.pauseSetup()
                    }

                    vc.setState(state)
                } else {
                    self.log("!!!!!!!!!!!!!!!!!!!!!!! Gen3SetupCreatingNetworkViewController.setState was attempted when it shouldn't be: \(state)")
                }

            case .SetupCanceled:
                self.cancelTapped(self)
            default:
                break;
        }
    }

    internal func gen3SetupError(_ sender: Gen3SetupStep, error: Gen3SetupFlowError, severity: Gen3SetupErrorSeverity, nsError: Error?) {
        DispatchQueue.main.async {

            var message = error.description

            if let apiError = nsError as? NSError {
                message = "\(message) (\(apiError.localizedDescription))"
            }

            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: Gen3SetupStrings.Prompt.ErrorTitle, message: message, preferredStyle: .alert)

                if (severity == .Fatal) {
                    self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.Ok, style: .default) { action in
                        if let callback = self.callback {
                            callback(Gen3SetupFlowResult.error, nil)
                        }
                        self.terminate()
                    })
                } else {
                    self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.Retry, style: .default) { action in
                        self.flowRunner.retryLastAction()
                    })

                    self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.Cancel, style: .cancel) { action in
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

        if (vcs.last! as! Gen3SetupViewController).viewControllerIsBusy {
            log("viewController is busy, not backing")
            //view controller cannot be backed from at this moment
            return
        }

        guard vcs.count > 1, let vcCurr = (vcs[vcs.count-1] as? Gen3SetupViewController), let vcPrev = (vcs[vcs.count-2] as? Gen3SetupViewController) else {
            log("Back button was pressed when it was not supposed to be pressed. Ignoring.")
            return
        }

        if vcCurr.allowBack {
            vcPrev.resume(animated: false)

            if vcPrev.ownerStepType != nil, vcCurr.ownerStepType != vcPrev.ownerStepType {
                log("Rewinding flow from: \(vcCurr.ownerStepType) to: \(vcPrev.ownerStepType!)")
                self.flowRunner.rewindTo(step: vcPrev.ownerStepType!)
            } else {
                log("Popping")
                self.embededNavigationController.popViewController(animated: true)
            }
        } else {
            log("Back button was pressed when it was not supposed to be pressed. Ignoring.")
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        if (sender is Gen3SetupUIBase) || (self.flowRunner.currentFlow == nil) {
            if let callback = self.callback {
                callback(Gen3SetupFlowResult.canceled, nil)
            }
            self.terminate()
        } else {
            DispatchQueue.main.async {
                if (self.hideAlertIfVisible()) {
                    self.alert = UIAlertController(title: Gen3SetupStrings.Prompt.CancelSetupTitle, message: Gen3SetupStrings.Prompt.CancelSetupText, preferredStyle: .alert)

                    self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.CancelSetup, style: .default) { action in
                        if let callback = self.callback {
                            callback(Gen3SetupFlowResult.canceled, nil)
                        }
                        self.terminate()
                    })

                    self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.ContinueSetup, style: .cancel) { action in
                        //do nothing
                    })

                    self.present(self.alert!, animated: true)
                }
            }
        }
    }

    func terminate() {
        self.flowRunner.cancelSetup()
        self.dismiss(animated: true)
    }

    @objc func isBusyChanged(notification: Notification) {
        self.backButtonImage.alpha = (embededNavigationController.topViewController as! Gen3SetupViewController).isBusy ? 0.5 : 1
    }


    //MARK: NavigationController Delegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.backButton.isHidden = !(viewController as! Gen3SetupViewController).allowBack
        self.backButtonImage.isHidden = self.backButton.isHidden
        self.backButtonImage.alpha = 1
        self.backButton.isUserInteractionEnabled = false //prevent back button during animation

        self.navigationBarTitle?.text = (viewController as! Gen3SetupViewController).customTitle
        log("ViewControllers: \(navigationController.viewControllers)")
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.backButton.isUserInteractionEnabled = !self.backButtonImage.isHidden
    }
}
