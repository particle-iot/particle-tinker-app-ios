//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetNewNetworkName: MeshSetupStep {
    override func start() {

        guard let context = self.context else {
            return
        }

        if (context.newNetworkName == nil) {
            context.delegate.meshSetupDidRequestToEnterNewNetworkName(self)
        } else {
            self.stepCompleted()
        }
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

        self.stepCompleted()

        return nil
    }
}
