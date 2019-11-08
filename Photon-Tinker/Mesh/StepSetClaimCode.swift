//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepSetClaimCode: MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        guard let claimed = context.targetDevice.isClaimed else {
            fatalError("at this point, claimed cannot be nil")
        }

        if (!claimed) {
            guard let code = context.targetDevice.claimCode else {
                fatalError("failed to generate claim code")
            }

            context.targetDevice.transceiver?.sendSetClaimCode(claimCode: code) { [weak self, weak context] result in
                guard let self = self, let context = context, !context.canceled else {
                    return
                }

                self.log("targetDevice.sendSetClaimCode: \(result.description())")

                if (result == .NONE) {
                    self.stepCompleted()
                } else {
                    self.handleBluetoothErrorResult(result)
                }
            }
        } else {
            self.stepCompleted()
        }
    }
}
