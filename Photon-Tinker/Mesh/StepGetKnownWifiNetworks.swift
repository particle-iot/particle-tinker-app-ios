//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepGetKnownWifiNetworks: MeshSetupStep {

    private var wifiNetworkInfoLoaded = false

    override func reset() {
        wifiNetworkInfoLoaded = false
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if (!wifiNetworkInfoLoaded) {
            self.getTargetDeviceStoredWifiNetworkInfo()
        } else {
            self.stepCompleted()
        }
    }

    private func getTargetDeviceStoredWifiNetworkInfo() {
        context?.targetDevice.transceiver?.sendGetKnownWifiNetworks { [weak self, weak context] result, knownWifiNetworks in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetKnownWifiNetworks: \(result.description())")
            self.log("\(knownWifiNetworks as Optional)");

            if (result == .NOT_FOUND) {
                self.wifiNetworkInfoLoaded = true
                context.targetDevice.knownWifiNetworks = nil
                self.start()
            } else if (result == .NONE) {
                self.wifiNetworkInfoLoaded = true
                context.targetDevice.knownWifiNetworks = knownWifiNetworks
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.targetDevice.knownWifiNetworks = nil
    }
}

