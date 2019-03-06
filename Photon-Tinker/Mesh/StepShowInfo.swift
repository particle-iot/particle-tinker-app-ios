//
// Created by Raimundas Sakalauskas on 2019-03-06.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepShowInfo : MeshSetupStep {
    override func start() {
        //for xenon joiner flow setupMesh will be nil, so if there's network info & nil for setup mesh, then it's
        //a continued joiner flow and we want to skip this step
        if (self.context.selectedNetworkMeshInfo != nil && self.context.userSelectedToSetupMesh == nil) {
            self.stepCompleted()
        } else {
            var gatewayFlow = false
            if let setupMesh = self.context.userSelectedToSetupMesh, let createNetwork = self.context.userSelectedToCreateNetwork, setupMesh == true, createNetwork == true {
                gatewayFlow = true
            }
            self.context.delegate.meshSetupDidRequestToShowInfo(gatewayFlow: gatewayFlow)
        }
    }

    func setInfoDone() -> MeshSetupFlowError? {
        self.stepCompleted()

        return nil
    }

}
