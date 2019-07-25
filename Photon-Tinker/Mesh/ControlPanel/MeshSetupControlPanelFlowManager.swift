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
        StepExitListeningMode(),
        StepGetWifiNetwork(),
        StepControlPanelFlowCompleted()
    ]

    func actionNewWifi() {
        self.currentFlow = actionNewWifiFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }


    fileprivate let actionManageWifiFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepExitListeningMode(),
        StepGetKnownWifiNetworks(),
        StepControlPanelFlowCompleted()
    ]

    func actionManageWifi() {
        self.currentFlow = actionManageWifiFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }


    fileprivate let actionRemoveWifiCredentialsFlow:[MeshSetupStep] = [
        StepRemoveSelectedWifiCredentials(),
        StepGetKnownWifiNetworks(),
        StepControlPanelFlowCompleted()
    ]

    func actionRemoveWifiCredentials() {
        self.currentFlow = actionRemoveWifiCredentialsFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    fileprivate let actionPairMeshFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepExitListeningMode(),
        StepGetMeshNetwork(),
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
        StepExitListeningMode(),
        StepGetEthernetFeatureStatus(),
        StepControlPanelFlowCompleted()
    ]

    func actionPairEthernet() {
        self.currentFlow = actionPairEthernetFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    fileprivate let actionPairWifiFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepExitListeningMode(),
        StepGetWifiNetwork(),
        StepControlPanelFlowCompleted()
    ]

    func actionPairWifi() {
        self.currentFlow = actionPairWifiFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }

    fileprivate let actionPairCellularFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepExitListeningMode(),
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
        StepExitListeningMode(),
        StepEnsureCorrectEthernetFeatureStatus(),
        StepControlPanelFlowCompleted()
    ]

    func actionToggleEthernetFeature() {
        self.currentFlow = actionToggleEthernetFeatureFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }




    fileprivate let actionToggleSimStatusFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepExitListeningMode(),
        StepShowInfo(.simStatusToggle),
        StepEnsureCorrectSimState(),
        StepControlPanelFlowCompleted()
    ]

    func actionToggleSimStatus() {
        self.currentFlow = actionToggleSimStatusFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }



    fileprivate let actionChangeDataLimitFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepExitListeningMode(),
        StepSetSimDataLimit(),
        StepControlPanelFlowCompleted()
    ]

    func actionChangeDataLimit() {
        self.currentFlow = actionChangeDataLimitFlow
        self.currentStepIdx = 0
        self.runCurrentStep()
    }


    fileprivate let actionLeaveMeshNetworkFlow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepEnsureNotOnMeshNetwork(),
        StepControlPanelFlowCompleted()
    ]

    func actionLeaveMeshNetwork() {
        self.currentFlow = actionLeaveMeshNetworkFlow
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

