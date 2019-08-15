//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepEnsureCorrectSelectedWifiNetworkPassword : MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        if context.selectedWifiNetworkInfo!.security == .noSecurity {
            self.setSelectedWifiNetworkPassword("") { error in
                self.log("WIFI with no password error: \(error)")
            }
            return
        }
        context.delegate.meshSetupDidRequestToEnterSelectedWifiNetworkPassword(self)
    }

    func setSelectedWifiNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard let context = self.context else {
            onComplete(nil)
            return
        }

        //TODO: validate length based on security
        guard self.validateWifiNetworkPassword(password) || (context.selectedWifiNetworkInfo!.security == .noSecurity) else {
            onComplete(.WifiPasswordTooShort)
            return
        }

        self.log("trying password with character count: \(password.count)")
        context.targetDevice!.transceiver?.sendJoinNewWifiNetwork(network: context.selectedWifiNetworkInfo!, password: password) {
            [weak self, weak context] result in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendJoinNewWifiNetwork: \(result.description())")
            if (context.selectedWifiNetworkInfo!.security == .noSecurity) {
                if (result == .NONE) {
                    onComplete(nil)
                    self.stepCompleted()
                } else {
                    onComplete(nil)
                    self.handleBluetoothErrorResult(result)
                }
            } else {
                if (result == .NONE) {
                    onComplete(nil)
                    self.stepCompleted()
                } else if (result == .NOT_FOUND) {
                    onComplete(.WrongNetworkPassword)
                } else {
                    onComplete(.BluetoothTimeout)
                }
            }
        }
    }

    private func validateWifiNetworkPassword(_ password: String) -> Bool {
        return password.count >= 5
    }
}
