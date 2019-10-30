//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupNetworkCreatedViewController: MeshSetupSuccessViewController {

//    static var nibName: String {
//        return "MeshSetupSuccessView"
//    }

    override func setContent() {
        successTitleLabel.text = MeshStrings.NetworkCreated.SuccessTitle
        successTextLabel.text = MeshStrings.NetworkCreated.SuccessText

        continueLabel.text = MeshStrings.NetworkCreated.ContinueSetupLabel
        continueButton.setTitle(MeshStrings.NetworkCreated.ContinueSetupButton, for: .normal)

        doneLabel.text = MeshStrings.NetworkCreated.DoneLabel
        doneButton.setTitle(MeshStrings.NetworkCreated.DoneButton, for: .normal)
    }
}
