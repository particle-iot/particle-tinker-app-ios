//
// Created by Raimundas Sakalauskas on 2019-03-01.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation


class MeshSetupFlowManager : MeshSetupFlowRunner {

    fileprivate let preflow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepEnsureCorrectEthernetFeatureStatus(),
        StepEnsureLatestFirmware(),
        StepGetAPINetworks(),
        StepEnsureTargetDeviceCanBeClaimed(),
        StepEnsureTargetDeviceIsNotOnMeshNetwork(),
        SetClaimCode(),
        StepCheckTargetDeviceHasNetworkInterfaces(),
    ]

    fileprivate let joinerFlow: [MeshSetupStep] = [
        StepShowInfo(),
        StepGetUserNetworkSelection(),
        StepGetCommissionerDeviceInfo(),
        StepConnectToCommissionerDevice(),
        StepEnsureCommissionerNetworkMatches(),
        StepEnsureCorrectSelectedNetworkPassword(),
        StepJoinSelectedNetwork(),
        StepFinishJoinSelectedNetwork(),
        StepCheckDeviceGotClaimed(),
        StepPublishDeviceSetupDoneEvent(),
        StepGetNewDeviceName(),
        StepOfferToAddOneMoreDevice()
    ]

    //runs before ethernet/wifi/cellular flows
    fileprivate let internetConnectedPreflow: [MeshSetupStep] = [
        StepOfferSetupStandAloneOrWithNetwork(),
        StepOfferSelectOrCreateNetwork()
    ]


    fileprivate let ethernetFlow: [MeshSetupStep] = [
        StepShowPricingImpact(),
        StepShowInfo(),
        StepEnsureHasInternetAccess(),
        StepCheckDeviceGotClaimed(),
        StepPublishDeviceSetupDoneEvent()
    ]

    fileprivate let wifiFlow: [MeshSetupStep] = [
        StepShowPricingImpact(),
        StepShowInfo(),
        StepGetUserWifiNetworkSelection(),
        StepEnsureCorrectSelectedWifiNetworkPassword(),
        StepEnsureHasInternetAccess(),
        StepCheckDeviceGotClaimed(),
        StepPublishDeviceSetupDoneEvent()
    ]

    fileprivate let cellularFlow: [MeshSetupStep] = [
        StepShowPricingImpact(),
        StepShowInfo(),
        StepEnsureHasInternetAccess(),
        StepCheckDeviceGotClaimed(),
        StepPublishDeviceSetupDoneEvent()
    ]

    //runs post ethernet/wifi/cellular flows
    fileprivate let networkCreatorPostflow: [MeshSetupStep] = [
        StepGetNewDeviceName(),
        StepGetNewNetworkName(),
        StepGetNewNetworkPassword(),
        StepCreateNetwork(),
        StepEnsureHasInternetAccess(),
        StepMakeTargetACommissioner(),
        StepOfferToAddOneMoreDevice()
    ]

    //runs post ethernet/wifi/cellular flows
    fileprivate let standalonePostflow: [MeshSetupStep] = [
        StepGetNewDeviceName(),
        StepOfferToAddOneMoreDevice()
    ]

    //entry to the flow
    func startSetup() {
        currentFlow = preflow
        currentStepIdx = 0

        self.runCurrentStep()
    }

    //this is for internal use only, because it requires a lot of internal knowledge to use and is nearly impossible to expose to external developers
    override internal func rewindTo(step: MeshSetupStep.Type) -> MeshSetupFlowError? {
        currentStep!.rewindFrom()

        if (currentStepIdx == 0) {
            //if we are backing from one of these flows, we need to switch the flow type.
            if (currentFlow == joinerFlow || currentFlow == ethernetFlow || currentFlow == wifiFlow || currentFlow == cellularFlow) {
                currentFlow = internetConnectedPreflow
            }
            currentStepIdx = internetConnectedPreflow.count
            self.log("Rewinding flow to internetConnectedPreflow")
        }

        for i in 0 ..< self.currentFlow.count {
            if (self.currentFlow[i].isKind(of: step)) {
                if (i >= self.currentStepIdx) {
                    //trying to "rewind" forward
                    return .IllegalOperation
                }

                self.currentStepIdx = i
                self.log("returning to step: \(self.currentStepIdx)")
                self.currentStep!.rewindTo(context: self.context)
                self.runCurrentStep()

                return nil
            }
        }

        return .IllegalOperation
    }

    override internal func switchFlow() {
        log("stepComplete\n\n" +
                "--------------------------------------------------------------------------------------------\n" +
                "Switching flow!!!")

        if (currentFlow == preflow) {
            if (context.targetDevice.hasActiveInternetInterface() && context.selectedNetworkMeshInfo == nil) {
                self.currentFlow = internetConnectedPreflow
                log("setting gateway flow")
            } else {
                //if context.targetDevice.hasActiveInternetInterface() == argon/boron/ethernet joiner flow

                log("setting xenon joiner flow")
                self.currentFlow = joinerFlow
            }
        } else if (currentFlow == internetConnectedPreflow) {
            if (context.userSelectedToSetupMesh! == false || context.userSelectedToCreateNetwork! == true) {
                //if user wants to go standalone or create network
                if (context.targetDevice.activeInternetInterface! == .ethernet) {
                    self.currentFlow = ethernetFlow
                    log("setting ethernetFlow flow")
                } else if (context.targetDevice.activeInternetInterface! == .wifi) {
                    self.currentFlow = wifiFlow
                    log("setting wifiFlow flow")
                } else if (context.targetDevice.activeInternetInterface! == .ppp) {
                    self.currentFlow = cellularFlow
                    log("setting cellularFlow flow")
                } else {
                    fatalError("wrong state?")
                }
            } else {  //if (context.selectedNetworkMeshInfo != nil)
                self.currentFlow = joinerFlow
            }
        } else if (currentFlow == ethernetFlow || self.currentFlow == wifiFlow || self.currentFlow == cellularFlow) {
            if (context.userSelectedToSetupMesh!) {
                self.currentFlow = networkCreatorPostflow
                log("setting creatorSubflow flow")
            } else {
                self.currentFlow = standalonePostflow
                log("setting standaloneSubflow flow")
            }
        } else {
            fatalError("no flow to switch to")
        }

        self.currentStepIdx = 0
    }



    override func setAddOneMoreDevice(addOneMoreDevice: Bool) -> MeshSetupFlowError? {
        guard type(of: currentStep!) == StepOfferToAddOneMoreDevice.self else {
            return .IllegalOperation
        }

        if (addOneMoreDevice) {
            self.currentStepIdx = 0
            self.currentFlow = preflow
            self.runCurrentStep()
        } else {
            self.finishSetup()
        }

        return nil
    }
}

