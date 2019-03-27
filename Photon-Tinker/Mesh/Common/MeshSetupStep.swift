//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

protocol MeshSetupStepDelegate {
    func stepCompleted(_ sender: MeshSetupStep)
    func rewindTo(_ sender: MeshSetupStep, step: MeshSetupStep.Type) -> MeshSetupStep
    func fail(_ sender: MeshSetupStep, withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?)
}

class MeshSetupStep: NSObject {
    var context: MeshSetupContext?

    func log(_ message: String) {
        ParticleLogger.logInfo("MeshSetupFlow", format: message, withParameters: getVaList([]))
    }

    func run(context: MeshSetupContext) {
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

    func rewindTo(context: MeshSetupContext) {
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

    func fail(withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity = .Error, nsError: Error? = nil) {
        guard let context = self.context else {
            return
        }

        context.stepDelegate.fail(self, withReason: reason, severity: severity, nsError: nsError)
    }


    func handleBluetoothConnectionManagerError(_ error: BluetoothConnectionManagerError) -> Bool {
        return false
    }

    func handleBluetoothConnectionManagerConnectionCreated(_ connection: MeshSetupBluetoothConnection) -> Bool {
        return false
    }

    func handleBluetoothConnectionManagerConnectionBecameReady(_ connection: MeshSetupBluetoothConnection) -> Bool {
        return false
    }

    func handleBluetoothConnectionManagerConnectionDropped(_ connection: MeshSetupBluetoothConnection) -> Bool {
        return false
    }


}

extension MeshSetupStep {
    static func removeRepeatedMeshNetworks(_ networks: [MeshSetupNetworkInfo]) -> [MeshSetupNetworkInfo] {
        var meshNetworkIds:Set<String> = []
        var filtered:[MeshSetupNetworkInfo] = []

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

    static func removeRepeatedWifiNetworks(_ networks: [MeshSetupNewWifiNetworkInfo]) -> [MeshSetupNewWifiNetworkInfo] {
        var wifiNetworkIds:Set<String> = []
        var filtered:[MeshSetupNewWifiNetworkInfo] = []

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

    static func GetMeshNetworkCells(meshNetworks: [MeshSetupNetworkInfo], apiMeshNetworks: [ParticleNetwork]) -> [MeshSetupNetworkCellInfo] {
        var networks = [String: MeshSetupNetworkCellInfo]()

        for network in meshNetworks {
            networks[network.extPanID] = MeshSetupNetworkCellInfo(name: network.name, extPanID: network.extPanID, userOwned: false, deviceCount: nil)
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
