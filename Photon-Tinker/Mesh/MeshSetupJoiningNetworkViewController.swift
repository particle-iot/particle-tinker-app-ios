//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupJoiningNetworkViewController: MeshSetupProgressViewController, Storyboardable {

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.JoiningNetwork.SuccessTitle
        successTextLabel.text = MeshSetupStrings.JoiningNetwork.SuccessText

        progressTitleLabel.text = MeshSetupStrings.JoiningNetwork.Title

        self.progressTextLabelValues = [
            MeshSetupStrings.JoiningNetwork.Text1,
            MeshSetupStrings.JoiningNetwork.Text2,
            MeshSetupStrings.JoiningNetwork.Text3
        ]

        setProgressLabelValues()
    }

    func setState(_ state: MeshSetupFlowState) {
        DispatchQueue.main.async {
            switch state {
                case .JoiningNetworkStarted:
                    self.setStep(0)
                case .JoiningNetworkStep1Done:
                    self.setStep(1)
                case .JoiningNetworkStep2Done:
                    self.setStep(2)
                case .JoiningNetworkCompleted:
                    self.setStep(3)
                default:
                    fatalError("this should never happen")
            }
        }
    }
}
