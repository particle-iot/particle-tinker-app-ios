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
                case .CreateNetworkStep1Done, .CreateNetworkStep2Done, .CreateNetworkStep3Done, .CreateNetworkCompleted:
                    self.advance()
                default:
                    fatalError("this should never happen")
            }
        }
    }
}
