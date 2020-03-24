//
// Created by Raimundas Sakalauskas on 2019-03-05.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class StepControlPanelFlowCompleted: Gen3SetupStep {
    override func start() {
        guard let context = self.context else {
            return
        }

        self.stepCompleted()
        context.delegate.gen3SetupDidCompleteControlPanelFlow(self)
    }
}
