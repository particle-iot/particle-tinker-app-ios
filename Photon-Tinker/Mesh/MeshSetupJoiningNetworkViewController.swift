//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupJoiningNetworkViewController: MeshSetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "MeshSetupProgressView"
    }

    override func setContent() {
        successTitleLabel.text = Gen3SetupStrings.JoiningNetwork.SuccessTitle
        successTextLabel.text = Gen3SetupStrings.JoiningNetwork.SuccessText

        progressTitleLabel.text = Gen3SetupStrings.JoiningNetwork.Title

        self.progressTextLabelValues = [
            Gen3SetupStrings.JoiningNetwork.Text1,
            Gen3SetupStrings.JoiningNetwork.Text2,
            Gen3SetupStrings.JoiningNetwork.Text3
        ]

        setProgressLabelValues()
    }

    override func setState(_ state: MeshSetupFlowState) {
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
