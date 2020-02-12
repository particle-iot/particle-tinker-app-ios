//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepEnsureGotClaimed: Gen3SetupStep {
    private var checkTargetDeviceGotConnectedStartTime: Date?
    private var checkTargetDeviceGotClaimedStartTime: Date?
    private var isConnected: Bool = false
    private var isClaimed: Bool = false

    override func start() {
        guard let context = self.context else {
            return
        }

        if (!isConnected) {
            self.checkTargetDeviceGotConnected()
        } else if (!isClaimed) {
            self.checkTargetDeviceGotClaimed()
        } else {
            self.log("device was successfully claimed")
            if (context.targetDevice.hasActiveInternetInterface()) {
                context.delegate.gen3SetupDidEnterState(self, state: .TargetDeviceConnectingToInternetCompleted)
            } else {
                context.delegate.gen3SetupDidEnterState(self, state: .JoiningNetworkCompleted)
            }
            self.stepCompleted()
        }
    }

    override func reset() {
        self.isConnected = false
        self.isClaimed = false

        self.checkTargetDeviceGotConnectedStartTime = nil
        self.checkTargetDeviceGotClaimedStartTime = nil
    }

    private func checkTargetDeviceGotConnected() {
        guard let context = self.context else {
            return
        }

        if (self.checkTargetDeviceGotConnectedStartTime == nil) {
            self.checkTargetDeviceGotConnectedStartTime = Date()
        }

        let diff = Date().timeIntervalSince(self.checkTargetDeviceGotConnectedStartTime!)
        if (diff > Gen3Setup.deviceConnectToCloudTimeout) {
            self.checkTargetDeviceGotConnectedStartTime = nil
            self.fail(withReason: .DeviceConnectToCloudTimeout)
            return
        }

        context.targetDevice.transceiver?.sendGetConnectionStatus { [weak self, weak context] result, status in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetConnectionStatus: \(result.description())")

            if (result == .NONE) {
                self.log("status: \(status as Optional)")
                if (status! == .connected) {
                    self.log("device connected to the cloud")
                    context.delegate.gen3SetupDidEnterState(self, state: .TargetDeviceConnectingToInternetStep1Done)
                    self.isConnected = true
                } else {
                    self.log("device did NOT connect yet")
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
                    [weak self, weak context] in

                    guard let self = self, let context = context, !context.canceled else {
                        return
                    }

                    self.start()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkTargetDeviceGotClaimed() {
        guard let context = self.context else {
            return
        }

        if (self.checkTargetDeviceGotClaimedStartTime == nil) {
            self.checkTargetDeviceGotClaimedStartTime = Date()
        }

        let diff = Date().timeIntervalSince(self.checkTargetDeviceGotClaimedStartTime!)
        if (diff > Gen3Setup.deviceGettingClaimedTimeout) {
            self.checkTargetDeviceGotClaimedStartTime = nil
            self.fail(withReason: .DeviceGettingClaimedTimeout)
            return
        }

        ParticleCloud.sharedInstance().getDevices { [weak self, weak context] devices, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            guard error == nil else {
                self.fail(withReason: .DeviceGettingClaimedTimeout, nsError: error!)
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == context.targetDevice.deviceId!) {
                        context.targetDevice.name = device.name
                        self.isClaimed = true
                        self.start()
                        return
                    }
                }
            }

            self.log("device was NOT successfully claimed")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                [weak self, weak context] in
                guard let self = self, let context = context, !context.canceled else {
                    return
                }

                self.start()
            }
        }
    }


}
