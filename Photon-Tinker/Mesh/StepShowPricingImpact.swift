//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepShowPricingImpact : MeshSetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        //for boron / b series
        if let activeInternetInterface = context.targetDevice.activeInternetInterface, activeInternetInterface == .ppp {
            if (context.targetDevice.externalSim == nil) {
                self.getTargetDeviceActiveSim()
            } else if (context.targetDevice.deviceICCID == nil) {
                self.getTargetDeviceICCID()
            } else if (context.pricingInfo == nil) {
                self.getPricingImpact()
            } else {
                context.delegate.meshSetupDidRequestToShowPricingInfo(info: context.pricingInfo!)
            }
        } else if (context.pricingInfo == nil) {
            self.getPricingImpact()
        } else {
            context.delegate.meshSetupDidRequestToShowPricingInfo(info: context.pricingInfo!)
        }
    }

    private func getTargetDeviceActiveSim() {
        context?.targetDevice.transceiver!.sendGetActiveSim () { [weak self, weak context] result, externalSim in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.transceiver!.sendGetActiveSim: \(result.description()), externalSim: \(externalSim as Optional)")

            if (result == .NONE) {
                context.targetDevice.externalSim = externalSim!
                if (externalSim!) {
                    self.fail(withReason: .ExternalSimNotSupported, severity: .Fatal)
                } else {
                    self.start()
                }
            } else if (result == .INVALID_STATE) {
                self.fail(withReason: .BoronModemError)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func getTargetDeviceICCID() {
        context?.targetDevice.transceiver!.sendGetIccid () { [weak self, weak context] result, iccid in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.transceiver!.sendGetIccid: \(result.description()), iccid: \(iccid as Optional)")

            if (result == .NONE) {
                context.targetDevice.deviceICCID = iccid!
                self.start()
            } else if (result == .INVALID_STATE) {
                self.fail(withReason: .BoronModemError)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func getPricingImpact() {
        guard let context = self.context else {
            return
        }

        //joiner flow
        var action = ParticlePricingImpactAction.addNetworkDevice
        if let userSelectedToSetupMesh = context.userSelectedToSetupMesh {
            //standalone or network
            action = userSelectedToSetupMesh ? .createNetwork : .addUserDevice
        }

        var networkType = ParticlePricingImpactNetworkType.wifi
        if let interface = context.targetDevice.activeInternetInterface, interface == .ppp {
            networkType = ParticlePricingImpactNetworkType.cellular
        }

        ParticleCloud.sharedInstance().getPricingImpact(action,
                deviceID: context.targetDevice.deviceId!,
                networkID: context.selectedNetworkMeshInfo?.networkID,
                networkType: networkType,
                iccid: context.targetDevice.deviceICCID)
        {
            [weak self, weak context] pricingInfo, error in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("getPricingImpact: \(pricingInfo), error: \(error)")

            if (error != nil || pricingInfo?.plan.monthlyBaseAmount == nil) {
                self.fail(withReason: .UnableToGetPricingInformation, nsError: error)
                return
            }

            context.pricingInfo = pricingInfo!
            self.start()
        }
    }

    func setPricingImpactDone() -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        if (!self.pricingRequirementsAreMet()) {
            //make sure to clear pricing info, otherwise the setup will just reuse old data
            context.pricingInfo = nil

            return .CCMissing
        }

        self.stepCompleted()
        return nil
    }

    func pricingRequirementsAreMet() -> Bool {
        guard let context = self.context else {
            return false
        }

        guard let pricingInfo = context.pricingInfo else {
            return false
        }

        return !pricingInfo.chargeable || (pricingInfo.ccOnFile == true)
    }

}
