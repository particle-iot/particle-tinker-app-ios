//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepGetAPINetworks: Gen3SetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        guard context.targetDevice.supportsMesh == nil || context.targetDevice.supportsMesh! == true else {
            self.stepCompleted()
            return
        }

        ParticleCloud.sharedInstance().getNetworks { [weak self, weak context] networks, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("getNetworks: \(networks as Optional), error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToRetrieveNetworks, nsError: error)
                return
            }

            if let networks = networks {
                context.apiNetworks = networks
            } else {
                context.apiNetworks = []
            }

            self.stepCompleted()
        }
    }

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.apiNetworks = nil
    }
}
