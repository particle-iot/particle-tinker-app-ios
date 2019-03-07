//
// Created by Raimundas Sakalauskas on 2019-03-06.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepShowCellularInfo : MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if (self.context!.targetDevice.simActive == nil) {
            self.getSimInfo()
        } else {
            self.context!.delegate.meshSetupDidRequestToShowCellularInfo(simActivated: self.context!.targetDevice.simActive!)
        }
    }

    private func getSimInfo() {
        guard let context = self.context else {
            return
        }

        ParticleCloud.sharedInstance().checkSim(context.targetDevice.deviceICCID!) { [weak self, weak context] simStatus, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("simStatus: \(simStatus.rawValue), error: \(error)")

            if (error != nil) {
                if simStatus == ParticleSimStatus.notFound {
                    self.fail(withReason: .ExternalSimNotSupported, severity: .Fatal, nsError: error)
                } else if simStatus == ParticleSimStatus.notOwnedByUser {
                    self.fail(withReason: .SimBelongsToOtherAccount, severity: .Fatal, nsError: error)
                } else {
                    self.fail(withReason: .UnableToGetSimStatus, nsError: error)
                }
            } else {
                if simStatus == ParticleSimStatus.OK {
                    context.targetDevice.simActive = false
                    self.start()
                } else if simStatus == ParticleSimStatus.activated || simStatus == ParticleSimStatus.activatedFree {
                    context.targetDevice.simActive = true
                    self.start()
                } else {
                    self.fail(withReason: .UnableToGetSimStatus)
                }
            }
        }
    }

    func setCellularInfoDone() -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        self.stepCompleted()
        return nil
    }
}
