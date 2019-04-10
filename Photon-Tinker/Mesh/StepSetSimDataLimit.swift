//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepSetSimDataLimit: MeshSetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        if context.targetDevice.setSimDataLimit == nil {
            context.delegate.meshSetupDidRequestToSelectSimDataLimit(self)
        } else if context.targetDevice.sim!.status == nil {
            self.getSimStatus()
        } else if (context.targetDevice.sim!.dataLimit != context.targetDevice.setSimDataLimit) {
            self.setCorrectSimDataLimit()
        } else {
            self.stepCompleted()
        }
    }


    func setSimDataLimit(dataLimit: Int) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.targetDevice.setSimDataLimit = dataLimit
        self.start()

        return nil
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
            } else {
                self.fail(withReason: .UnableToGetSimStatus)
            }
        }
    }

    private func setCorrectSimDataLimit() {
        guard let context = self.context else {
            return
        }

        ParticleCloud.sharedInstance().updateSim(context.targetDevice.sim!.iccid!, action: ParticleUpdateSimAction.setDataLimit, dataLimit: NSNumber(integerLiteral: context.targetDevice.setSimDataLimit!), countryCode: nil, cardToken: nil) {
            [weak self, weak context] error in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("updateSim error: \(error)")

            if (error != nil) {
                self.fail(withReason: .FailedToChangeSimDataLimit, nsError: error!)
                return
            } else {
                context.targetDevice.sim!.dataLimit = context.targetDevice.setSimDataLimit!
                self.start()
            }
        }
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.targetDevice.setSimDataLimit = nil
    }
}
