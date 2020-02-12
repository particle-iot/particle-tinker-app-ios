//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepExitListeningMode : Gen3SetupStep {
    private var attemptedToExitListeningMode: Bool = false

    override func reset() {
        self.attemptedToExitListeningMode = false
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.targetDevice.isListeningMode == nil) {
            self.getDeviceMode()
        } else if (context.targetDevice.isListeningMode! == true && !attemptedToExitListeningMode) {
            self.stopTargetDeviceListening()
        } else {
            self.stepCompleted()
        }
    }

    private func getDeviceMode() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver?.sendGetDeviceIsInListeningMode {
            [weak self, weak context] result, listeningMode in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetDeviceIsInListeningMode: \(result.description()), listeningMode: \(listeningMode as Optional)")

            if (result == .NONE) {
                context.targetDevice.isListeningMode = listeningMode!
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func stopTargetDeviceListening() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver?.sendStopListening {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendStopListening: \(result.description())")

            if (result == .NONE) {
                self.attemptedToExitListeningMode = true
                context.targetDevice.isListeningMode = nil
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}
