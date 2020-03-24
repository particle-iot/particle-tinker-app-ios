//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepGetNewNetworkPassword : Gen3SetupStep {
    override func start() {

        guard let context = self.context else {
            return
        }

        if (context.newNetworkPassword == nil) {
            context.delegate.gen3SetupDidRequestToEnterNewNetworkPassword(self)
        } else {
            self.stepCompleted()
        }
    }

    func setNewNetworkPassword(password: String) -> Gen3SetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        guard Gen3SetupStep.validateNetworkPassword(password) else {
            return .PasswordTooShort
        }

        self.log("set network password with character count: \(password.count)")
        context.newNetworkPassword = password

        self.stepCompleted()

        return nil
    }

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.newNetworkPassword = nil
    }
}
