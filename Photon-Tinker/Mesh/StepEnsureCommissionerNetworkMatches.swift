//
// Created by Raimundas Sakalauskas on 2019-03-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepEnsureCommissionerNetworkMatches : MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        context.commissionerDevice!.transceiver?.sendGetNetworkInfo { [weak self, weak context] result, networkInfo in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("commissionerDevice.sendGetNetworkInfo: \(result.description()), networkInfo: \(networkInfo as Optional)")

            if (result == .NOT_FOUND) {
                context.commissionerDevice!.meshNetworkInfo = nil
            } else if (result == .NONE) {
                context.commissionerDevice!.meshNetworkInfo = networkInfo
            } else {
                self.handleBluetoothErrorResult(result)
                return
            }

            if (context.selectedNetworkMeshInfo?.extPanID == context.commissionerDevice!.meshNetworkInfo?.extPanID) {
                context.selectedNetworkMeshInfo = context.commissionerDevice!.meshNetworkInfo
                context.targetDevice.meshNetworkInfo = context.commissionerDevice!.meshNetworkInfo

                if let networkId = context.targetDevice.meshNetworkInfo?.networkID, networkId.count > 0 {
                    self.stepCompleted()
                } else {
                    self.fail(withReason: .UnableToJoinOldNetwork, severity: .Fatal)
                    return
                }
            } else {
                self.fail(withReason: .CommissionerNetworkDoesNotMatch)

                //drop connection with current peripheral
                let connection = context.commissionerDevice!.transceiver!.connection
                context.commissionerDevice!.transceiver = nil
                context.commissionerDevice = nil
                context.bluetoothManager.dropConnection(with: connection)

                let _ = context.stepDelegate.rewindTo(self, step: StepGetCommissionerDeviceInfo.self, runStep: true)
                context.paused = false
            }
        }
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.commissionerDevice?.meshNetworkInfo = nil
    }
}
