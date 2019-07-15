//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepExitListeningMode : MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.targetDevice.isListeningMode == nil || context.targetDevice.isListeningMode! == true) {
            self.stopTargetDeviceListening()
        } else {
            self.stepCompleted()
        }
    }

    private func stopTargetDeviceListening() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendStopListening {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendStopListening: \(result.description())")

            if (result == .NONE) {
                context.targetDevice.isListeningMode = false
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}
