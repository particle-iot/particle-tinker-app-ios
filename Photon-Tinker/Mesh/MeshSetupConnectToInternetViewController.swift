//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupConnectToInternetViewController: MeshSetupProgressViewController, Storyboardable {

    static var nibName: String {
        return "MeshSetupProgressView"
    }

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.ConnectToInternet.SuccessTitle
        successTextLabel.text = MeshSetupStrings.ConnectToInternet.SuccessText

        progressTitleLabel.text = MeshSetupStrings.ConnectToInternet.Title

        self.progressTextLabelValues = [
            MeshSetupStrings.ConnectToInternet.Text1,
            MeshSetupStrings.ConnectToInternet.Text2
        ]

        setProgressLabelValues()
    }

    func setState(_ state: MeshSetupFlowState) {
        DispatchQueue.main.async {
            switch state {
                case .TargetDeviceConnectingToInternetStarted:
                    self.setStep(0)
                case .TargetDeviceConnectingToInternetStep1Done:
                    self.setStep(1)
                case .TargetDeviceConnectingToInternetCompleted:
                    self.setStep(2)
                default:
                    fatalError("this should never happen")
            }
        }
    }
}
