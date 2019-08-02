//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetEthernetFeatureStatus: MeshSetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        if context.targetDevice.ethernetDetectionFeature == nil {
            self.getFeatureFlag()
        } else {
            self.stepCompleted()
        }
    }

    private func getFeatureFlag() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendGetFeature(feature: .ethernetDetection) { [weak self, weak context] result, enabled in
            guard let self = self, let context = context, !context.canceled else {
                return
            }


            self.log("targetDevice.sendGetFeature: \(result.description()) enabled: \(enabled as Optional)")

            if (result == .NONE) {
                context.targetDevice.ethernetDetectionFeature = enabled!
                self.start()
            } else if (result == .NOT_SUPPORTED) {
                context.targetDevice.ethernetDetectionFeature = false
                self.stepCompleted()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.targetDevice.ethernetDetectionFeature = nil
    }
}
