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

    func setDevice(_ device: ParticleDevice) {
        self.device = device
        self.targetDeviceDataMatrix = MeshSetupDataMatrix(serialNumber: device.serialNumber!, mobileSecret: device.mobileSecret!, deviceType: device.type)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.flowRunner = MeshSetupControlPanelFlowManager(delegate: self)
    }

    override internal func setupInitialViewController() {
        self.currentStepType = nil

        let rootVC = MeshSetupControlPanelRootViewController.loadedViewController()
        rootVC.setup(device: self.device, didSelectAction: self.controlPanelRootViewCompleted)
        rootVC.ownerStepType = nil
        self.embededNavigationController.setViewControllers([rootVC], animated: false)
    }


    private func showControlPanelRootView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelRootViewController.self)) {
                let rootVC = MeshSetupControlPanelRootViewController.loadedViewController()
                rootVC.setup(device: self.device, didSelectAction: self.controlPanelRootViewCompleted)
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
                wifiVC.setup(device: self.device, didSelectAction: self.controlPanelWifiViewCompleted)
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
        showFlowCompleteView()

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
            default:
                break;
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
        if error != .FailedToScanBecauseOfTimeout {
            super.meshSetupError(sender, error: error, severity: severity, nsError: nsError)
        } else {
            self.flowRunner.retryLastAction()
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
