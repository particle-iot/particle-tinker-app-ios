//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepControlPanelFlowCompleted: MeshSetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        self.stepCompleted()
        context.delegate.meshSetupDidCompleteControlPanelFlow(self)
    }
}
