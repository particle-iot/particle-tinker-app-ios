//
//  MeshSetupJoiningNetworkViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/23/18.
//  Copyright © 2018 spark. All rights reserved.
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
                case .JoiningNetworkStep1Done, .JoiningNetworkStep2Done, .JoiningNetworkCompleted:
                    self.advance()
                default:
                    fatalError("this should never happen")
            }
        }
    }
}
