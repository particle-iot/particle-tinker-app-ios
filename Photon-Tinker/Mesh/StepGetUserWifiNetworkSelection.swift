//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetUserWifiNetworkSelection : MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.selectedWifiNetworkInfo != nil) {
            self.stepCompleted()
        } else {
            context.delegate.meshSetupDidEnterState(self, state: .TargetDeviceScanningForWifiNetworks)
            self.scanWifiNetworks()
        }
    }

    func scanWifiNetworks() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendScanWifiNetworks { [weak self, weak context] result, networks in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("sendScanWifiNetworks: \(result.description()), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")

            if (result == .NONE) {
                context.targetDevice.wifiNetworks = MeshSetupStep.removeRepeatedWifiNetworks(networks!)
            } else {
                //this command will be repeated multiple times, no need to trigger errors.. just pretend all is fine
                context.targetDevice.wifiNetworks = []
            }
            context.delegate.meshSetupDidRequestToSelectWifiNetwork(self, availableNetworks: context.targetDevice.wifiNetworks!)
        }
    }




    func setSelectedWifiNetwork(selectedNetwork: MeshSetupNewWifiNetworkInfo) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.selectedWifiNetworkInfo = selectedNetwork
        self.log("self.selectedWifiNetworkInfo: \(context.selectedWifiNetworkInfo)")
        self.stepCompleted()

        return nil
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.selectedWifiNetworkInfo = nil
    }
}
