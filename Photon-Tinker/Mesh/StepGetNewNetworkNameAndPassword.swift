//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetNewNetworkNameAndPassword : MeshSetupStep {
    override func start() {

        guard let context = self.context else {
            return
        }

        context.delegate.meshSetupDidRequestToEnterNewNetworkNameAndPassword()
    }


    func setNewNetworkName(name: String) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        guard self.validateNetworkName(name) else {
            return .NameTooShort
        }

        if let networks =  context.apiNetworks {
            for network in networks {
                if (network.name.lowercased() == name.lowercased()) {
                    return .NameInUse
                }
            }
        }


        self.log("set network name: \(name)")
        context.newNetworkName = name

        if (context.newNetworkName != nil && context.newNetworkPassword != nil) {
            self.stepCompleted()
        }

        return nil
    }


    func setNewNetworkPassword(password: String) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        guard self.validateNetworkPassword(password) else {
            return .PasswordTooShort
        }

        self.log("set network password: \(password)")
        context.newNetworkPassword = password

        if (context.newNetworkName != nil && context.newNetworkPassword != nil) {
            self.stepCompleted()
        }

        return nil
    }

    private func validateNetworkPassword(_ password: String) -> Bool {
        return password.count >= 6
    }


    private func validateNetworkName(_ networkName: String) -> Bool {
        //ensure proper length
        if (networkName.count == 0) || (networkName.count > 16) {
            return false
        }

        //ensure no illegal characters
        let regex = try! NSRegularExpression(pattern: "[^a-zA-Z0-9_\\-]+")
        let matches = regex.matches(in: networkName, options: [], range: NSRange(location: 0, length: networkName.count))
        return matches.count == 0
    }
}
