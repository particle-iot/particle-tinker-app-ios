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

        if (context.pricingInfo == nil) {
            self.getPricingImpact()
        } else {
            context.delegate.meshSetupDidRequestToShowPricingInfo(self, info: context.pricingInfo!)
        }
    }

    override func rewindFrom() {
        guard let context = self.context else {
            return
        }

        context.pricingInfo = nil

        super.rewindFrom()
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
