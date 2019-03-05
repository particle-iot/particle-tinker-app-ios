//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepOfferSetupStandAloneOrWithNetwork : MeshSetupStep {
    override func start() {
       self.context.delegate.didRequestToSelectStandAloneOrMeshSetup()
    }

    func setSelectStandAloneOrMeshSetup(meshSetup: Bool) -> MeshSetupFlowError? {
        self.context.userSelectedToSetupMesh = meshSetup

        self.stepCompleted()

        return nil
    }
}
