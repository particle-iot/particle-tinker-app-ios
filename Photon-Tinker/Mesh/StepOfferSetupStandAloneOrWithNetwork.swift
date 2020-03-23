//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepOfferSetupStandAloneOrWithNetwork : Gen3SetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        guard let supportsMesh = context.targetDevice.supportsMesh, supportsMesh == true else {
            context.userSelectedToSetupMesh = false
            self.stepCompleted()
            return
        }

        context.delegate.gen3SetupDidRequestToSelectStandAloneOrMeshSetup(self)
    }

    func setSelectStandAloneOrMeshSetup(meshSetup: Bool) -> Gen3SetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.userSelectedToSetupMesh = meshSetup

        self.stepCompleted()

        return nil
    }

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.userSelectedToSetupMesh = nil
    }
}
