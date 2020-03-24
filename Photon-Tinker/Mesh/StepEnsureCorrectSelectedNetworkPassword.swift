//
// Created by Raimundas Sakalauskas on 2019-03-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepEnsureCorrectSelectedNetworkPassword : Gen3SetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        if (self.context?.selectedNetworkPassword == nil) {
            context.delegate.gen3SetupDidRequestToEnterSelectedNetworkPassword(self)
        } else {
            self.stepCompleted()
        }
    }

    func setSelectedNetworkPassword(_ password: String, onComplete:@escaping (Gen3SetupFlowError?) -> ()) {
        guard let context = self.context else {
            onComplete(nil)

            return
        }

        guard Gen3SetupStep.validateNetworkPassword(password) else {
            onComplete(.PasswordTooShort)
            return
        }

        /// NOT_FOUND: The device is not a member of a network
        /// NOT_ALLOWED: Invalid commissioning credential
        context.commissionerDevice!.transceiver?.sendAuth(password: password) { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("trying password with character count: \(password.count)")

            self.log("commissionerDevice.sendAuth: \(result.description())")
            if (result == .NONE) {
                self.log("password set with character count: \(password.count)")
                context.selectedNetworkPassword = password

                onComplete(nil)
                self.stepCompleted()
            } else if (result == .NOT_ALLOWED) {
                onComplete(.WrongNetworkPassword)
            } else {
                onComplete(.BluetoothTimeout)
            }
        }
    }

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.selectedNetworkPassword = nil
    }
}
