//
//  MeshSetupSuccessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/25/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupNetworkCreatedViewController: MeshSetupSuccessViewController {

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.NetworkCreated.SuccessTitle
        successTextLabel.text = MeshSetupStrings.NetworkCreated.SuccessText

        continueLabel.text = MeshSetupStrings.NetworkCreated.ContinueSetupLabel
        continueButton.setTitle(MeshSetupStrings.NetworkCreated.ContinueSetupButton, for: .normal)

        doneLabel.text = MeshSetupStrings.NetworkCreated.DoneLabel
        doneButton.setTitle(MeshSetupStrings.NetworkCreated.DoneButton, for: .normal)
    }
}
