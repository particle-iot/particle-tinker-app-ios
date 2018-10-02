//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupCreatingNetworkViewController: MeshSetupProgressViewController, Storyboardable {

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.CreatingNetwork.SuccessTitle
        successTextLabel.text = MeshSetupStrings.CreatingNetwork.SuccessText

        progressTitleLabel.text = MeshSetupStrings.CreatingNetwork.Title

        self.progressTextLabelValues = [
            MeshSetupStrings.CreatingNetwork.Text1,
            MeshSetupStrings.CreatingNetwork.Text2,
            MeshSetupStrings.CreatingNetwork.Text3,
            MeshSetupStrings.CreatingNetwork.Text4,
        ]

        setProgressLabelValues()
    }

    func setState(_ state: MeshSetupFlowState) {
        DispatchQueue.main.async {
            switch state {
                case .CreateNetworkStarted:
                    self.setStep(0)
                case .CreateNetworkStep1Done:
                    self.setStep(1)
                case .CreateNetworkStep2Done:
                    self.setStep(2)
                case .CreateNetworkStep3Done:
                    self.setStep(3)
                case .CreateNetworkCompleted:
                    self.setStep(4)
                default:
                    fatalError("this should never happen")
            }
        }
    }
}
