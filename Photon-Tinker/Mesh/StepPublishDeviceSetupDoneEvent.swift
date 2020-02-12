//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepPublishDeviceSetupDoneEvent : Gen3SetupStep {
    //MARK: PublishDeviceSetupDoneEvent
    override func start() {
        guard let context = self.context else {
            return
        }

        self.log("publishing device setup done")
        ParticleCloud.sharedInstance().publishEvent(withName: "mesh-device-setup-complete", data: context.targetDevice.deviceId!, isPrivate: true, ttl: 60) {
            [weak self, weak context] error in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("stepPublishDeviceSetupDoneEvent error: \(error as Optional)")

            guard error == nil else {
                self.fail(withReason: .UnableToPublishDeviceSetupEvent, nsError: error)
                return
            }

            self.stepCompleted()
        }
    }
}
