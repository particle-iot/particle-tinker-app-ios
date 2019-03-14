//
// Created by Raimundas Sakalauskas on 2019-03-08.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetUserNetworkSelection : MeshSetupStep {

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.selectedNetworkMeshInfo != nil) {
            self.stepCompleted()
        } else {
            context.delegate.meshSetupDidEnterState(self, state: .TargetDeviceScanningForNetworks)
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
                context.targetDevice.meshNetworks = MeshSetupStep.removeRepeatedMeshNetworks(networks!)
            } else {
                //this command will be repeated multiple times, no need to trigger errors.. just pretend all is fine
                context.targetDevice.meshNetworks = []
            }
            self.getUserNetworkSelection()
        }
    }

    private func getUserNetworkSelection() {
        guard let context = self.context else {
            return
        }

        let networks = MeshSetupStep.GetMeshNetworkCells(meshNetworks: context.targetDevice.meshNetworks!, apiMeshNetworks: context.apiNetworks!)
        context.delegate.meshSetupDidRequestToSelectNetwork(self, availableNetworks: networks)
    }

    func setSelectedNetwork(selectedNetworkExtPanID: String) -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        context.selectedNetworkMeshInfo = nil
        for network in context.targetDevice.meshNetworks! {
            if network.extPanID == selectedNetworkExtPanID {
                context.selectedNetworkMeshInfo = network
                break
            }
        }

        self.log("self.selectedNetworkMeshInfo: \(context.selectedNetworkMeshInfo)")
        self.stepCompleted()

        return nil
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.selectedNetworkMeshInfo = nil
    }
}
