//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetAPINetworks: MeshSetupStep {

    override func start() {
        ParticleCloud.sharedInstance().getNetworks { networks, error in
            if (self.context.canceled) {
                return
            }

            self.log("getNetworks: \(networks as Optional), error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToRetrieveNetworks, nsError: error)
                return
            }

            if let networks = networks {
                self.context.apiNetworks = networks
            } else {
                self.context.apiNetworks = []
            }

            self.stepCompleted()
        }
    }
}
