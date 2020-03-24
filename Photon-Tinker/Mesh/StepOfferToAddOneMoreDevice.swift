//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepOfferToAddOneMoreDevice : Gen3SetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        //disconnect current device
        if (context.targetDevice.transceiver != nil) {
            self.log("Dropping connection to target device")

            if let connection = context.targetDevice.transceiver!.connection {
                context.targetDevice.transceiver = nil
                context.bluetoothManager.dropConnection(with: connection)
            }
        }

        context.delegate.gen3SetupDidRequestToAddOneMoreDevice(self)
    }
}
