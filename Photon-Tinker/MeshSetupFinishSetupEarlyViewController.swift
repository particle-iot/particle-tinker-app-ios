//
//  MeshSetupSuccessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/25/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupFinishSetupEarlyViewController: MeshSetupSuccessViewController {

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.FinishSetupEarly.SuccessTitle
        successTextLabel.text = MeshSetupStrings.FinishSetupEarly.SuccessText

        continueLabel.text = MeshSetupStrings.FinishSetupEarly.ContinueSetupLabel
        continueButton.setTitle(MeshSetupStrings.FinishSetupEarly.ContinueSetupButton, for: .normal)

        doneLabel.text = MeshSetupStrings.FinishSetupEarly.DoneLabel
        doneButton.setTitle(MeshSetupStrings.FinishSetupEarly.DoneButton, for: .normal)
    }
}
