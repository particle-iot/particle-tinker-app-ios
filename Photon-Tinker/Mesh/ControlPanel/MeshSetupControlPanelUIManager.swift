//
// Created by Raimundas Sakalauskas on 2019-03-14.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import MessageUI

class MeshSetupControlPanelUIManager: MeshSetupUIBase {

    private var currentAction: MeshSetupControlPanelCellType?

    var controlPanelManager: MeshSetupControlPanelFlowManager! {
        return self.flowRunner as! MeshSetupControlPanelFlowManager
    }

    private var device: ParticleDevice!

    func setDevice(_ device: ParticleDevice, context: MeshSetupContext? = nil) {
        self.device = device
        if let serial = device.serialNumber, let mobileSecret = device.mobileSecret {
            self.targetDeviceDataMatrix = MeshSetupDataMatrix(serialNumber: device.serialNumber!, mobileSecret: device.mobileSecret!, deviceType: device.type)
        }

        self.flowRunner = MeshSetupControlPanelFlowManager(delegate: self, context: context)

        self.flowRunner.context.targetDevice.deviceId = self.device.id
        self.flowRunner.context.targetDevice.name = self.device.getName()
        self.flowRunner.context.targetDevice.notes = self.device.notes
        self.flowRunner.context.targetDevice.networkRole = self.device.networkRole
    }

    override internal func setupInitialViewController() {
        self.currentStepType = nil

        let rootVC = MeshSetupControlPanelRootViewController.loadedViewController()
        rootVC.setup(device: self.device, context: controlPanelManager.context, didSelectAction: self.controlPanelRootViewCompleted)
        rootVC.ownerStepType = nil
        self.embededNavigationController.setViewControllers([rootVC], animated: false)
    }


