//
// Created by Raimundas Sakalauskas on 2019-03-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepGetCommissionerDeviceInfo : MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.commissionerDevice?.credentials == nil) {
            context.delegate.meshSetupDidRequestCommissionerDeviceInfo(self)
        } else {
            self.stepCompleted()
        }
    }

    func setCommissionerDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.commissionerDevice = MeshSetupDevice()

        self.log("dataMatrix: \(dataMatrix)")
        context.commissionerDevice!.type = dataMatrix.type
        self.log("self.commissionerDevice.type?.description = \(context.commissionerDevice!.type?.description as Optional)")

        context.commissionerDevice!.credentials = MeshSetupPeripheralCredentials(name: context.commissionerDevice!.type!.bluetoothNamePrefix + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)
        context.commissionerDevice!.state = .credentialsSet

        if (context.commissionerDevice?.credentials?.name == context.targetDevice.credentials?.name) {
            context.commissionerDevice = nil
            return .SameDeviceScannedTwice
        }

        self.stepCompleted()

        return nil
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.commissionerDevice = MeshSetupDevice()
    }
}
