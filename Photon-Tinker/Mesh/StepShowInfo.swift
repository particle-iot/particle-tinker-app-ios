//
// Created by Raimundas Sakalauskas on 2019-03-06.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

enum MeshInfoType {
    case joinerFlow
    case creatorFlow
    case simStatusToggle
}

class StepShowInfo : MeshSetupStep {

    public let infoType: MeshInfoType

    init(_ infoType: MeshInfoType) {
        self.infoType = infoType
    }

    override func start() {

        guard let context = self.context else {
            return
        }

        //for xenon joiner flow setupMesh will be nil, so if there's network info & nil for setup mesh, then it's
        //a continued joiner flow and we want to skip this step
        if (context.selectedNetworkMeshInfo != nil && context.userSelectedToSetupMesh == nil) {
            self.stepCompleted()
        } else {
            self.context!.delegate.meshSetupDidRequestToShowInfo(self)
        }
    }


    func setInfoDone() -> MeshSetupFlowError? {
        guard let context = self.context else {
            return nil
        }

        self.stepCompleted()

        return nil
    }

}