    private func showControlPanelRootView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelRootViewController.self)) {
                let rootVC = MeshSetupControlPanelRootViewController.loadedViewController()
                rootVC.setup(device: self.device, context: self.controlPanelManager.context, didSelectAction: self.controlPanelRootViewCompleted)
                rootVC.ownerStepType = nil
                self.embededNavigationController.setViewControllers([rootVC], animated: true)
            }
        }
    }

    func controlPanelRootViewCompleted(action: MeshSetupControlPanelCellType) {
        currentAction = action

        switch action {
            case .documentation:
                showDocumentation()
            case .unclaim:
                showUnclaim()
            case .mesh:
                controlPanelManager.actionPairMesh()
            case .cellular:
                controlPanelManager.actionPairCellular()
            case .ethernet:
                controlPanelManager.actionPairEthernet()
            case .wifi:
                controlPanelManager.actionPairWifi()
            case .notes:
                editNotes()
            case .name:
                rename()
            default:
                fatalError("cellType \(action) should never be returned")
        }
    }

    func rename() {
        var vc = DeviceInspectorTextInputViewController.storyboardViewController()
        vc.setup(caption: "Name", multiline: false, value: self.device.name, blurBackground: false, onCompletion: {
            [weak self] value in
            if let self = self {
                self.device.rename(value) { error in
                    if let error = error {
                        RMessage.showNotification(withTitle: "Error", subtitle: "Error renaming device: \(error.localizedDescription)", type: .error, customTypeName: nil, callback: nil)
                        vc.resume(animated: true)
                    } else {
                        self.controlPanelManager.context.targetDevice.name = self.device.getName()
                        let root = self.embededNavigationController!.topViewController as! MeshSetupViewController
                        root.resume(animated: false)
                        vc.dismiss(animated: true)
                    }
                }
            }
        })
        self.present(vc, animated: true)

    }


    func editNotes() {
        var vc = DeviceInspectorTextInputViewController.storyboardViewController()
        vc.setup(caption: "Notes", multiline: true, value: self.device.notes, blurBackground: false, onCompletion: {
            [weak self] value in
            if let self = self {
                self.device.setNotes(value) { error in
                    if let error = error {
                        RMessage.showNotification(withTitle: "Error", subtitle: "Error editing notes device: \(error.localizedDescription)", type: .error, customTypeName: nil, callback: nil)
                        vc.resume(animated: true)
                    } else {
                        self.controlPanelManager.context.targetDevice.notes = self.device.notes
                        let root = self.embededNavigationController!.topViewController as! MeshSetupViewController
                        root.resume(animated: false)
                        vc.dismiss(animated: true)
                    }
                }
            }

        })
        self.present(vc, animated: true)
    }

    private func showDocumentation() {
        DispatchQueue.main.async {
            let wifiVC = MeshSetupControlPanelDocumentationViewController.loadedViewController()
            wifiVC.setup(self.device)
            wifiVC.ownerStepType = nil
            self.embededNavigationController.pushViewController(wifiVC, animated: true)
        }
    }

    private func showUnclaim() {
        self.currentAction = .unclaim
        DispatchQueue.main.async {
            let unclaimVC = MeshSetupControlPanelUnclaimViewController.loadedViewController()
            unclaimVC.setup(deviceName: self.device.name!, callback: self.unclaimCompleted)
            unclaimVC.ownerStepType = nil
            self.embededNavigationController.pushViewController(unclaimVC, animated: true)
        }
    }

    func unclaimCompleted(unclaimed: Bool) {
        if (unclaimed) {
            self.unclaim()
        }
    }

    private func unclaim() {
        self.device.unclaim() { (error: Error?) -> Void in
            if let error = error as? NSError {
                self.showNetworkError(error: error)
            } else {
                if let callback = self.callback {
                    callback(MeshSetupFlowResult.unclaimed)
                }
                self.terminate()
            }
        }
    }

    internal func showNetworkError(error: NSError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle,
                    message: error.localizedDescription,
                    preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: MeshSetupStrings.Action.Cancel, style: .cancel) { action in
                (self.embededNavigationController.topViewController! as! Fadeable).resume(animated: true)
            })

            alert.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                self.unclaim()
            })

            self.present(alert, animated: true)
        }
    }




    private func showControlPanelWifiView() {
        self.currentAction = .wifi
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelWifiViewController.self)) {
                let wifiVC = MeshSetupControlPanelWifiViewController.loadedViewController()
                wifiVC.setup(device: self.device, context: self.controlPanelManager.context, didSelectAction: self.controlPanelWifiViewCompleted)
                wifiVC.ownerStepType = nil
                self.embededNavigationController.pushViewController(wifiVC, animated: true)
            }
        }
    }

    func controlPanelWifiViewCompleted(action: MeshSetupControlPanelCellType) {
        currentAction = action
        switch action {
            case .actionNewWifi:
                controlPanelManager.actionNewWifi()
            case .actionManageWifi:
                controlPanelManager.actionManageWifi()
            case .wifi:
                controlPanelManager.actionPairWifi()
            default:
                fatalError("cellType \(action) should never be returned")
        }
    }

    private func showControlPanelCellularView() {
        self.currentAction = .cellular
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelCellularViewController.self)) {
                let cellularVC = MeshSetupControlPanelCellularViewController.loadedViewController()
                cellularVC.setup(device: self.device, context: self.controlPanelManager.context, didSelectAction: self.controlPanelCellularViewCompleted)
                cellularVC.ownerStepType = nil
                self.embededNavigationController.pushViewController(cellularVC, animated: true)
            }
        }
    }

    func controlPanelCellularViewCompleted(action: MeshSetupControlPanelCellType) {
        currentAction = action
        switch action {
            case .actionChangeSimStatus:
                if controlPanelManager.context.targetDevice.sim!.status! == .activate {
                    controlPanelManager.context.targetDevice.setSimActive = false
                    controlPanelManager.actionToggleSimStatus()
                } else if (controlPanelManager.context.targetDevice.sim!.status! == .inactiveDataLimitReached) {
                    controlPanelManager.context.targetDevice.setSimActive = true
                    controlPanelManager.actionToggleSimStatus()
                } else {
                    controlPanelManager.context.targetDevice.setSimActive = true
                    controlPanelManager.actionToggleSimStatus()
                }
            case .actionChangeDataLimit:
                controlPanelManager.actionChangeDataLimit()
            default:
                fatalError("cellType \(action) should never be returned")
        }
    }

    private func showControlPanelMeshView() {
        self.currentAction = .mesh
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelMeshViewController.self)) {
                let meshVC = MeshSetupControlPanelMeshViewController.loadedViewController()
                meshVC.setup(device: self.device, context: self.controlPanelManager.context, didSelectAction: self.controlPanelMeshViewCompleted)
                meshVC.ownerStepType = nil
                self.embededNavigationController.pushViewController(meshVC, animated: true)
            }
        }
    }

    func controlPanelMeshViewCompleted(action: MeshSetupControlPanelCellType) {
        currentAction = action
        switch action {
            case .actionAddToMeshNetwork:
                controlPanelManager.context.userSelectedToSetupMesh = true
                controlPanelManager.actionAddToMesh()
            case .actionLeaveMeshNetwork:
                controlPanelManager.context.targetDevice.networkRole = nil
                controlPanelManager.context.userSelectedToLeaveNetwork = true
                controlPanelManager.actionLeaveMeshNetwork()
            case .mesh:
                controlPanelManager.actionPairMesh()
            case .actionPromoteToGateway:
                break
            case .actionDemoteFromGateway:
                break

            default:
                fatalError("cellType \(action) should never be returned")
        }
    }

    private func showControlPanelEthernetView() {
        self.currentAction = .ethernet
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelEthernetViewController.self)) {
                let ethernetVC = MeshSetupControlPanelEthernetViewController.loadedViewController()
                ethernetVC.setup(device: self.device, context: self.controlPanelManager.context, didSelectAction: self.controlPanelEthernetViewCompleted)
                ethernetVC.ownerStepType = nil
                self.embededNavigationController.pushViewController(ethernetVC, animated: true)
            }
        }
    }

    func controlPanelEthernetViewCompleted(action: MeshSetupControlPanelCellType) {
        currentAction = action
        switch action {
            case .actionChangePinsStatus:
                if (controlPanelManager.context.targetDevice.ethernetDetectionFeature!) {
                    controlPanelManager.context.targetDevice.enableEthernetDetectionFeature = false
                    controlPanelManager.actionToggleEthernetFeature()
                } else {
                    controlPanelManager.context.targetDevice.enableEthernetDetectionFeature = true
                    controlPanelManager.actionToggleEthernetFeature()
                }
            default:
                fatalError("cellType \(action) should never be returned")
        }
    }

    private func showPrepareForPairingView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelPrepareForPairingViewController.self)) {
                let prepareVC = MeshSetupControlPanelPrepareForPairingViewController.loadedViewController()
                prepareVC.setup(device: self.device)
                prepareVC.ownerStepType = nil
                self.embededNavigationController.pushViewController(prepareVC, animated: true)
            }
        }
    }

    override func meshSetupDidCompleteControlPanelFlow(_ sender: MeshSetupStep) {
        switch currentAction! {
            case .actionNewWifi,
                 .actionChangePinsStatus,
                 .actionChangeSimStatus, .actionChangeDataLimit,
                 .actionLeaveMeshNetwork:
                showFlowCompleteView()
            case .mesh:
                showControlPanelMeshView()
            case .ethernet:
                showControlPanelEthernetView()
            case .wifi:
                showControlPanelWifiView()
            case .cellular:
                showControlPanelCellularView()
            case .actionManageWifi:
                showManageWifiView()
            case .actionAddToMeshNetwork:
                controlPanelManager.context.userSelectedToCreateNetwork = nil
                controlPanelManager.context.selectedNetworkMeshInfo = nil
                controlPanelManager.context.selectedNetworkPassword = nil

                controlPanelManager.context.newNetworkName = nil
                controlPanelManager.context.newNetworkPassword = nil
                controlPanelManager.context.newNetworkId = nil


                currentAction = .mesh
                controlPanelManager.actionPairMesh()
            default:
                break;
        }
    }

    private func showFlowCompleteView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelFlowCompleteViewController.self)) {
                let flowCompleteVC = MeshSetupControlPanelFlowCompleteViewController.loadedViewController()
                flowCompleteVC.setup(didFinishScreen: self.flowCompleteViewCompleted, deviceType: self.device.type, deviceName: self.device.name!, action: self.currentAction!, context: self.controlPanelManager.context)
                flowCompleteVC.ownerStepType = nil
                self.embededNavigationController.pushViewController(flowCompleteVC, animated: true)
            }
        }
    }

    internal func flowCompleteViewCompleted() {
        switch currentAction! {
            case .actionNewWifi:
                controlPanelManager.context.selectedWifiNetworkInfo = nil

                currentAction = .wifi
                controlPanelManager.actionPairWifi()
            case .actionChangeSimStatus, .actionChangeDataLimit:
                controlPanelManager.context.targetDevice.setSimDataLimit = nil
                controlPanelManager.context.targetDevice.setSimActive = nil

                currentAction = .cellular
                controlPanelManager.actionPairCellular()
            case .actionChangePinsStatus:
                controlPanelManager.context.targetDevice.enableEthernetDetectionFeature = nil

                currentAction = .ethernet
                controlPanelManager.actionPairEthernet()
            case .actionLeaveMeshNetwork:
                controlPanelManager.context.userSelectedToLeaveNetwork = nil

                currentAction = .mesh
                controlPanelManager.actionPairMesh()
            default:
                break;
        }
    }

    override func meshSetupDidRequestToShowInfo(_ sender: MeshSetupStep) {
        currentStepType = type(of: sender)
        let infoType = (sender as! StepShowInfo).infoType

        if infoType == .joinerFlow {
            if (!self.rewindTo(MeshSetupInfoJoinerViewController.self)) {
                let infoVC = MeshSetupInfoJoinerViewController.loadedViewController()
                infoVC.allowBack = true
                infoVC.ownerStepType = self.currentStepType
                infoVC.setup(didFinishScreen: self.infoViewCompleted, setupMesh: self.flowRunner.context.userSelectedToSetupMesh, deviceType: self.flowRunner.context.targetDevice.type!)
                self.embededNavigationController.pushViewController(infoVC, animated: true)
            }
        } else {
            if controlPanelManager.context.targetDevice.sim!.status! == .activate {
                showDeactivateSimInfoView()
            } else if (controlPanelManager.context.targetDevice.sim!.status! == .inactiveDataLimitReached) {
                showResumeSimInfoView()
            } else {
                showActivateSimInfoView()
            }
        }
    }

    func infoViewCompleted() {
        self.flowRunner.setInfoDone()
    }

    private func showManageWifiView() {
        DispatchQueue.main.async {
            if let manageWifiView = self.embededNavigationController.topViewController as? MeshSetupControlPanelManageWifiViewController {
                manageWifiView.setNetworks(networks: self.controlPanelManager.context.targetDevice.knownWifiNetworks!)
            }

            if (!self.rewindTo(MeshSetupControlPanelManageWifiViewController.self)) {
                let manageWifiView = MeshSetupControlPanelManageWifiViewController.loadedViewController()
                manageWifiView.setup(didSelectNetwork: self.selectKnownWifiNetworkViewCompleted)
                manageWifiView.setNetworks(networks: self.controlPanelManager.context.targetDevice.knownWifiNetworks!)
                manageWifiView.ownerStepType = nil
                self.embededNavigationController.pushViewController(manageWifiView, animated: true)
            }
        }
    }

    internal func selectKnownWifiNetworkViewCompleted(network: MeshSetupKnownWifiNetworkInfo) {
        self.controlPanelManager.context.selectedForRemovalWifiNetworkInfo = network
        self.controlPanelManager.actionRemoveWifiCredentials()
    }

    private func showDeactivateSimInfoView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelInfoDeactivateSimViewController.self)) {
                let infoView = MeshSetupControlPanelInfoDeactivateSimViewController.loadedViewController()
                infoView.setup(context: self.controlPanelManager.context, didFinish: self.simInfoViewCompleted)
                infoView.ownerStepType = nil
                self.embededNavigationController.pushViewController(infoView, animated: true)
            }
        }
    }

    private func showActivateSimInfoView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelInfoActivateSimViewController.self)) {
                let infoView = MeshSetupControlPanelInfoActivateSimViewController.loadedViewController()
                infoView.setup(context: self.controlPanelManager.context, didFinish: self.simInfoViewCompleted)
                infoView.ownerStepType = nil
                self.embededNavigationController.pushViewController(infoView, animated: true)
            }
        }
    }

    private func showResumeSimInfoView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelInfoResumeSimViewController.self)) {
                let infoView = MeshSetupControlPanelInfoResumeSimViewController.loadedViewController()
                infoView.setup(context: self.controlPanelManager.context, didFinish: self.simInfoViewCompleted, requestShowDataLimit: self.requestShowDataLimit)
                infoView.ownerStepType = nil
                self.embededNavigationController.pushViewController(infoView, animated: true)
            }
        }
    }

    func simInfoViewCompleted() {
        self.controlPanelManager.setInfoDone()
    }

    func requestShowDataLimit() {
        self.showSimDataLimitView()
    }



    override func meshSetupDidRequestToSelectSimDataLimit(_ sender: MeshSetupStep) {
        self.currentStepType = type(of: sender)
        showSimDataLimitView()
    }

    private func showSimDataLimitView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelSimDataLimitViewController.self)) {
                let dataLimitVC = MeshSetupControlPanelSimDataLimitViewController.loadedViewController()
                dataLimitVC.setup(currentLimit: self.controlPanelManager.context.targetDevice.sim!.dataLimit!,
                        disableValuesSmallerThanCurrent: self.currentAction == .actionChangeDataLimit ? false : true,
                        callback: self.simDataLimitViewCompleted)
                dataLimitVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(dataLimitVC, animated: true)
            }
        }
    }

    private func simDataLimitViewCompleted(limit: Int) {
        if (self.currentAction == .actionChangeDataLimit) {
            self.controlPanelManager.setSimDataLimit(dataLimit: limit)
        } else {
            //adjust value in context and pop to previous view
            self.controlPanelManager.context.targetDevice.setSimDataLimit = limit
            showResumeSimInfoView()
        }
    }

    override func meshSetupDidRequestTargetDeviceInfo(_ sender: MeshSetupStep) {
        self.controlPanelManager.setTargetDeviceInfo(dataMatrix: self.targetDeviceDataMatrix!)
    }

    override func targetPairingProcessViewCompleted() {
        //remove last two views, because they will prevent back from functioning properly
        self.embededNavigationController.popViewController(animated: false)
        self.embededNavigationController.popViewController(animated: false)

        super.targetPairingProcessViewCompleted()
    }


    internal func showExternalSim() {
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle,
                        message: MeshSetupStrings.Prompt.ControlPanelExternalSimNotSupportedText,
                        preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
                    (self.embededNavigationController.topViewController as? MeshSetupViewController)?.resume(animated: true)
                })

                self.present(self.alert!, animated: true)
            }
        }
    }

    override func meshSetupDidEnterState(_ sender: MeshSetupStep, state: MeshSetupFlowState) {
        super.meshSetupDidEnterState(sender, state: state)

        switch state {
            case .TargetDeviceConnecting:
                showPrepareForPairingView()
            case .TargetDeviceDiscovered:
                showTargetPairingProcessView()
            default:
                break
        }
    }


    override func meshSetupError(_ sender: MeshSetupStep, error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?) {
        //don't show timeout error when pairing to target device
        if error == .FailedToScanBecauseOfTimeout,  let currentStep = flowRunner.currentStep, type(of: currentStep) == StepConnectToTargetDevice.self {
            self.flowRunner.retryLastAction()
        } else if (error == .ExternalSimNotSupported) {
            self.controlPanelManager.stopCurrentFlow()
            self.showExternalSim()
        } else {
            super.meshSetupError(sender, error: error, severity: severity, nsError: nsError)
        }
    }

    @IBAction override func backTapped(_ sender: UIButton) {
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
                if (vcPrev.ownerStepType == nil) {
                    self.controlPanelManager.stopCurrentFlow()
                }

                log("Popping")
                self.embededNavigationController.popViewController(animated: true)
            }
        } else {
            log("Back button was pressed when it was not supposed to be pressed. Ignoring.")
        }
    }
}
