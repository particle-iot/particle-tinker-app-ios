//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class SetClaimCode : MeshSetupStep {
    override func start() {
        guard let claimed = self.context.targetDevice.isClaimed else {
            fatalError("at this point, claimed cannot be nil")
        }

        if (!claimed) {
            guard let code = self.context.targetDevice.claimCode else {
                fatalError("failed to generate claim code")
            }

            self.context.targetDevice.transceiver!.sendSetClaimCode(claimCode: code) { result in
                self.log("targetDevice.sendSetClaimCode: \(result.description())")

                if (self.context.canceled) {
                    return
                }

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
