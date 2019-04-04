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

    func actionNewWifi() {
        self.currentFlow = actionNewWifiFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    fileprivate let actionPairMeshFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepControlPanelFlowCompleted()
    ]

    func actionPairMesh() {
        self.currentFlow = actionPairMeshFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    fileprivate let actionPairEthernetFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepGetEthernetFeatureStatus(),
        StepControlPanelFlowCompleted()
    ]

    func actionPairEthernet() {
        self.currentFlow = actionPairEthernetFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    fileprivate let actionPairCellularFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepCheckHasNetworkInterfaces(),
        StepControlPanelFlowCompleted()
    ]

    func actionPairCellular() {
        self.currentFlow = actionPairCellularFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    fileprivate let actionToggleEthernetFeatureFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepEnsureCorrectEthernetFeatureStatus(),
        StepControlPanelFlowCompleted()
    ]

    func actionToggleEthernetFeature() {
        self.currentFlow = actionToggleEthernetFeatureFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }



    fileprivate let actionDeactivateSIMFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepEnsureCorrectSimState(),
        StepControlPanelFlowCompleted()
    ]

    func actionDeactivateSIM() {
        self.currentFlow = actionDeactivateSIMFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }



    fileprivate let actionActivateSIMFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepEnsureCorrectSimState(),
        StepControlPanelFlowCompleted()
    ]

    func actionActivateSIM() {
        self.currentFlow = actionActivateSIMFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }


    override func switchFlow() {
        self.currentFlow = nil
        self.currentStepIdx = 0
    }

    func stopCurrentFlow() {
        self.context.canceled = false

        self.currentStep?.reset()
        self.currentStep?.context = nil

        self.currentFlow = nil
        self.currentStepIdx = 0
    }


}

