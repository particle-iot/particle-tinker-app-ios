//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetNewNetworkPassword : MeshSetupStep {
    override func start() {

        guard let context = self.context else {
            return
        }

        if (context.newNetworkPassword == nil) {
            context.delegate.meshSetupDidRequestToEnterNewNetworkPassword(self)
        } else {
            self.stepCompleted()
        }
    }

    func setNewNetworkPassword(password: String) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        guard MeshSetupStep.validateNetworkPassword(password) else {
            return .PasswordTooShort
        }

        self.log("set network password: \(password)")
        context.newNetworkPassword = password

        self.stepCompleted()

        return nil
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.newNetworkPassword = nil
    }
}
