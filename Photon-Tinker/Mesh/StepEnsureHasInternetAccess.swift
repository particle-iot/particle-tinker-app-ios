//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureHasInternetAccess : MeshSetupStep {
    private var checkDeviceHasIPStartTime: Date?
    private var checkSimActiveRetryCount: Int = 0

    override func start() {
        guard let context = self.context else {
            return
        }

        context.delegate.meshSetupDidEnterState(self, state: .TargetDeviceConnectingToInternetStarted)

        if (context.targetDevice.isSetupDone == nil || context.targetDevice.isSetupDone! == false) {
            self.setDeviceSetupDone()
        } else if (context.targetDevice.hasActiveInternetInterface() &&
                context.targetDevice.activeInternetInterface! == .ppp &&
                context.targetDevice.simActive == nil) {
            self.activateSim()
        } else if (context.targetDevice.isListeningMode == nil || context.targetDevice.isListeningMode! == true) {
            self.stopTargetDeviceListening()
        } else if (context.targetDevice.hasInternetAddress == nil || context.targetDevice.hasInternetAddress! == false) {
            self.checkDeviceHasIP()
        } else {
            self.stepCompleted()
        }

    }

    override func reset() {
        self.checkDeviceHasIPStartTime = nil
        self.checkSimActiveRetryCount = 0
    }

    private func setDeviceSetupDone() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendDeviceSetupDone (done: true) { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.transceiver!.sendDeviceSetupDone: \(result.description())")

            if (result == .NONE) {
                context.targetDevice.isSetupDone = true
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    private func activateSim() {
        guard let context = self.context else {
            return
        }

        if (self.checkSimActiveRetryCount > MeshSetup.activateSimRetryCount) {
            self.checkSimActiveRetryCount = 0
            self.fail(withReason: .FailedToActivateSim)
            return
        }
        self.checkSimActiveRetryCount += 1

        ParticleCloud.sharedInstance().updateSim(context.targetDevice.deviceICCID!, action: .activate, dataLimit: nil, countryCode: nil, cardToken: nil) {
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
                self.fail(withReason: .FailedToActivateSim, nsError: error!)
                return
            } else {
                context.targetDevice.simActive = true
                context.delegate.meshSetupDidEnterState(self, state: .TargetDeviceConnectingToInternetStep0Done)
                self.start()
            }
        }
    }

    private func stopTargetDeviceListening() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendStopListening { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendStopListening: \(result.description())")

            if (result == .NONE) {
                context.targetDevice.isListeningMode = false
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    private func checkDeviceHasIP() {
        guard let context = self.context else {
            return
        }

        if (self.checkDeviceHasIPStartTime == nil) {
            self.checkDeviceHasIPStartTime = Date()
        }

        let diff = Date().timeIntervalSince(self.checkDeviceHasIPStartTime!)

        //simActive is going to be not nil only if cellular flow
        let limit = (context.targetDevice.simActive != nil) ? MeshSetup.deviceObtainedIPCellularTimeout : MeshSetup.deviceObtainedIPTimeout

        if (diff > limit) {
            self.checkDeviceHasIPStartTime = nil

            if (context.targetDevice.simActive != nil) {
                self.fail(withReason: .FailedToObtainIpBoron)
            } else {
                self.fail(withReason: .FailedToObtainIp)
            }
            return
        }

        context.targetDevice.transceiver!.sendGetInterface(interfaceIndex: context.targetDevice.getActiveNetworkInterfaceIdx()!) {
            [weak self, weak context] result, interface in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("result: \(result.description()), networkInfo: \(interface as Optional)")

            if (result == .NONE) {
                if (interface?.ipv4Config.addresses.first != nil || interface?.ipv6Config.addresses.first != nil) {
                    context.targetDevice.hasInternetAddress = true
                    self.start()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        [weak self, weak context] in
                        guard let self = self, let context = context, !context.canceled else {
                            return
                        }

                        self.start()
                    }
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

}
