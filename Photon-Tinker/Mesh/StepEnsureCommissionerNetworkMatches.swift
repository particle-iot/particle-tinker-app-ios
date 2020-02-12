//
// Created by Raimundas Sakalauskas on 2019-03-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepEnsureCommissionerNetworkMatches : Gen3SetupStep {
    private var expectingConnectionDrop: Bool = false

    override func start() {
        guard let context = self.context else {
            return
        }

        context.commissionerDevice!.transceiver?.sendGetNetworkInfo { [weak self, weak context] result, networkInfo in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("commissionerDevice.sendGetNetworkInfo: \(result.description()), networkInfo: \(networkInfo as Optional)")


            if (result == .NOT_FOUND || result == .NOT_SUPPORTED) {
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
                if result == .NOT_SUPPORTED  {
                    self.fail(withReason: .CommissionerMeshNotSupported)
                } else {
                    self.fail(withReason: .CommissionerNetworkDoesNotMatch)
                }

                //drop connection with current peripheral

                if let connection = context.commissionerDevice!.transceiver!.connection {
                    context.commissionerDevice!.transceiver = nil
                    context.commissionerDevice = nil
                    context.bluetoothManager.dropConnection(with: connection)
                }

                let _ = context.stepDelegate.rewindTo(self, step: StepGetCommissionerDeviceInfo.self, runStep: true)
                context.paused = false
            }
        }
    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: Gen3SetupBluetoothConnection) -> Bool {
        //this is expected
        return expectingConnectionDrop
    }

    override func reset() {
        super.reset()

        self.expectingConnectionDrop = false
    }

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        expectingConnectionDrop = false
        context.commissionerDevice?.meshNetworkInfo = nil
    }
}
