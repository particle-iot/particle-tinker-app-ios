//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepStopSignal : MeshSetupStep {
    private var controlRequestSent: Bool = false

    override func reset() {
        self.controlRequestSent = false
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if (!controlRequestSent) {
            self.stopSignaling()
        } else {
            self.stepCompleted()
        }
    }

    private func stopSignaling() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendStopNyanSignal {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendStopNyanSignal: \(result.description())")

            if (result == .NONE) {
                self.controlRequestSent = true
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}
