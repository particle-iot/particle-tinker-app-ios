//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright © 2018 Particle. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import MessageUI

class MeshSetupFlowUIManager : MeshSetupUIBase {

    var meshSetupManager: MeshSetupFlowManager! {
        return self.flowRunner as! MeshSetupFlowManager
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.flowRunner = MeshSetupFlowManager(delegate: self)
        self.meshSetupManager.startSetup()
    }

    override func setupInitialViewController() {
        self.targetDeviceDataMatrix = nil

        self.currentStepType = StepGetTargetDeviceInfo.self

        let findStickerVC = MeshSetupFindStickerViewController.loadedViewController()
        findStickerVC.setup(didPressScan: self.findStickerViewCompleted)
        findStickerVC.allowBack = false
        findStickerVC.ownerStepType = self.currentStepType
        self.embededNavigationController.setViewControllers([findStickerVC], animated: false)
    }



    //MARK: Get Target Device Info
    override func meshSetupDidRequestTargetDeviceInfo(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)

        self.showSetupFindStickerView()
    }

    func showSetupFindStickerView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupFindStickerViewController.self)) {
                let findStickerVC = MeshSetupFindStickerViewController.loadedViewController()
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
            if (!self.rewindTo(MeshSetupScanStickerViewController.self)) {
                let scanVC = MeshSetupScanStickerViewController.loadedViewController()
                scanVC.setup(didFindStickerCode: self.targetDeviceScanStickerViewCompleted)
                scanVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(scanVC, animated: true)
            }
        }
    }

    func targetDeviceScanStickerViewCompleted(dataMatrixString:String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        self.validateMatrix(dataMatrixString, targetDevice: true)
    }

    override func setTargetDeviceValidatedMatrix(dataMatrix: MeshSetupDataMatrix) {
        self.targetDeviceDataMatrix = dataMatrix
        self.showTargetGetReadyView()
    }

    func showTargetGetReadyView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupGetReadyViewController.self)) {
                let getReadyVC = MeshSetupGetReadyViewController.loadedViewController()
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
                    self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: error.description, preferredStyle: .alert)

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
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
    override func meshSetupDidRequestToLeaveNetwork(_ sender: MeshSetupStep, network: MeshSetupNetworkInfo) {
        currentStepType = type(of: sender)

        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.LeaveNetworkTitle, message: MeshSetupStrings.Prompt.LeaveNetworkText, preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.LeaveNetwork, style: .default) { action in
                    self.flowRunner.setTargetDeviceLeaveNetwork(leave: true)
                })

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.DontLeaveNetwork, style: .cancel) { action in
                    self.flowRunner.setTargetDeviceLeaveNetwork(leave: false)
                })

                self.present(self.alert!, animated: true)
            }
        }
    }



    //MARK: switch to control panel
    override func meshSetupDidRequestToSwitchToControlPanel(_ sender: MeshSetupStep, device: ParticleDevice) {
        currentStepType = type(of: sender)

        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.SwitchToControlPanelTitle, message: MeshSetupStrings.Prompt.SwitchToControlPanelText, preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.SwitchToControlPanel, style: .default) { action in
                    let vc = MeshSetupControlPanelUIManager.loadedViewController()
                    vc.setDevice(device, context: self.flowRunner.context)
                    let presentingVC = self.presentingViewController
                    NSLog("presentingVC = \(presentingVC)")
                    self.dismiss(animated: true) {
                        presentingVC?.present(vc, animated: true)
                    }
                })

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.DontSwitchToControlPanel, style: .cancel) { action in
                    self.flowRunner.setSwitchToControlPanel(switchToCP: false)
                })

                self.present(self.alert!, animated: true)
            }
        }
    }




    //MARK: stand alone or mesh
    override func meshSetupDidRequestToSelectStandAloneOrMeshSetup(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)

        showStandAloneOrMeshSetupView()
    }

    private func showStandAloneOrMeshSetupView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupStandAloneOrMeshSetupViewController.self)) {
                let setupVC = MeshSetupStandAloneOrMeshSetupViewController.loadedViewController()
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
    override func meshSetupDidRequestToShowInfo(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)

        showInfoView()
    }

    private func showInfoView() { //xenon joiner flow = activeInternetInterface == nil, userSelectedToSetupMesh = nil, userSelectedToCreateNetwork = nil
        //argon / boron joiner flow = activeInternetInterface != nil, userSelectedToSetupMesh = true, userSelectedToCreateNetwork = false

        //gateway flow = activeInternetInterface != nil, userSelectedToSetupMesh = true, userSelectedToCreateNetwork = true
        //standalone flow = activeInternetInterface != nil, userSelectedToSetupMesh = false, userSelectedToCreateNetwork = nil


        if let activeInternetInterface = self.flowRunner.context.targetDevice.activeInternetInterface, let userSelectedToSetupMesh = self.flowRunner.context.userSelectedToSetupMesh,
           self.flowRunner.context.userSelectedToCreateNetwork == nil || self.flowRunner.context.userSelectedToCreateNetwork! == true {
            switch activeInternetInterface {
                case .ethernet:
                    DispatchQueue.main.async {
                        if (!self.rewindTo(MeshSetupInfoEthernetViewController.self)) {
                            let infoVC = MeshSetupInfoEthernetViewController.loadedViewController()
                            infoVC.ownerStepType = self.currentStepType
                            infoVC.setup(didFinishScreen: self.infoViewCompleted, setupMesh: userSelectedToSetupMesh, deviceType: self.flowRunner.context.targetDevice.type!)
                            self.embededNavigationController.pushViewController(infoVC, animated: true)
                        }
                    }
                case .wifi:
                    DispatchQueue.main.async {
                        if (!self.rewindTo(MeshSetupInfoWifiViewController.self)) {
                            let infoVC = MeshSetupInfoWifiViewController.loadedViewController()
                            infoVC.ownerStepType = self.currentStepType
                            infoVC.setup(didFinishScreen: self.infoViewCompleted, setupMesh: userSelectedToSetupMesh, deviceType: self.flowRunner.context.targetDevice.type!)
                            self.embededNavigationController.pushViewController(infoVC, animated: true)
                        }
                    }
                case .ppp:
                    DispatchQueue.main.async {
                        if (!self.rewindTo(MeshSetupCellularInfoViewController.self)) {
                            let cellularInfoVC = MeshSetupCellularInfoViewController.loadedViewController()
                            cellularInfoVC.ownerStepType = self.currentStepType
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
                if (!self.rewindTo(MeshSetupInfoJoinerViewController.self)) {
                    let infoVC = MeshSetupInfoJoinerViewController.loadedViewController()
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
    override func meshSetupDidRequestToAddOneMoreDevice(_ sender: MeshSetupStep) {
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
        if (!self.rewindTo(MeshSetupSuccessViewController.self)) {
            let successVC = MeshSetupSuccessViewController.loadedViewController()
            successVC.ownerStepType = self.currentStepType
            successVC.allowBack = false
            successVC.setup(didSelectDone: self.successViewCompleted, deviceName: self.flowRunner.context.targetDevice.name!, networkName: self.flowRunner.context.selectedNetworkMeshInfo?.name)
            self.embededNavigationController.pushViewController(successVC, animated: true)
        }
    }

    private func showNetworkCreatedView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupNetworkCreatedViewController.self)) {
                let successVC = MeshSetupNetworkCreatedViewController.loadedViewController()
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
            self.dismiss(animated: true)
        } else {
            self.setupInitialViewController()
        }
    }


}


