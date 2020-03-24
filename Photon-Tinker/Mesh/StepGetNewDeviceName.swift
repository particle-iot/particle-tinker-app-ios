//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepGetNewDeviceName : Gen3SetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        context.delegate.gen3SetupDidRequestToEnterDeviceName(self)
    }


    func setDeviceName(name: String, onComplete:@escaping (Gen3SetupFlowError?) -> ()) {
        guard let context = self.context else {
            onComplete(nil)
            return
        }

        guard self.validateDeviceName(name) else {
            onComplete(.NameTooShort)
            return
        }

        ParticleCloud.sharedInstance().getDevice(context.targetDevice.deviceId!) { [weak self, weak context] device, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            if (error == nil) {
                device!.rename(name) { error in
                    if error == nil {
                        context.targetDevice.name = name
                        onComplete(nil)
                        self.stepCompleted()
                    } else {
                        onComplete(.UnableToRenameDevice)
                        return
                    }
                }
            } else {
                onComplete(.UnableToRenameDevice)
                return
            }
        }
    }

    private func validateDeviceName(_ name: String) -> Bool {
        return name.count > 0
    }

}
