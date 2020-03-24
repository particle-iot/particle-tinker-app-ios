//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class Gen3SetupCreatingNetworkViewController: Gen3SetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "Gen3SetupProgressView"
    }

    override func setContent() {
        successTitleLabel.text = Gen3SetupStrings.CreatingNetwork.SuccessTitle
        successTextLabel.text = Gen3SetupStrings.CreatingNetwork.SuccessText

        progressTitleLabel.text = Gen3SetupStrings.CreatingNetwork.Title

        self.progressTextLabelValues = [
            Gen3SetupStrings.CreatingNetwork.Text1,
            Gen3SetupStrings.CreatingNetwork.Text2
        ]

        setProgressLabelValues()
    }

    override func setState(_ state: Gen3SetupFlowState) {
        DispatchQueue.main.async {
            switch state {
                case .CreateNetworkStarted:
                    self.setStep(0)
                case .CreateNetworkStep1Done:
                    self.setStep(1)
                case .CreateNetworkCompleted:
                    self.setStep(2)
                default:
                    fatalError("this should never happen")
            }
        }
    }
}
