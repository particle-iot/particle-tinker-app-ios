//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupNetworkCreatedViewController: MeshSetupSuccessViewController {

//    static var nibName: String {
//        return "MeshSetupSuccessView"
//    }

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.NetworkCreated.SuccessTitle
        successTextLabel.text = MeshSetupStrings.NetworkCreated.SuccessText

        continueLabel.text = MeshSetupStrings.NetworkCreated.ContinueSetupLabel
        continueButton.setTitle(MeshSetupStrings.NetworkCreated.ContinueSetupButton, for: .normal)

        doneLabel.text = MeshSetupStrings.NetworkCreated.DoneLabel
        doneButton.setTitle(MeshSetupStrings.NetworkCreated.DoneButton, for: .normal)
    }
}
