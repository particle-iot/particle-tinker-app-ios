//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepOfferToAddOneMoreDevice : MeshSetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        //disconnect current device
        if (context.targetDevice.transceiver != nil) {
            self.log("Dropping connection to target device")

            let connection = context.targetDevice.transceiver!.connection
            context.targetDevice.transceiver = nil
            context.bluetoothManager.dropConnection(with: connection)
        }

        context.delegate.meshSetupDidRequestToAddOneMoreDevice()
    }
}
