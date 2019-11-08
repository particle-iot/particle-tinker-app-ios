//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepRemoveSelectedWifiCredentials: MeshSetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.selectedForRemovalWifiNetworkInfo != nil) {
            self.getTargetDeviceStoredWifiNetworkInfo()
        } else {
            self.stepCompleted()
        }
    }

    private func getTargetDeviceStoredWifiNetworkInfo() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver?.sendRemoveKnownWifiNetwork(network: context.selectedForRemovalWifiNetworkInfo!) { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }
            self.log("targetDevice.sendRemoveKnownWifiNetwork: \(result.description())")

            if (result == .NONE) {
                context.targetDevice.knownWifiNetworks = nil
                context.selectedForRemovalWifiNetworkInfo = nil
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}

