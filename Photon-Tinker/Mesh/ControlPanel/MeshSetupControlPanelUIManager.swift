//
// Created by Raimundas Sakalauskas on 2019-03-14.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import MessageUI

class MeshSetupControlPanelUIManager: MeshSetupUIBase {

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
        rootVC.setup(device: self.device, didSelectTo: self.didSelectRootView)
        rootVC.ownerStepType = nil
        self.embededNavigationController.setViewControllers([rootVC], animated: false)
    }


    private func showControlPanelRootView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelRootViewController.self)) {
                let rootVC = MeshSetupControlPanelRootViewController.loadedViewController()
                rootVC.setup(device: self.device, didSelectTo: self.didSelectRootView)
                rootVC.ownerStepType = nil
                self.embededNavigationController.setViewControllers([rootVC], animated: true)
            }
        }
    }

    func didSelectRootView() {
        showControlPanelWifiView()
    }



    private func showControlPanelWifiView() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupControlPanelWifiViewController.self)) {
                let wifiVC = MeshSetupControlPanelWifiViewController.loadedViewController()
                wifiVC.setup(device: self.device, didSelectTo: self.controlPanelWifiViewCompleted)
                wifiVC.ownerStepType = nil
                self.embededNavigationController.pushViewController(wifiVC, animated: true)
            }
        }
    }

    func controlPanelWifiViewCompleted() {
        self.controlPanelManager.addNewWifi()
    }

    override func meshSetupDidRequestTargetDeviceInfo(_ sender: MeshSetupStep) {
        self.controlPanelManager.setTargetDeviceInfo(dataMatrix: self.targetDeviceDataMatrix!)
    }
}
