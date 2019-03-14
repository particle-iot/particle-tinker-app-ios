//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepCheckTargetDeviceHasNetworkInterfaces : MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.targetDevice.activeInternetInterface == nil) {
            self.getActiveInternetInterface()
        } else if (context.targetDevice.activeInternetInterface! == .ppp && context.targetDevice.externalSim == nil) {
            self.getTargetDeviceActiveSim()
        } else if (context.targetDevice.activeInternetInterface! == .ppp && context.targetDevice.deviceICCID == nil) {
            self.getTargetDeviceICCID()
        } else if (context.targetDevice.activeInternetInterface! == .ppp && context.targetDevice.simActive == nil) {
            self.getSimInfo()
        } else {
            self.stepCompleted()
        }

    }

    private func getActiveInternetInterface() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendGetInterfaceList {
            [weak self, weak context] result, interfaces in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetInterfaceList: \(result.description()), networkCount: \(interfaces?.count as Optional)")
            self.log("\(interfaces as Optional)")

            if (result == .NONE) {
                context.targetDevice.activeInternetInterface = nil

                context.targetDevice.networkInterfaces = interfaces!

                for interface in interfaces! {
                    if (interface.type == .ethernet) {
                        //top priority
                        context.targetDevice.activeInternetInterface = .ethernet
                    } else if (interface.type == .wifi) {
                        //has priority over .ppp, but not over .ethernet
                        if (context.targetDevice.activeInternetInterface == nil || context.targetDevice.activeInternetInterface! == .ppp) {
                            context.targetDevice.activeInternetInterface = .wifi
                        }
                    } else if (interface.type == .ppp) {
                        //lowest priority, only set if there's no other interface
                        if (context.targetDevice.activeInternetInterface == nil) {
                            context.targetDevice.activeInternetInterface = .ppp
                        }
                    }
                }

                if (context.targetDevice.activeInternetInterface == nil) {
                    self.stepCompleted()
                } else {
                    self.start()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
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

    private func getTargetDeviceActiveSim() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendGetActiveSim () { [weak self, weak context] result, externalSim in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.transceiver!.sendGetActiveSim: \(result.description()), externalSim: \(externalSim as Optional)")

            if (result == .NONE) {
                context.targetDevice.externalSim = externalSim!
                if (externalSim!) {
                    self.fail(withReason: .ExternalSimNotSupported, severity: .Fatal)
                } else {
                    self.start()
                }
            } else if (result == .INVALID_STATE) {
                self.fail(withReason: .BoronModemError)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func getTargetDeviceICCID() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendGetIccid () { [weak self, weak context] result, iccid in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.transceiver!.sendGetIccid: \(result.description()), iccid: \(iccid as Optional)")

            if (result == .NONE) {
                context.targetDevice.deviceICCID = iccid!
                self.start()
            } else if (result == .INVALID_STATE) {
                self.fail(withReason: .BoronModemError)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.targetDevice.activeInternetInterface = nil
    }
}
