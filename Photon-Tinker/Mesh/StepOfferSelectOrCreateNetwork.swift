//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepOfferSelectOrCreateNetwork : MeshSetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        if let setupMesh = context.userSelectedToSetupMesh, setupMesh == false {
            //if in previous step user selected not to create networks, just complete the step
            self.stepCompleted()
        } else if (context.userSelectedToCreateNetwork != nil) {
            //if user has already selected the mesh network we also complete the step
            self.stepCompleted()
        } else {
            context.delegate.meshSetupDidEnterState(state: .TargetInternetConnectedDeviceScanningForNetworks)
            self.scanNetworks()
        }
    }

    func scanNetworks() {
        context?.targetDevice.transceiver!.sendScanNetworks { [weak self, weak context] result, networks in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("sendScanNetworks: \(result.description()), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")

            if (result == .NONE) {
                context.targetDevice.meshNetworks = self.removeRepeatedMeshNetworks(networks!)
            } else {
                //this command will be repeated multiple times, no need to trigger errors.. just pretend all is fine
                context.targetDevice.meshNetworks = []
            }
            self.getUserOptionalNetworkSelection()
        }
    }

    private func getUserOptionalNetworkSelection() {
        guard let context = self.context else {
            return
        }

        var networks = [String: MeshSetupNetworkCellInfo]()

        for network in context.targetDevice.meshNetworks! {
            networks[network.extPanID] = MeshSetupNetworkCellInfo(name: network.name, extPanID: network.extPanID, userOwned: false, deviceCount: nil)
        }

        for apiNetwork in context.apiNetworks! {
            if let xpanId = apiNetwork.xpanId, var meshNetwork = networks[xpanId] {
                meshNetwork.userOwned = true
                meshNetwork.deviceCount = apiNetwork.deviceCount
                networks[xpanId] = meshNetwork
            }
        }

        context.delegate.meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: Array(networks.values))
    }

    func setOptionalSelectedNetwork(selectedNetworkExtPanID: String?) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        if (selectedNetworkExtPanID != nil) {
            context.userSelectedToCreateNetwork = false

            for network in context.targetDevice.meshNetworks! {
                if network.extPanID == selectedNetworkExtPanID! {
                    context.selectedNetworkMeshInfo = network
                    break
                }
            }
        } else {
            context.userSelectedToCreateNetwork = true
            context.selectedNetworkMeshInfo = nil
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
