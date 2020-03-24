//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepGetUserWifiNetworkSelection : Gen3SetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.selectedWifiNetworkInfo != nil) {
            self.stepCompleted()
        } else {
            context.delegate.gen3SetupDidEnterState(self, state: .TargetDeviceScanningForWifiNetworks)
            self.scanWifiNetworks()
        }
    }

    func scanWifiNetworks() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver?.sendScanWifiNetworks { [weak self, weak context] result, networks in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("sendScanWifiNetworks: \(result.description()), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")

            if (result == .NONE) {
                context.targetDevice.wifiNetworks = Gen3SetupStep.removeRepeatedWifiNetworks(networks!)
            } else {
                //this command will be repeated multiple times, no need to trigger errors.. just pretend all is fine
                context.targetDevice.wifiNetworks = []
            }
            context.delegate.gen3SetupDidRequestToSelectWifiNetwork(self, availableNetworks: context.targetDevice.wifiNetworks!)
        }
    }




    func setSelectedWifiNetwork(selectedNetwork: Gen3SetupNewWifiNetworkInfo) -> Gen3SetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.selectedWifiNetworkInfo = selectedNetwork
        self.log("self.selectedWifiNetworkInfo: \(context.selectedWifiNetworkInfo)")
        self.stepCompleted()

        return nil
    }

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.selectedWifiNetworkInfo = nil
    }
}
