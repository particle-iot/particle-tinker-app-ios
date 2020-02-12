//
// Created by Raimundas Sakalauskas on 2019-08-01.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepEnterListeningMode: Gen3SetupStep {

    private var startedListeningMode = false

    override func reset() {
        self.startedListeningMode = false
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if !self.startedListeningMode {
            self.startTargetDeviceListening()
        } else {
            context.targetDevice.wifiNetworkInfo = nil
            self.stepCompleted()
        }
    }


    private func startTargetDeviceListening() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver?.sendStartListening {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendStartListening: \(result.description())")

            if (result == .NONE) {
                context.targetDevice.isListeningMode = nil
                self.startedListeningMode = true
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}

