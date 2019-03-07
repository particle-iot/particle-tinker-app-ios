//
// Created by Raimundas Sakalauskas on 2019-03-07.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepCreateNetwork : MeshSetupStep {

    private var listeningMode: Bool = false

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.newNetworkId == nil) {
            context.delegate.meshSetupDidEnterState(state: .CreateNetworkStarted)
            self.createNetworkInAPI()
        } else if (context.selectedNetworkMeshInfo == nil ) {
            if (!listeningMode) {
                self.startTargetDeviceListening()
            } else {
                self.createNetworkInMesh()
            }
        } else {
            self.stepCompleted()
        }
    }

    override func reset() {
        self.listeningMode = false
    }

    private func createNetworkInAPI() {
        guard let context = self.context else {
            return
        }

        var networkType = ParticleNetworkType.microWifi
        if let interface = context.targetDevice.activeInternetInterface, interface == .ppp {
            networkType = ParticleNetworkType.microCellular
        }

        ParticleCloud.sharedInstance().createNetwork(context.newNetworkName!,
                gatewayDeviceID: context.targetDevice.deviceId!,
                gatewayDeviceICCID: networkType == .microCellular ? context.targetDevice.deviceICCID : nil,
                networkType: networkType) {
            [weak self, weak context] network, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("createNetwork: \(network as Optional), error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToCreateNetwork, nsError: error)
                return
            }

            if let network = network {
                context.newNetworkId = network.id
                context.delegate.meshSetupDidEnterState(state: .CreateNetworkStep1Done)
                self.start()
            }
        }
    }

    private func startTargetDeviceListening() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendStarListening { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendStarListening: \(result.description())")

            if (result == .NONE) {
                self.listeningMode = true
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func createNetworkInMesh() {
        guard let context = self.context else {
            return
        }

        context.targetDevice.transceiver!.sendCreateNetwork(name: context.newNetworkName!, password: context.newNetworkPassword!, networkId: context.newNetworkId!) {
            [weak self, weak context] result, networkInfo in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendCreateNetwork: \(result.description()), networkInfo: \(networkInfo as Optional)")

            if (result == .NONE) {
                self.log("Setting current target device as commissioner device part 1")
                context.selectedNetworkMeshInfo = networkInfo!
                context.selectedNetworkPassword = context.newNetworkPassword

                context.delegate.meshSetupDidCreateNetwork(network: MeshSetupNetworkCellInfo(name: networkInfo!.name, extPanID: networkInfo!.extPanID, userOwned: true, deviceCount: 1))
                context.delegate.meshSetupDidEnterState(state: .CreateNetworkCompleted)
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}
