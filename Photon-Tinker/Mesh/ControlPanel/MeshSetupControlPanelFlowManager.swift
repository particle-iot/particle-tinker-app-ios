//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelFlowManager : MeshSetupFlowRunner {



    fileprivate let actionNewWifiFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepGetUserWifiNetworkSelection(),
        StepEnsureCorrectSelectedWifiNetworkPassword(),
        StepControlPanelFlowCompleted()
    ]

    fileprivate let actionPairMeshFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepControlPanelFlowCompleted()
    ]

    fileprivate let actionPairEthernetFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepGetEthernetFeatureStatus(),
        StepControlPanelFlowCompleted()
    ]

    fileprivate let actionPairCellularFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepControlPanelFlowCompleted()
    ]

    fileprivate let actionToggleEthernetFeatureFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepEnsureCorrectEthernetFeatureStatus(),
        StepControlPanelFlowCompleted()
    ]


    func actionNewWifi() {
        self.currentFlow = actionNewWifiFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    func actionPairMesh() {
        self.currentFlow = actionPairMeshFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    func actionPairEthernet() {
        self.currentFlow = actionPairEthernetFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    func actionPairCellular() {
        self.currentFlow = actionPairCellularFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }


    override func switchFlow() {
        self.currentFlow = nil
        self.currentStepIdx = 0
    }

    func stopCurrentFlow() {
        self.currentStep?.reset()
        self.currentStep?.context = nil

        self.currentFlow = nil
        self.currentStepIdx = 0
    }

    func actionToggleEthernetFeature() {
        self.currentFlow = actionToggleEthernetFeatureFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }
}

