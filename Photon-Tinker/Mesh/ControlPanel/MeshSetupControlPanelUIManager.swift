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
        self.targetDeviceDataMatrix = MeshSetupDataMatrix(serialNumber: device.serialNumber!, mobileSecret: device.mobileSecret!, deviceType: device.type)
        self.flowRunner = MeshSetupControlPanelFlowManager(delegate: self, context: context)
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
                break
            case .cellular:
                controlPanelManager.actionPairCellular()
                break
            case .ethernet:
                controlPanelManager.actionPairEthernet()
                break
            case .wifi:
                showControlPanelWifiView()
            default:
                fatalError("cellType \(action) should never be returned")
        }
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
        let alert = UIAlertController(title: "Unclaim confirmation", message: "Are you sure you want to remove this device from your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
            action in
            if let vc = self.embededNavigationController.topViewController as? MeshSetupViewController {
                vc.resume(animated: false)
            }
        })
        alert.addAction(UIAlertAction(title: "Unclaim", style: .default) { action in
            self.unclaim()
        })
        self.present(alert, animated: true)
    }

    private func unclaim() {
        self.device.unclaim() { (error: Error?) -> Void in
            if let error = error as? NSError {
                self.showNetworkError(error: error)
            } else {
                DispatchQueue.main.async {
                    (self.presentingViewController as! UINavigationController).popViewController(animated: false)
                    self.dismiss(animated: true)
                }
            }
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
                break

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
            case .actionActivateSim:
                controlPanelManager.context.targetDevice.setSimActive = true
                controlPanelManager.actionActivateSIM()
            case .actionDeactivateSim:
                controlPanelManager.context.targetDevice.setSimActive = false
                controlPanelManager.actionDeactivateSIM()
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
            case .actionMeshNetworkInfo:
                showMeshNetworkInfo()
            case .actionJoinNetwork:
                break
            case .actionCreateNetwork:
                break
            case .actionLeaveNetwork:
                break
            case .actionPromoteToGateway:
                break
            case .actionDemoteFromGateway:
                break

            default:
                fatalError("cellType \(action) should never be returned")
        }
    }

    private func showMeshNetworkInfo() {
        self.currentAction = .mesh
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelMeshNetworkInfoViewController.self)) {
                let meshVC = MeshSetupControlPanelMeshNetworkInfoViewController.loadedViewController()
                meshVC.setup(device: self.device, context: self.controlPanelManager.context)
                meshVC.ownerStepType = nil
                self.embededNavigationController.pushViewController(meshVC, animated: true)
            }
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
            case .actionActivateEthernet:
                controlPanelManager.context.targetDevice.enableEthernetDetectionFeature = true
                controlPanelManager.actionToggleEthernetFeature()
            case .actionDeactivateEthernet:
                controlPanelManager.context.targetDevice.enableEthernetDetectionFeature = false
                controlPanelManager.actionToggleEthernetFeature()
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
            case .actionNewWifi, .actionManageWifi,
                 .actionActivateEthernet, .actionDeactivateEthernet,
                 .actionDeactivateSim, .actionActivateSim, .actionChangeDataLimit:
                showFlowCompleteView()
            case .mesh:
                showControlPanelMeshView()
            case .ethernet:
                showControlPanelEthernetView()
            case .cellular:
                showControlPanelCellularView()
            default:
                break;
        }
    }


    private func showFlowCompleteView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelFlowCompleteViewController.self)) {
                let flowCompleteVC = MeshSetupControlPanelFlowCompleteViewController.loadedViewController()
                flowCompleteVC.setup(didFinishScreen: self.flowCompleteViewCompleted, deviceType: self.device.type, deviceName: self.device.name!, action: self.currentAction!)
                flowCompleteVC.ownerStepType = nil
                self.embededNavigationController.pushViewController(flowCompleteVC, animated: true)
            }
        }
    }

    internal func flowCompleteViewCompleted() {
        switch currentAction! {
            case .actionNewWifi, .actionManageWifi:
                showControlPanelWifiView()
            case .actionDeactivateSim, .actionActivateSim, .actionChangeDataLimit:
                currentAction = .cellular
                controlPanelManager.actionPairCellular()
            case .actionActivateEthernet, .actionDeactivateEthernet:
                currentAction = .ethernet
                controlPanelManager.actionPairEthernet()
            default:
                break;
        }
    }

    override func meshSetupDidRequestToSelectSimDataLimit(_ sender: MeshSetupStep) {
        self.currentStepType = type(of: sender)
        showSimDataLimitView()
    }

    private func showSimDataLimitView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelSimDataLimitViewController.self)) {
                let dataLimitVC = MeshSetupControlPanelSimDataLimitViewController.loadedViewController()
                dataLimitVC.setup(currentLimit: self.controlPanelManager.context.targetDevice.sim!.dataLimit!, callback: self.simDataLimitViewCompleted)
                dataLimitVC.ownerStepType = self.currentStepType
                self.embededNavigationController.pushViewController(dataLimitVC, animated: true)
            }
        }
    }

    private func simDataLimitViewCompleted(limit: Int) {
        self.controlPanelManager.setSimDataLimit(dataLimit: limit)
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

    internal func showNetworkError(error: NSError) {
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle,
                        message: error.localizedDescription,
                        preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Cancel, style: .cancel) { action in
                    if let vc = self.embededNavigationController.topViewController as? MeshSetupViewController {
                        vc.resume(animated: false)
                    }
                })

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                    self.unclaim()
                })

                self.present(self.alert!, animated: true)
            }
        }
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
        if error == .FailedToScanBecauseOfTimeout {
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
