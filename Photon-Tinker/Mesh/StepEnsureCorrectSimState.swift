//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureCorrectSimState: MeshSetupStep {

    private var checkSimActiveRetryCount: Int = 0
    private var simStatusReceived: Bool = false

    override func start() {
        guard let context = self.context else {
            return
        }


        if context.targetDevice.setSimActive == nil {
            context.delegate.meshSetupDidRequestToSelectSimStatus(self)
        } else if context.targetDevice.sim!.active == nil {
            self.getSimInfo()
        } else if context.targetDevice.sim!.status == nil && simStatusReceived == false {
            self.getSimStatus()
        } else if (context.targetDevice.sim!.active != context.targetDevice.setSimActive) {
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
        self.simStatusReceived = true
    }

    private func getSimStatus() {
        guard let context = self.context else {
            return
        }


        ParticleCloud.sharedInstance().getSim(context.targetDevice.sim!.iccid!) { [weak self, weak context] simInfo, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("simInfo: \(simInfo), error: \(error)")

            if (error == nil) {
                context.targetDevice.sim!.status = simInfo!.status
                context.targetDevice.sim!.dataLimit = Int(simInfo!.mbLimit)
                self.start()
            } else if let nserror = error as? NSError, nserror.code == 404 {
                context.targetDevice.sim!.status = nil
                context.targetDevice.sim!.dataLimit = nil
                self.simStatusReceived = true
            } else {
                self.fail(withReason: .UnableToGetSimStatus)
            }
        }
    }

    private func getSimInfo() {
        guard let context = self.context else {
            return
        }

        ParticleCloud.sharedInstance().checkSim(context.targetDevice.sim!.iccid!) { [weak self, weak context] simStatus, error in
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
                if simStatus == ParticleSimStatus.inactive {
                    context.targetDevice.sim!.active = false
                    self.start()
                } else if simStatus == ParticleSimStatus.active {
                    context.targetDevice.sim!.active = true
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


        ParticleCloud.sharedInstance().updateSim(context.targetDevice.sim!.iccid!, action: context.targetDevice.setSimActive! ? ParticleUpdateSimAction.activate : ParticleUpdateSimAction.deactivate, dataLimit: nil, countryCode: nil, cardToken: nil) {
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
                context.targetDevice.sim!.active = context.targetDevice.setSimActive
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
