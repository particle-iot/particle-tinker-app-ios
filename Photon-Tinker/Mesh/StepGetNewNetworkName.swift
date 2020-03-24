//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepGetNewNetworkName: Gen3SetupStep {
    override func start() {

        guard let context = self.context else {
            return
        }

        if (context.newNetworkName == nil) {
            context.delegate.gen3SetupDidRequestToEnterNewNetworkName(self)
        } else {
            self.stepCompleted()
        }
    }

    func setNewNetworkName(name: String) -> Gen3SetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        guard Gen3SetupStep.validateNetworkName(name) else {
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

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.newNetworkName = nil
    }
}
