//
// Created by Raimundas Sakalauskas on 2019-03-06.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepShowInfo : MeshSetupStep {
    override func start() {

        guard let context = self.context else {
            return
        }

        //for xenon joiner flow setupMesh will be nil, so if there's network info & nil for setup mesh, then it's
        //a continued joiner flow and we want to skip this step
        if (context.selectedNetworkMeshInfo != nil && self.context!.userSelectedToSetupMesh == nil) {
            self.stepCompleted()
        } else if (context.targetDevice.hasActiveInternetInterface() && context.targetDevice.activeInternetInterface == .ppp && self.context!.targetDevice.simActive == nil) {
            self.getSimInfo()
        } else {
            self.context!.delegate.meshSetupDidRequestToShowInfo()
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

    func setInfoDone() -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        self.stepCompleted()

        return nil
    }

}
