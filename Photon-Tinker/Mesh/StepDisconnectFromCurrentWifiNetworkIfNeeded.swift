//
// Created by Raimundas Sakalauskas on 2019-08-01.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepDisconnectFromCurrentWifiNetworkIfNeeded: MeshSetupStep {

    private var startedListeningMode = false
    private var stoppedListeningMode = false

    override func reset() {
        self.startedListeningMode = false
        self.stoppedListeningMode = false
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if (self.startedListeningMode && self.stoppedListeningMode) {
            context.targetDevice.wifiNetworkInfo = nil
            self.stepCompleted()
        } else if self.shouldDisconnectFromCurrentWifi() && !self.startedListeningMode {
            self.startTargetDeviceListening()
        } else if self.shouldDisconnectFromCurrentWifi() && !self.stoppedListeningMode {
            self.stopTargetDeviceListening()
        } else {
            stepCompleted()
        }
    }

    func shouldDisconnectFromCurrentWifi() -> Bool {
        guard let context = self.context else {
            return false
        }

        if let network = context.targetDevice.wifiNetworkInfo, let knownNetworks = context.targetDevice.knownWifiNetworks {
            for knownNetwork in knownNetworks {
                if (network.ssid.lowercased() == knownNetwork.ssid.lowercased()) {
                    return false
                }
            }
            return true
        } else {
            return false
        }

    }


    private func startTargetDeviceListening() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendStartListening {
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
                context.targetDevice.isListeningMode = nil
                self.stoppedListeningMode = true
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}

