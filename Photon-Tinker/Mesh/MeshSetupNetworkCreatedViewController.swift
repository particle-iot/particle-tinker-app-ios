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
        successTitleLabel.text = Gen3SetupStrings.NetworkCreated.SuccessTitle
        successTextLabel.text = Gen3SetupStrings.NetworkCreated.SuccessText

        continueLabel.text = Gen3SetupStrings.NetworkCreated.ContinueSetupLabel
        continueButton.setTitle(Gen3SetupStrings.NetworkCreated.ContinueSetupButton, for: .normal)

        doneLabel.text = Gen3SetupStrings.NetworkCreated.DoneLabel
        doneButton.setTitle(Gen3SetupStrings.NetworkCreated.DoneButton, for: .normal)
    }
}
