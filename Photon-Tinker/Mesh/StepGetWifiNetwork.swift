//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetWifiNetwork: MeshSetupStep {

    private var wifiNetworkInfoLoaded = false

    override func reset() {
        wifiNetworkInfoLoaded = false
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.targetDevice.wifiNetworkInfo == nil && !wifiNetworkInfoLoaded) {
            self.getTargetDeviceWifiNetworkInfo()
        } else {
            self.stepCompleted()
        }
    }

    private func getTargetDeviceWifiNetworkInfo() {
        context?.targetDevice.transceiver!.sendGetCurrentWifiNetwork { [weak self, weak context] result, networkInfo in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetNetworkInfo: \(result.description())")
            self.log("\(networkInfo as Optional)");

            if (result == .NOT_FOUND) {
                self.wifiNetworkInfoLoaded = true
                context.targetDevice.wifiNetworkInfo = nil
                self.start()
            } else if (result == .NONE) {
                self.wifiNetworkInfoLoaded = true
                context.targetDevice.wifiNetworkInfo = networkInfo
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

        context.targetDevice.wifiNetworkInfo = nil
    }
}

