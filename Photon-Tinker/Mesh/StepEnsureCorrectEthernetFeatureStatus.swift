//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureCorrectEthernetFeatureStatus: MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if context.targetDevice.enableEthernetDetectionFeature == nil {
            context.delegate.meshSetupDidRequestToSelectEthernetStatus(self)
        } else if context.targetDevice.ethernetDetectionFeature == nil {
            self.getFeatureFlag()
        } else if (context.targetDevice.enableEthernetDetectionFeature != context.targetDevice.ethernetDetectionFeature) {
            self.setCorrectEthernetFeatureStatus()
        } else {
            self.stepCompleted()
        }
    }

    func setTargetUseEthernet(useEthernet: Bool) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.targetDevice.enableEthernetDetectionFeature = useEthernet
        self.start()

        return nil
    }

    private func getFeatureFlag() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendGetFeature(feature: .ethernetDetection) { [weak self, weak context] result, enabled in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            context.targetDevice.ethernetDetectionFeature = enabled!
            self.log("targetDevice.sendGetFeature: \(result.description()) enabled: \(enabled as Optional)")
            self.log("self.targetDevice.enableEthernetFeature = \(context.targetDevice.enableEthernetDetectionFeature)")

            if (result == .NONE) {
                self.start()
            } else if (result == .NOT_SUPPORTED) {
                self.stepCompleted()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    func setCorrectEthernetFeatureStatus() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendSetFeature(feature: .ethernetDetection, enabled: context.targetDevice.enableEthernetDetectionFeature!) { [weak self, weak context] result  in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            context.targetDevice.ethernetDetectionFeature = nil
            context.targetDevice.activeInternetInterface = nil
            context.targetDevice.sim = nil
            self.log("targetDevice.sendSetFeature: \(result.description())")
            if (context.canceled) {
                return
            }

            if (result == .NONE) {
                self.prepareForTargetDeviceReboot()
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

        context.targetDevice.enableEthernetDetectionFeature = nil
        context.targetDevice.ethernetDetectionFeature = nil
    }

    func prepareForTargetDeviceReboot() {
        context?.targetDevice.transceiver!.sendSetStartupMode(startInListeningMode: true) { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendSetStartupMode: \(result.description())")

            if (result == .NONE) {
                self.sendDeviceReset()
            } else if (result == .NOT_SUPPORTED) {
                self.sendDeviceReset()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    func sendDeviceReset() {
        context?.targetDevice.transceiver!.sendSystemReset() { [weak self, weak context] result  in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendSystemReset: \(result.description())")

            if (result == .NONE) {
                //if all is fine, connection will be dropped and the setup will return few steps in dropped connection handler
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: MeshSetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        self.log("force reconnect to device")

        let step = context.stepDelegate.rewindTo(self, step: StepConnectToTargetDevice.self, runStep: false) as! StepConnectToTargetDevice
        step.reconnectAfterForcedReboot = true
        step.reconnectAfterForcedRebootRetry = 1
        step.start()

        return true
    }


}
