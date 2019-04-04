//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureCorrectSimState: MeshSetupStep {

    private var checkSimActiveRetryCount: Int = 0

    override func start() {
        guard let context = self.context else {
            return
        }


        if context.targetDevice.setSimActive == nil {
            context.delegate.meshSetupDidRequestToSelectSimStatus(self)
        } else if context.targetDevice.simActive == nil {
            self.getSimInfo()
        } else if (context.targetDevice.simActive != context.targetDevice.setSimActive) {
            self.setCorrectSimStatus()
        } else {
            self.stepCompleted()
        }
    }


    func setTargetSimStatus(simActive: Bool) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.targetDevice.setSimActive = simActive
        self.start()

        return nil
    }

    override func reset() {
        self.checkSimActiveRetryCount = 0
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

    private func setCorrectSimStatus() {
        guard let context = self.context else {
            return
        }

        if (self.checkSimActiveRetryCount > MeshSetup.activateSimRetryCount) {
            self.checkSimActiveRetryCount = 0
            if (context.targetDevice.setSimActive!) {
                self.fail(withReason: .FailedToActivateSim)
            } else {
                self.fail(withReason: .FailedToDeactivateSim)
            }
            return
        }
        self.checkSimActiveRetryCount += 1


        ParticleCloud.sharedInstance().updateSim(context.targetDevice.deviceICCID!, action: context.targetDevice.setSimActive! ? ParticleUpdateSimAction.activate : ParticleUpdateSimAction.deactivate, dataLimit: nil, countryCode: nil, cardToken: nil) {
            [weak self, weak context] error in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("updateSim error: \(error)")

            if let nsError = error as? NSError, nsError.code == 504 {
                self.log("activate sim returned 504, but that is fine :(")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    self.start()
                }
            } else if (error != nil) {
                if (context.targetDevice.setSimActive!) {
                    self.fail(withReason: .FailedToActivateSim, nsError: error!)
                } else {
                    self.fail(withReason: .FailedToDeactivateSim, nsError: error!)
                }
                return
            } else {
                context.targetDevice.simActive = context.targetDevice.setSimActive
                self.start()
            }
        }
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.targetDevice.setSimActive = nil
    }
}
