//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetTargetDeviceInfo: MeshSetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.targetDevice.credentials == nil || context.targetDevice.type == nil) {
            context.delegate.meshSetupDidRequestTargetDeviceInfo(self)
        } else {
            self.stepCompleted()
        }
    }

    func setTargetDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        self.resetFlowFlags()

        self.log("dataMatrix: \(dataMatrix)")
        context.targetDevice.type = dataMatrix.type
        self.log("self.targetDevice.type?.description = \(self.context!.targetDevice.type?.description as Optional)")
        context.targetDevice.credentials = MeshSetupPeripheralCredentials(name: self.context!.targetDevice.type!.bluetoothNamePrefix + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)
        context.targetDevice.state = .credentialsSet

        if (context.targetDevice.credentials?.name == context.commissionerDevice?.credentials?.name) {
            context.targetDevice = MeshSetupDevice()
            return .ThisDeviceIsACommissioner
        }

        self.stepCompleted()

        return nil
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        context.targetDevice = MeshSetupDevice()
    }

    func resetFlowFlags() {
        //these flags are used to determine gateway subflow .. if they are set, new network is being created
        //otherwise gateway is joining the existing network so it is important to clear them
        //we cant use selected network, because that part might be reused if multiple devices are connected to same
        //network without disconnecting commissioner

        guard let context = self.context else {
            return
        }

        context.newNetworkPassword = nil
        context.newNetworkName = nil
        context.newNetworkId = nil

        context.apiNetworks = nil

        context.selectedWifiNetworkInfo = nil

        context.userSelectedToLeaveNetwork = nil
        context.userSelectedToUpdateFirmware = nil
        context.userSelectedToSetupMesh = nil
        context.userSelectedToCreateNetwork = nil

        context.pricingInfo = nil
    }
}

