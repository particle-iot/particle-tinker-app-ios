//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepShowPricingImpact : MeshSetupStep {

    override func start() {
        //for boron / b series
        if let activeInternetInterface = self.context.targetDevice.activeInternetInterface, activeInternetInterface == .ppp {
            if (self.context.targetDevice.externalSim == nil) {
                self.getTargetDeviceActiveSim()
            } else if (self.context.targetDevice.deviceICCID == nil) {
                self.getTargetDeviceICCID()
            } else if (self.context.pricingInfo == nil) {
                self.getPricingImpact()
            } else {
                self.context.delegate.meshSetupDidRequestToShowPricingInfo(info: self.context.pricingInfo!)
            }
        } else if (self.context.pricingInfo == nil) {
            self.getPricingImpact()
        } else {
            self.context.delegate.meshSetupDidRequestToShowPricingInfo(info: self.context.pricingInfo!)
        }
    }

    private func getTargetDeviceActiveSim() {
        self.context.targetDevice.transceiver!.sendGetActiveSim () { result, externalSim in

            self.log("targetDevice.transceiver!.sendGetActiveSim: \(result.description()), externalSim: \(externalSim as Optional)")
            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                self.context.targetDevice.externalSim = externalSim!
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
        self.context.targetDevice.transceiver!.sendGetIccid () { result, iccid in

            self.log("targetDevice.transceiver!.sendGetIccid: \(result.description()), iccid: \(iccid as Optional)")
            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                self.context.targetDevice.deviceICCID = iccid!
                self.start()
            } else if (result == .INVALID_STATE) {
                self.fail(withReason: .BoronModemError)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func getPricingImpact() {
        //joiner flow
        var action = ParticlePricingImpactAction.addNetworkDevice
        if let userSelectedToSetupMesh = self.context.userSelectedToSetupMesh {
            //standalone or network
            action = userSelectedToSetupMesh ? .createNetwork : .addUserDevice
        }

        var networkType = ParticlePricingImpactNetworkType.wifi
        if let interface = self.context.targetDevice.activeInternetInterface, interface == .ppp {
            networkType = ParticlePricingImpactNetworkType.cellular
        }

        ParticleCloud.sharedInstance().getPricingImpact(action,
                deviceID: self.context.targetDevice.deviceId!,
                networkID: self.context.selectedNetworkMeshInfo?.networkID,
                networkType: networkType,
                iccid: self.context.targetDevice.deviceICCID)
        {
            pricingInfo, error in

            if (self.context.canceled) {
                return
            }

            self.log("getPricingImpact: \(pricingInfo), error: \(error)")

            if (error != nil || pricingInfo?.plan.monthlyBaseAmount == nil) {
                self.fail(withReason: .UnableToGetPricingInformation, nsError: error)
                return
            }

            self.context.pricingInfo = pricingInfo!
            self.start()
        }
    }

    func setPricingImpactDone() -> MeshSetupFlowError? {
        if (!self.pricingRequirementsAreMet()) {
            //make sure to clear pricing info, otherwise the setup will just reuse old data
            self.context.pricingInfo = nil

            return .CCMissing
        }

        self.stepCompleted()
        return nil
    }

    func pricingRequirementsAreMet() -> Bool {
        guard let pricingInfo = self.context.pricingInfo else {
            return false
        }

        return !pricingInfo.chargeable || (pricingInfo.ccOnFile == true)
    }

}
