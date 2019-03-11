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

        context.delegate.meshSetupDidRequestTargetDeviceInfo()
    }

    func setTargetDeviceInfo(dataMatrix: MeshSetupDataMatrix, useEthernet: Bool) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.targetDevice = MeshDevice()

        self.resetFlowFlags()

        self.log("dataMatrix: \(dataMatrix)")
        context.targetDevice.enableEthernetFeature = useEthernet
        context.targetDevice.type = dataMatrix.type
        self.log("self.targetDevice.type?.description = \(self.context!.targetDevice.type?.description as Optional)")
        context.targetDevice.credentials = MeshSetupPeripheralCredentials(name: self.context!.targetDevice.type!.bluetoothNamePrefix + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        if (context.targetDevice.credentials?.name == context.commissionerDevice?.credentials?.name) {
            context.targetDevice = MeshDevice()
            return .ThisDeviceIsACommissioner
        }

        self.stepCompleted()

        return nil
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

        context.userSelectedToLeaveNetwork = nil
        context.userSelectedToUpdateFirmware = nil
        context.userSelectedToSetupMesh = nil
        context.userSelectedToCreateNetwork = nil

        context.pricingInfo = nil
    }
}

