//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelFlowManager : MeshSetupFlowRunner {

    fileprivate let addWifiFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepGetUserWifiNetworkSelection(),
        StepEnsureCorrectSelectedWifiNetworkPassword()
    ]

    func addNewWifi() {
        self.currentFlow = addWifiFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    override func switchFlow() {
        self.currentFlow = nil
        self.currentStepIdx = 0
    }
}

