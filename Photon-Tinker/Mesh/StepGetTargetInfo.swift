//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetTargetDeviceInfo: MeshSetupStep {

    override func start() {
        context.delegate.meshSetupDidRequestTargetDeviceInfo()
    }

    func setTargetDeviceInfo(dataMatrix: MeshSetupDataMatrix, useEthernet: Bool) -> MeshSetupFlowError? {
        context.targetDevice = MeshDevice()

        self.resetFlowFlags()

        self.log("dataMatrix: \(dataMatrix)")
        context.targetDevice.enableEthernetFeature = useEthernet
        context.targetDevice.type = dataMatrix.type
        self.log("self.targetDevice.type?.description = \(context.targetDevice.type?.description as Optional)")
        context.targetDevice.credentials = MeshSetupPeripheralCredentials(name: context.targetDevice.type!.bluetoothNamePrefix + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        self.stepCompleted()

        return nil
    }


    func resetFlowFlags() {
        //these flags are used to determine gateway subflow .. if they are set, new network is being created
        //otherwise gateway is joining the existing network so it is important to clear them
        //we cant use selected network, because that part might be reused if multiple devices are connected to same
        //network without disconnecting commissioner

        self.context.newNetworkPassword = nil
        self.context.newNetworkName = nil
        self.context.newNetworkId = nil

        self.context.apiNetworks = nil

        self.context.userSelectedToLeaveNetwork = nil
        self.context.userSelectedToUpdateFirmware = nil
        self.context.userSelectedToSetupMesh = nil

        self.context.pricingInfo = nil
        self.context.pricingRequirementsAreMet = nil
    }
}

