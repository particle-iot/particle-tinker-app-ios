//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepOfferToSwitchToControlPanel: MeshSetupStep {

    internal var device: ParticleDevice?

    override func start() {
        guard let context = self.context else {
            return
        }

        if context.targetDevice.isSetupDone! && context.targetDevice.isClaimed! {
            if let device = device {
                context.delegate.meshSetupDidRequestToSwitchToControlPanel(self, device: device)
            } else {
                self.getDevice()
            }
        } else {
            self.stepCompleted()
        }
    }

    override func reset() {
        self.device = nil;
    }

    func getDevice() {
        guard let context = self.context else {
            return
        }

        ParticleCloud.sharedInstance().getDevice(context.targetDevice.deviceId!) { [weak self, weak context] device, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            if (error == nil) {
                self.device = device
                self.start()
            } else {
                self.fail(withReason: .FailedToGetDeviceInfo)
            }
        }
    }

    func setSwitchToControlPanel(switchToCP: Bool) -> MeshSetupFlowError? {
        self.stepCompleted()

        return nil
    }
}
