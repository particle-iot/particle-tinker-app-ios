//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetNewNetworkNameAndPassword : MeshSetupStep {
    override func start() {

        guard let context = self.context else {
            return
        }

        context.delegate.meshSetupDidRequestToEnterNewNetworkNameAndPassword()
    }


    func setNewNetworkName(name: String) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        guard MeshSetupStep.validateNetworkName(name) else {
            return .NameTooShort
        }

        if let networks =  context.apiNetworks {
            for network in networks {
                if (network.name.lowercased() == name.lowercased()) {
                    return .NameInUse
                }
            }
        }


        self.log("set network name: \(name)")
        context.newNetworkName = name

        if (context.newNetworkName != nil && context.newNetworkPassword != nil) {
            self.stepCompleted()
        }

        return nil
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

        if (context.newNetworkName != nil && context.newNetworkPassword != nil) {
            self.stepCompleted()
        }

        return nil
    }
}
