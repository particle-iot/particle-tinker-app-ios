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
        successTitleLabel.text = MeshStrings.JoiningNetwork.SuccessTitle
        successTextLabel.text = MeshStrings.JoiningNetwork.SuccessText

        progressTitleLabel.text = MeshStrings.JoiningNetwork.Title

        self.progressTextLabelValues = [
            MeshStrings.JoiningNetwork.Text1,
            MeshStrings.JoiningNetwork.Text2,
            MeshStrings.JoiningNetwork.Text3
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
