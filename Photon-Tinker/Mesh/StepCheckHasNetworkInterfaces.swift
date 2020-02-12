//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepCheckHasNetworkInterfaces: Gen3SetupStep {

    private var simStatusReceived: Bool = false
    private var forceSimStatus: Bool = false

    init(forceSimStatus: Bool = false) {
        self.forceSimStatus = forceSimStatus
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.targetDevice.activeInternetInterface == nil) {
            self.getActiveInternetInterface()
        } else if (context.targetDevice.sim == nil) {
            self.stepCompleted()
        } else if (context.targetDevice.sim!.isExternal == nil) {
            self.getTargetDeviceActiveSim()
        } else if (context.targetDevice.sim!.isExternal == true) {
            self.fail(withReason: .ExternalSimNotSupported, severity: .Fatal)
        } else if (context.targetDevice.sim!.iccid == nil) {
            self.getTargetDeviceICCID()
        } else if (context.targetDevice.sim!.active == nil) {
            self.getSimInfo()
        } else if (context.targetDevice.sim!.status == nil && simStatusReceived == false) {
            self.getSimStatus()
        } else {
            self.stepCompleted()
        }

    }

    override func reset() {
        self.simStatusReceived = false
    }

    private func getActiveInternetInterface() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver?.sendGetInterfaceList {
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
                    if (interface.type == .thread) {
                        context.targetDevice.supportsMesh = true
                    }

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

                if let interface = context.targetDevice.activeInternetInterface {
                    if (interface == .ppp || self.forceSimStatus) {
                        context.targetDevice.sim = Gen3SetupSim()
                    } else {
                        context.targetDevice.sim = nil
                    }
                    self.start()
                } else {
                    context.targetDevice.sim = nil
                    self.stepCompleted()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
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
                context.targetDevice.sim!.status = .inactiveNeverActivated
                context.targetDevice.sim!.dataLimit = -1
                self.simStatusReceived = true
                self.start()
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



    private func getTargetDeviceActiveSim() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver?.sendGetActiveSim () { [weak self, weak context] result, externalSim in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.transceiver?.sendGetActiveSim: \(result.description()), externalSim: \(externalSim as Optional)")

            if (result == .NONE) {
                context.targetDevice.sim!.isExternal = externalSim!
                self.start()
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

        context.targetDevice.transceiver?.sendGetIccid () { [weak self, weak context] result, iccid in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.transceiver?.sendGetIccid: \(result.description()), iccid: \(iccid as Optional)")

            if (result == .NONE) {
                context.targetDevice.sim!.iccid = iccid!
                self.start()
            } else if (result == .INVALID_STATE) {
                self.fail(withReason: .BoronModemError)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.targetDevice.activeInternetInterface = nil
        context.targetDevice.sim = nil
    }



//    private func switchToInternalSim() {
//        guard let context = self.context else {
//            return
//        }
//
//        context.targetDevice.transceiver?.sendSetActiveSim(useExternalSim: false) { [weak self, weak context] result in
//            guard let self = self, let context = context, !context.canceled else {
//                return
//            }
//
//            self.log("targetDevice.transceiver?.sendSetActiveSim: \(result.description())")
//
//            if (result == .NONE) {
//                context.targetDevice.externalSim = nil
//                self.prepareForTargetDeviceReboot()
//            } else if (result == .INVALID_STATE) {
//                self.fail(withReason: .BoronModemError)
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    func prepareForTargetDeviceReboot() {
//        context?.targetDevice.transceiver?.sendSetStartupMode(startInListeningMode: true) { [weak self, weak context] result in
//            guard let self = self, let context = context, !context.canceled else {
//                return
//            }
//
//            self.log("targetDevice.sendSetStartupMode: \(result.description())")
//
//            if (result == .NONE) {
//                self.sendDeviceReset()
//            } else if (result == .NOT_SUPPORTED) {
//                self.sendDeviceReset()
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    func sendDeviceReset() {
//        context?.targetDevice.transceiver?.sendSystemReset() { [weak self, weak context] result  in
//            guard let self = self, let context = context, !context.canceled else {
//                return
//            }
//
//            self.log("targetDevice.sendSystemReset: \(result.description())")
//
//            if (result == .NONE) {
//                //if all is fine, connection will be dropped and the setup will return few steps in dropped connection handler
//            } else {
//                self.handleBluetoothErrorResult(result)
//            }
//        }
//    }
//
//    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: Gen3SetupBluetoothConnection) -> Bool {
//        guard let context = self.context else {
//            return false
//        }
//
//        self.log("force reconnect to device")
//
//        let step = context.stepDelegate.rewindTo(self, step: StepConnectToTargetDevice.self, runStep: false) as! StepConnectToTargetDevice
//        step.reset()
//        step.reconnectAfterForcedReboot = true
//        step.reconnectAfterForcedRebootRetry = 1
//        step.start()
//
//        return true
//    }
}
