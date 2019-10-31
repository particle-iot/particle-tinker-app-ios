//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 Particle. All rights reserved.
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
            //if device has no network interfaces, this will trigger UI to show the screen that has
            if context.targetDevice.hasActiveInternetInterface() {
                context.delegate.meshSetupDidEnterState(self, state: .TargetInternetConnectedDeviceScanningForNetworks)
                self.scanNetworks()
            } else {
                context.delegate.meshSetupDidEnterState(self, state: .TargetDeviceScanningForNetworks)
                self.scanNetworks()
            }
        }
    }

    func scanNetworks() {
        context?.targetDevice.transceiver?.sendScanNetworks { [weak self, weak context] result, networks in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("sendScanNetworks: \(result.description()), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")

            if (result == .NONE) {
                context.targetDevice.meshNetworks = MeshSetupStep.removeRepeatedMeshNetworks(networks!)
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

        let networks = MeshSetupStep.GetMeshNetworkCells(meshNetworks: context.targetDevice.meshNetworks!, apiMeshNetworks: context.apiNetworks!)
        context.delegate.meshSetupDidRequestToSelectOrCreateNetwork(self, availableNetworks: networks)
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

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.userSelectedToCreateNetwork = nil
        context.selectedNetworkMeshInfo = nil
    }
}
