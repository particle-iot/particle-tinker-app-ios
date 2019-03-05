//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepShowPricingImpact : MeshSetupStep {

    //    //MARK: ShowPricingImpact
//    private func stepShowPricingImpact() {
//        //if it's boron and active interface is cellular, get iccid first
//        if ((self.targetDevice.type! == .boron || (self.targetDevice.type! == .bSeries)) &&
//                self.targetDevice.activeInternetInterface != nil &&
//                self.targetDevice.activeInternetInterface! == .ppp &&
//                self.targetDevice.deviceICCID == nil) {
//
//            if (self.targetDevice.externalSim == nil) {
//                self.getTargetDeviceActiveSim()
//            } else {
//                self.getTargetDeviceICCID()
//            }
//
//            return
//        }
//
//        self.getPricingImpact()
//    }
//
//    private func getTargetDeviceActiveSim() {
//        if (self.targetDevice.externalSim != nil) {
//            self.getTargetDeviceICCID()
//            return;
//        }
//
//        self.targetDevice.transceiver!.sendGetActiveSim () { result, externalSim in
//            self.log("targetDevice.transceiver!.sendGetActiveSim: \(result.description()), externalSim: \(externalSim as Optional)")
//            if (self.canceled) {
//                return
//            }
//
//            if (result == .NONE) {
//                self.targetDevice.externalSim = externalSim!
//                if (externalSim!) {
//                    self.fail(withReason: .ExternalSimNotSupported, severity: .Fatal)
//                } else {
//                    self.getTargetDeviceICCID()
//                }
//            } else if (result == .INVALID_STATE) {
//                self.fail(withReason: .BoronModemError)
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func getTargetDeviceICCID() {
//        if (self.targetDevice.deviceICCID != nil) {
//            self.getPricingImpact()
//            return
//        }
//
//        self.targetDevice.transceiver!.sendGetIccid () { result, iccid in
//            self.log("targetDevice.transceiver!.sendGetIccid: \(result.description()), iccid: \(iccid as Optional)")
//            if (self.canceled) {
//                return
//            }
//
//            if (result == .NONE) {
//                self.targetDevice.deviceICCID = iccid!
//                self.getPricingImpact()
//            } else if (result == .INVALID_STATE) {
//                self.fail(withReason: .BoronModemError)
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    private func getPricingImpact() {
//        //if we already have pricing info, lets just use it
//        if (self.pricingInfo != nil) {
//            self.delegate.meshSetupDidRequestToShowPricingInfo(info: pricingInfo!)
//            return
//        }
//
//        //joiner flow
//        var action = ParticlePricingImpactAction.addNetworkDevice
//        if (self.userSelectedToSetupMesh != nil){
//            //standalone or network
//            action = self.userSelectedToSetupMesh! ? .createNetwork : .addUserDevice
//        }
//
//        var networkType = ParticlePricingImpactNetworkType.wifi
//        if let interface = self.targetDevice.activeInternetInterface, interface == .ppp {
//            networkType = ParticlePricingImpactNetworkType.cellular
//        }
//
//        ParticleCloud.sharedInstance().getPricingImpact(action,
//                deviceID: self.targetDevice.deviceId!,
//                networkID: self.selectedNetworkMeshInfo?.networkID,
//                networkType: networkType,
//                iccid: self.targetDevice.deviceICCID)
//        {
//            pricingInfo, error in
//
//            if (self.canceled) {
//                return
//            }
//
//            self.log("getPricingImpact: \(pricingInfo), error: \(error)")
//
//            if (error != nil || pricingInfo?.plan.monthlyBaseAmount == nil) {
//                self.fail(withReason: .UnableToGetPricingInformation, nsError: error)
//                return
//            }
//
//            if (pricingInfo!.chargeable == false) {
//                self.pricingRequirementsAreMet = true
//            } else {
//                self.pricingRequirementsAreMet = pricingInfo!.ccOnFile == true
//            }
//
//            self.pricingInfo = pricingInfo!
//            self.delegate.meshSetupDidRequestToShowPricingInfo(info: self.pricingInfo!)
//        }
//    }
//
//    func setPricingImpactDone() -> MeshSetupFlowError? {
//        guard currentCommand == .ShowPricingImpact else {
//            return .IllegalOperation
//        }
//
//        if (!(self.pricingRequirementsAreMet ?? false)) {
//            //make sure to clear pricing info, otherwise the setup will just reuse old data
//            self.pricingInfo = nil
//            self.pricingRequirementsAreMet = nil
//            return .CCMissing
//        }
//
//        self.stepComplete(.ShowPricingImpact)
//        return nil
//    }

}
