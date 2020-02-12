//
// Created by Raimundas Sakalauskas on 2019-03-09.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepFinishJoinSelectedNetwork: Gen3SetupStep {

    private var networkJoinedInAPI: Bool = false
    private var dropCommissionerConnection: Bool = false

    init(dropCommissionerConnection: Bool = false) {
        self.dropCommissionerConnection = dropCommissionerConnection
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if (!networkJoinedInAPI) {
            self.joinNetworkInAPI()
        } else if (context.commissionerDevice?.isCommissionerMode ?? false) {
            self.stopCommissioner()
        } else if (context.targetDevice.isSetupDone == nil || context.targetDevice.isSetupDone == false) {
            self.setTargetDeviceSetupDone()
        } else if (dropCommissionerConnection && context.commissionerDevice != nil) {
            self.dropCommissioner()
        } else {
            self.stepCompleted()
        }
    }

    override func reset() {
        networkJoinedInAPI = false
    }

    private func joinNetworkInAPI() {
        guard let context = self.context else {
            return
        }

        ParticleCloud.sharedInstance().addDevice(context.targetDevice.deviceId!, toNetwork: context.targetDevice.meshNetworkInfo!.networkID) {
            [weak self, weak context] error in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("addDevice error: \(error as Optional)")

            guard error == nil else {
                self.fail(withReason: .UnableToJoinNetwork, nsError: error)
                return
            }

            self.networkJoinedInAPI = true
            self.start()
        }
    }

    private func stopCommissioner() {
        guard let context = self.context else {
            return
        }

        context.delegate.gen3SetupDidEnterState(self, state: .JoiningNetworkStep2Done)

        /// NOT_ALLOWED: The client is not authenticated
        context.commissionerDevice!.transceiver?.sendStopCommissioner {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("commissionerDevice.sendStopCommissioner: \(result.description())")

            if (result == .NONE) {
                context.commissionerDevice?.isCommissionerMode = false
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
         }
    }

    private func setTargetDeviceSetupDone() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver?.sendDeviceSetupDone (done: true) {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendDeviceSetupDone: \(result.description())")

            if (result == .NONE) {
                context.targetDevice.isSetupDone = true
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func dropCommissioner() {
        guard let context = self.context else {
            return
        }

        if let connection = context.commissionerDevice!.transceiver!.connection {
            context.commissionerDevice!.transceiver = nil
            context.commissionerDevice = nil
            context.bluetoothManager.dropConnection(with: connection)
        }

        self.start()
    }
}
