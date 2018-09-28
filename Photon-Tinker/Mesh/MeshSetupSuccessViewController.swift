//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupSuccessViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!
    
    
    @IBOutlet weak var continueLabel: MeshLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!
    
    @IBOutlet weak var doneLabel: MeshLabel!
    @IBOutlet weak var doneButton: MeshSetupButton!
    
    @IBOutlet var splitterView: UIView!

    private var callback: ((Bool) -> ())!

    func setup(didSelectDone: @escaping (Bool) -> (), deviceName: String) {
        self.callback = didSelectDone
        self.deviceName = deviceName
    }

    override func setStyle() {
        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

        continueLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)

        doneLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        doneButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)
    }

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.Success.SuccessTitle
        successTextLabel.text = MeshSetupStrings.Success.SuccessText

        continueLabel.text = MeshSetupStrings.Success.SetupAnotherLabel
        continueButton.setTitle(MeshSetupStrings.Success.SetupAnotherButton, for: .normal)

        doneLabel.text = MeshSetupStrings.Success.DoneLabel
        doneButton.setTitle(MeshSetupStrings.Success.DoneButton, for: .normal)
    }

    @IBAction func setupAnotherButtonTapped(_ sender: Any) {
        callback(false)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        callback(true)
    }

}
