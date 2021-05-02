//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepOfferToSwitchToControlPanel: Gen3SetupStep {

    internal var device: ParticleDevice?

    override func start() {
        guard let context = self.context else {
            return
        }

        if context.targetDevice.isSetupDone! && context.targetDevice.isClaimed! {
            if let device = device {
                context.delegate.gen3SetupDidRequestToSwitchToControlPanel(self, device: device)
            } else {
                self.getDevice()
            }
        } else {
            guard context.targetDevice.type != .xenon && context.targetDevice.type != .xSeries else {

                self.fail(withReason: .XennonNotSupportedError)
                //drop connection with current peripheral

                if let connection = context.targetDevice!.transceiver!.connection {
                    context.targetDevice!.transceiver = nil
                    context.targetDevice = nil
                    context.bluetoothManager.dropConnection(with: connection)
                }

                let _ = context.stepDelegate.rewindTo(self, step: StepGetTargetDeviceInfo.self, runStep: true)
                context.paused = false

                return
            }

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

    func setSwitchToControlPanel(switchToCP: Bool) -> Gen3SetupFlowError? {
        self.stepCompleted()

        return nil
    }
}
