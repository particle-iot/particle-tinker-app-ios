//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepMakeTargetACommissioner : Gen3SetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if context.commissionerDevice == nil {
            self.log("Setting current target device as commissioner device part 2")
            context.commissionerDevice = context.targetDevice
            context.targetDevice = Gen3SetupDevice()
        }

        self.stepCompleted()
    }
}
