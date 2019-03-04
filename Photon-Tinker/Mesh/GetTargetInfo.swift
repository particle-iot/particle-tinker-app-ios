//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class GetTargetDeviceInfo: MeshSetupStep {
    override func start() {
        context.delegate.meshSetupDidRequestTargetDeviceInfo()
    }

    func setTargetDeviceInfo(dataMatrix: MeshSetupDataMatrix, useEthernet: Bool) -> MeshSetupFlowError? {
        context.targetDevice = MeshDevice()
        context.resetFlowFlags()

        self.log("dataMatrix: \(dataMatrix)")
        context.targetDevice.enableEthernetFeature = useEthernet
        context.targetDevice.type = dataMatrix.type
        self.log("self.targetDevice.type?.description = \(context.targetDevice.type?.description as Optional)")
        context.targetDevice.credentials = MeshSetupPeripheralCredentials(name: context.targetDevice.type!.bluetoothNamePrefix + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        self.stepCompleted()

        return nil
    }
}

