//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol Gen3SetupStepDelegate {
    func stepCompleted(_ sender: Gen3SetupStep)
    func rewindTo(_ sender: Gen3SetupStep, step: Gen3SetupStep.Type, runStep: Bool) -> Gen3SetupStep
    func fail(_ sender: Gen3SetupStep, withReason reason: Gen3SetupFlowError, severity: Gen3SetupErrorSeverity, nsError: Error?)
}

class Gen3SetupStep: NSObject {
    var context: Gen3SetupContext?

    func log(_ message: String) {
        ParticleLogger.logInfo("Gen3SetupFlow", format: message, withParameters: getVaList([]))
    }

    func run(context: Gen3SetupContext) {
        self.context = context

        self.start()
    }

    func stepCompleted() {
        guard let context = self.context else {
            return
        }

        context.stepDelegate.stepCompleted(self)
        self.context = nil
    }

    func reset() {
        //clear step flags
    }

    func start() {
        fatalError("not implemented!!!")
    }

    func retry() {
        self.start()
    }

    func rewindFrom() {
        self.context = nil
    }

    func rewindTo(context: Gen3SetupContext) {
        self.context = context

        self.reset()
    }

    func handleBluetoothErrorResult(_ result: ControlReplyErrorType) {
        guard let context = self.context, !context.canceled else {
            return
        }

        if (result == .TIMEOUT && !context.bluetoothReady) {
            self.fail(withReason: .BluetoothDisabled)
        } else if (result == .TIMEOUT) {
            self.fail(withReason: .BluetoothTimeout)
        } else if (result == .INVALID_STATE) {
            self.fail(withReason: .InvalidDeviceState, severity: .Fatal)
        } else {
            self.fail(withReason: .BluetoothError)
        }
    }

    func fail(withReason reason: Gen3SetupFlowError, severity: Gen3SetupErrorSeverity = .Error, nsError: Error? = nil) {
        guard let context = self.context else {
            return
        }

        context.stepDelegate.fail(self, withReason: reason, severity: severity, nsError: nsError)
    }


    func handleBluetoothConnectionManagerError(_ error: BluetoothConnectionManagerError) -> Bool {
        return false
    }

    func handleBluetoothConnectionManagerPeripheralDiscovered(_ peripheral: CBPeripheral) -> Bool {
        return false
    }

    func handleBluetoothConnectionManagerConnectionCreated(_ connection: Gen3SetupBluetoothConnection) -> Bool {
        return false
    }

    func handleBluetoothConnectionManagerConnectionBecameReady(_ connection: Gen3SetupBluetoothConnection) -> Bool {
        return false
    }

    func handleBluetoothConnectionManagerConnectionDropped(_ connection: Gen3SetupBluetoothConnection) -> Bool {
        return false
    }


}

extension Gen3SetupStep {
    static func removeRepeatedMeshNetworks(_ networks: [Gen3SetupNetworkInfo]) -> [Gen3SetupNetworkInfo] {
        var meshNetworkIds:Set<String> = []
        var filtered:[Gen3SetupNetworkInfo] = []

        for network in networks {
            if (!meshNetworkIds.contains(network.extPanID)) {
                meshNetworkIds.insert(network.extPanID)
                filtered.append(network)
            }
        }

        return filtered.sorted { networkInfo, networkInfo2 in
            return networkInfo.name.localizedCaseInsensitiveCompare(networkInfo2.name) == .orderedAscending
        }
    }

    static func removeRepeatedWifiNetworks(_ networks: [Gen3SetupNewWifiNetworkInfo]) -> [Gen3SetupNewWifiNetworkInfo] {
        var wifiNetworkIds:Set<String> = []
        var filtered:[Gen3SetupNewWifiNetworkInfo] = []

        for network in networks {
            if (!wifiNetworkIds.contains(network.ssid)) {
                wifiNetworkIds.insert(network.ssid)
                filtered.append(network)
            }
        }

        return filtered.sorted { networkInfo, networkInfo2 in
            return networkInfo.ssid.localizedCaseInsensitiveCompare(networkInfo2.ssid) == .orderedAscending
        }
    }

    static func GetMeshNetworkCells(meshNetworks: [Gen3SetupNetworkInfo], apiMeshNetworks: [ParticleNetwork]) -> [Gen3SetupNetworkCellInfo] {
        var networks = [String: Gen3SetupNetworkCellInfo]()

        for network in meshNetworks {
            networks[network.extPanID] = Gen3SetupNetworkCellInfo(name: network.name, extPanID: network.extPanID, userOwned: false, deviceCount: nil)
        }

        for apiNetwork in apiMeshNetworks {
            if let xpanId = apiNetwork.xpanId, var meshNetwork = networks[xpanId] {
                meshNetwork.userOwned = true
                meshNetwork.deviceCount = apiNetwork.deviceCount
                networks[xpanId] = meshNetwork
            }
        }

        return Array(networks.values)
    }

    static func validateNetworkPassword(_ password: String) -> Bool {
        return password.count >= 6
    }


    static func validateNetworkName(_ networkName: String) -> Bool {
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
