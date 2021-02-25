//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright (c) 2018 Particle. All rights reserved.
//

import Foundation
import UIKit

class Gen3SetupFlowUIManager : Gen3SetupUIBase {

    var gen3SetupManager: Gen3SetupFlowManager! {
        return self.flowRunner as! Gen3SetupFlowManager
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.flowRunner = Gen3SetupFlowManager(delegate: self)
        self.gen3SetupManager.startSetup()
    }

    override func setupInitialViewController() {
        self.targetDeviceDataMatrix = nil

        self.currentStepType = StepGetTargetDeviceInfo.self

        let findStickerVC = Gen3SetupFindStickerViewController.loadedViewController()
        findStickerVC.setup(didPressScan: self.findStickerViewCompleted)
        findStickerVC.allowBack = false
        findStickerVC.ownerStepType = self.currentStepType
        self.embededNavigationController.setViewControllers([findStickerVC], animated: false)
    }



    //MARK: Get Target Device Info
    override func gen3SetupDidRequestTargetDeviceInfo(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        self.showSetupFindStickerView()
    }

    func showSetupFindStickerView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupFindStickerViewController.self)) {
                let findStickerVC = Gen3SetupFindStickerViewController.loadedViewController()
                findStickerVC.setup(didPressScan: self.findStickerViewCompleted)
                findStickerVC.allowBack = false
                findStickerVC.ownerStepType = self.currentStepType
                self.embededNavigationController.setViewControllers([findStickerVC], animated: true)
            }
        }
    }

    func findStickerViewCompleted() {
        self.showTargetScanStickerView()
    }

    func showTargetScanStickerView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupScanStickerViewController.self)) {
                let scanVC = Gen3SetupScanStickerViewController.loadedViewController()
                scanVC.setup(didFindStickerCode: self.targetDeviceScanStickerViewCompleted)
                scanVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(scanVC, animated: true)
            }
        }
    }

    func targetDeviceScanStickerViewCompleted(dataMatrixString:String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        Gen3SetupDataMatrix.getMatrix(fromString: dataMatrixString, onComplete: setTargetDeviceValidatedMatrix)
        
    }

    func setTargetDeviceValidatedMatrix(dataMatrix: Gen3SetupDataMatrix?, error: DataMatrixError?) {
        if let error: DataMatrixError = error {
            switch error {
                case .InvalidMatrix:
                    self.showWrongMatrixError(targetDevice: true)
                case .UnableToRecoverMobileSecret:
                    self.showFailedMatrixRecoveryError(dataMatrix: dataMatrix!)
                case .NetworkError:
                    self.showMatrixNetworkError { [weak self] in
                        if let self = self {
                            Gen3SetupDataMatrix.getMatrix(fromString: dataMatrix!.matrixString, onComplete: self.setTargetDeviceValidatedMatrix)
                        }
                    }
                }
        } else if let dataMatrix = dataMatrix {
            self.targetDeviceDataMatrix = dataMatrix
            self.showTargetGetReadyView()
        }
    }

    func showTargetGetReadyView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupGetReadyViewController.self)) {
                let getReadyVC = Gen3SetupGetReadyViewController.loadedViewController()
                getReadyVC.setup(didPressReady: self.targetGetReadyViewCompleted, dataMatrix: self.targetDeviceDataMatrix!)
                getReadyVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(getReadyVC, animated: true)
            }
        }
    }

    func targetGetReadyViewCompleted(useEthernet: Bool) {
        if let error = flowRunner.setTargetDeviceInfo(dataMatrix: self.targetDeviceDataMatrix!) {
            DispatchQueue.main.async {
                if (self.hideAlertIfVisible()) {
                    self.alert = UIAlertController(title: Gen3SetupStrings.Prompt.ErrorTitle, message: error.description, preferredStyle: .alert)

                    self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.Ok, style: .default) { action in
                        self.showTargetScanStickerView()
                    })

                    self.present(self.alert!, animated: true)
                }
            }
        } else {
            //this will be requested by the setup flow slightly later
            self.flowRunner.context.targetDevice.enableEthernetDetectionFeature = useEthernet

            //we do this here, because there's a high chance of reconnect in the process and we don't want this screen appearing when we reconnect
            showTargetPairingProcessView()
        }
    }





    //Mark: Request to leave network
    override func gen3SetupDidRequestToLeaveNetwork(_ sender: Gen3SetupStep, network: Gen3SetupNetworkInfo) {
        currentStepType = type(of: sender)

        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: Gen3SetupStrings.Prompt.LeaveNetworkTitle, message: Gen3SetupStrings.Prompt.LeaveNetworkText, preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.LeaveNetwork, style: .default) { action in
                    self.flowRunner.setTargetDeviceLeaveNetwork(leave: true)
                })

                self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.DontLeaveNetwork, style: .cancel) { action in
                    self.flowRunner.setTargetDeviceLeaveNetwork(leave: false)
                })

                self.present(self.alert!, animated: true)
            }
        }
    }



    //MARK: switch to control panel
    override func gen3SetupDidRequestToSwitchToControlPanel(_ sender: Gen3SetupStep, device: ParticleDevice) {
        currentStepType = type(of: sender)

        //TODO: drop commissioner connection
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: Gen3SetupStrings.Prompt.SwitchToControlPanelTitle, message: Gen3SetupStrings.Prompt.SwitchToControlPanelText, preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.SwitchToControlPanel, style: .default) { action in
                    let vc = Gen3SetupControlPanelUIManager.loadedViewController()
                    vc.setDevice(device, context: self.flowRunner.context)
                    self.dismiss(animated: true) {
                        if let callback = self.callback {
                            callback(Gen3SetupFlowResult.switchToControlPanel, [vc])
                        }
                    }
                })

                self.alert!.addAction(UIAlertAction(title: Gen3SetupStrings.Action.DontSwitchToControlPanel, style: .cancel) { action in
                    self.flowRunner.setSwitchToControlPanel(switchToCP: false)
                })

                self.present(self.alert!, animated: true)
            }
        }
    }




    //MARK: stand alone or mesh
    override func gen3SetupDidRequestToSelectStandAloneOrMeshSetup(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        showStandAloneOrMeshSetupView()
    }

    private func showStandAloneOrMeshSetupView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupStandAloneOrMeshSetupViewController.self)) {
                let setupVC = Gen3SetupStandAloneOrMeshSetupViewController.loadedViewController()
                setupVC.allowBack = false
                setupVC.ownerStepType = self.currentStepType
                setupVC.setup(setupMesh: self.standAloneOrMeshSetupViewCompleted, deviceType: self.flowRunner.context.targetDevice.type)
                self.embededNavigationController.pushViewController(setupVC, animated: true)
            }
        }
    }

    func standAloneOrMeshSetupViewCompleted(setupMesh: Bool) {
        flowRunner.setSelectStandAloneOrMeshSetup(meshSetup: setupMesh)
    }








    //MARK: Gateway Info
    override func gen3SetupDidRequestToShowInfo(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        showInfoView(type: (sender as! StepShowInfo).infoType)
    }

    private func showInfoView(type: Gen3SetupInfoType) {
        //TODO: review this based on mesh info type

        //xenon joiner flow = activeInternetInterface == nil, userSelectedToSetupMesh = nil, userSelectedToCreateNetwork = nil
        //argon / boron joiner flow = activeInternetInterface != nil, userSelectedToSetupMesh = true, userSelectedToCreateNetwork = false

        //gateway flow = activeInternetInterface != nil, userSelectedToSetupMesh = true, userSelectedToCreateNetwork = true
        //standalone flow = activeInternetInterface != nil, userSelectedToSetupMesh = false, userSelectedToCreateNetwork = nil


        if let activeInternetInterface = self.flowRunner.context.targetDevice.activeInternetInterface, let userSelectedToSetupMesh = self.flowRunner.context.userSelectedToSetupMesh,
           self.flowRunner.context.userSelectedToCreateNetwork == nil || self.flowRunner.context.userSelectedToCreateNetwork! == true {
            switch activeInternetInterface {
                case .ethernet:
                    DispatchQueue.main.async {
                        if (!self.rewindTo(Gen3SetupInfoEthernetViewController.self)) {
                            let infoVC = Gen3SetupInfoEthernetViewController.loadedViewController()
                            infoVC.ownerStepType = self.currentStepType
                            infoVC.allowBack = self.flowRunner.context.targetDevice.supportsMesh!
                            infoVC.setup(didFinishScreen: self.infoViewCompleted, setupMesh: userSelectedToSetupMesh, deviceType: self.flowRunner.context.targetDevice.type!)
                            self.embededNavigationController.pushViewController(infoVC, animated: true)
                        }
                    }
                case .wifi:
                    DispatchQueue.main.async {
                        if (!self.rewindTo(Gen3SetupInfoWifiViewController.self)) {
                            let infoVC = Gen3SetupInfoWifiViewController.loadedViewController()
                            infoVC.ownerStepType = self.currentStepType
                            infoVC.allowBack = self.flowRunner.context.targetDevice.supportsMesh!
                            infoVC.setup(didFinishScreen: self.infoViewCompleted, setupMesh: userSelectedToSetupMesh, deviceType: self.flowRunner.context.targetDevice.type!)
                            self.embededNavigationController.pushViewController(infoVC, animated: true)
                        }
                    }
                case .ppp:
                    DispatchQueue.main.async {
                        if (!self.rewindTo(Gen3SetupCellularInfoViewController.self)) {
                            let cellularInfoVC = Gen3SetupCellularInfoViewController.loadedViewController()
                            cellularInfoVC.ownerStepType = self.currentStepType
                            cellularInfoVC.allowBack = self.flowRunner.context.targetDevice.supportsMesh!
                            cellularInfoVC.setup(didFinishScreen: self.infoViewCompleted, setupMesh: userSelectedToSetupMesh, simActive: self.flowRunner.context.targetDevice.sim?.active ?? false, deviceType: self.flowRunner.context.targetDevice.type!)
                            self.embededNavigationController.pushViewController(cellularInfoVC, animated: true)
                        }
                    }
                default:
                    //others are not interesting
                    break
            }
        } else {
            DispatchQueue.main.async {
                if (!self.rewindTo(Gen3SetupInfoJoinerViewController.self)) {
                    let infoVC = Gen3SetupInfoJoinerViewController.loadedViewController()
                    //if we are setting up argon/boron device, user will be asked to select if he wants to setup mesh
                    //for xenons this will be nil. We want to let argon/boron joiner flow to be backed from to enable option
                    //of switching to gateway / standalone flow
                    infoVC.allowBack = self.flowRunner.context.userSelectedToSetupMesh != nil
                    infoVC.ownerStepType = self.currentStepType
                    infoVC.setup(didFinishScreen: self.infoViewCompleted, setupMesh: self.flowRunner.context.userSelectedToSetupMesh, deviceType: self.flowRunner.context.targetDevice.type!)
                    self.embededNavigationController.pushViewController(infoVC, animated: true)
                }
            }
        }
    }

    func infoViewCompleted() {
        self.flowRunner.setInfoDone()
    }






    //MARK: add one more device
    override func gen3SetupDidRequestToAddOneMoreDevice(_ sender: Gen3SetupStep) {
        currentStepType = type(of: sender)

        if (self.flowRunner.context.userSelectedToCreateNetwork != nil && self.flowRunner.context.userSelectedToCreateNetwork!) {
            //this is the end of create network flow
            showNetworkCreatedView()
        } else {
            //this is the end of joiner or standalone flow
            showSuccessView()
        }
    }

    private func showSuccessView() {
        if (!self.rewindTo(Gen3SetupSuccessViewController.self)) {
            let successVC = Gen3SetupSuccessViewController.loadedViewController()
            successVC.ownerStepType = self.currentStepType
            successVC.allowBack = false
            successVC.setup(didSelectDone: self.successViewCompleted, deviceName: self.flowRunner.context.targetDevice.name!, networkName: self.flowRunner.context.selectedNetworkMeshInfo?.name)
            self.embededNavigationController.pushViewController(successVC, animated: true)
        }
    }

    private func showNetworkCreatedView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(Gen3SetupNetworkCreatedViewController.self)) {
                let successVC = Gen3SetupNetworkCreatedViewController.loadedViewController()
                successVC.ownerStepType = self.currentStepType
                successVC.allowBack = false
                successVC.setup(didSelectDone: self.successViewCompleted, deviceName: self.flowRunner.context.commissionerDevice!.name!) //at this point the target device has already been marked as commissioner
                self.embededNavigationController.pushViewController(successVC, animated: true)
            }
        }
    }

    func successViewCompleted(done: Bool) {
        flowRunner.setAddOneMoreDevice(addOneMoreDevice: !done)

        if (done) {
            //setup done
            self.terminate()
            if let callback = self.callback {
                callback(Gen3SetupFlowResult.success, nil)
            }
        } else {
            self.setupInitialViewController()
        }
    }


}


