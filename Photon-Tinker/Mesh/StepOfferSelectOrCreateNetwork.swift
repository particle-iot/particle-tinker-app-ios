//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepOfferSelectOrCreateNetwork : MeshSetupStep {

    override func start() {

        if let setupMesh = self.context.userSelectedToSetupMesh, setupMesh == false {
            //if in previous step user selected not to create networks, just complete the step
            self.stepCompleted()
        } else if (self.context.userSelectedToCreateNetwork != nil) {
            //if user has already selected the mesh network we also complete the step
            self.stepCompleted()
        } else {
            self.context.delegate.meshSetupDidEnterState(state: .TargetInternetConnectedDeviceScanningForNetworks)
            self.scanNetworks()
        }
    }

    func scanNetworks() {
        self.context.targetDevice.transceiver!.sendScanNetworks { result, networks in
            self.log("sendScanNetworks: \(result.description()), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")

            if (self.context.canceled) {
                return
            }

            if (result == .NONE) {
                self.context.targetDevice.meshNetworks = self.removeRepeatedMeshNetworks(networks!)
            } else {
                //this command will be repeated multiple times, no need to trigger errors.. just pretend all is fine
                self.context.targetDevice.meshNetworks = []
            }
            self.getUserOptionalNetworkSelection()
        }
    }

    private func getUserOptionalNetworkSelection() {
        var networks = [String: MeshSetupNetworkCellInfo]()

        for network in self.context.targetDevice.meshNetworks! {
            networks[network.extPanID] = MeshSetupNetworkCellInfo(name: network.name, extPanID: network.extPanID, userOwned: false, deviceCount: nil)
        }

        for apiNetwork in self.context.apiNetworks! {
            if let xpanId = apiNetwork.xpanId, var meshNetwork = networks[xpanId] {
                meshNetwork.userOwned = true
                meshNetwork.deviceCount = apiNetwork.deviceCount
                networks[xpanId] = meshNetwork
            }
        }

        self.context.delegate.meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: Array(networks.values))
    }

    func setOptionalSelectedNetwork(selectedNetworkExtPanID: String?) -> MeshSetupFlowError? {
        if (selectedNetworkExtPanID != nil) {
            self.context.userSelectedToCreateNetwork = false

            for network in self.context.targetDevice.meshNetworks! {
                if network.extPanID == selectedNetworkExtPanID! {
                    self.context.selectedNetworkMeshInfo = network
                    break
                }
            }
        } else {
            self.context.userSelectedToCreateNetwork = true
            self.context.selectedNetworkMeshInfo = nil
        }

        self.stepCompleted()

        return nil
    }

    private func removeRepeatedMeshNetworks(_ networks: [MeshSetupNetworkInfo]) -> [MeshSetupNetworkInfo] {
        var meshNetworkIds:Set<String> = []
        var filtered:[MeshSetupNetworkInfo] = []

        for network in networks {
            if (!meshNetworkIds.contains(network.extPanID)) {
                meshNetworkIds.insert(network.extPanID)
                filtered.append(network)
            }
        }

        return filtered
    }
}
