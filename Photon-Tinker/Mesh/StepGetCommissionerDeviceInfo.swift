//
// Created by Raimundas Sakalauskas on 2019-03-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepGetCommissionerDeviceInfo : Gen3SetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.commissionerDevice?.credentials == nil) {
            context.delegate.gen3SetupDidRequestCommissionerDeviceInfo(self)
        } else {
            self.stepCompleted()
        }
    }

    func setCommissionerDeviceInfo(dataMatrix: Gen3SetupDataMatrix) -> Gen3SetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.commissionerDevice = Gen3SetupDevice()

        self.log("dataMatrix: \(dataMatrix)")
        context.commissionerDevice!.type = dataMatrix.type
        self.log("self.commissionerDevice.type?.description = \(context.commissionerDevice!.type?.description as Optional)")

        context.commissionerDevice!.credentials = Gen3SetupPeripheralCredentials(name: context.commissionerDevice!.type!.bluetoothNamePrefix + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)
        context.commissionerDevice!.state = .credentialsSet

        if (context.commissionerDevice?.credentials?.name == context.targetDevice.credentials?.name) {
            context.commissionerDevice = nil
            return .SameDeviceScannedTwice
        }

        self.stepCompleted()

        return nil
    }

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.commissionerDevice = Gen3SetupDevice()
    }
}
