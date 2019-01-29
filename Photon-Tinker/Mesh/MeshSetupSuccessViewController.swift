//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupSuccessViewController: MeshSetupViewController, Storyboardable {

    static var nibName: String {
        return "MeshSetupSuccessView"
    }

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!
    
    
    @IBOutlet weak var continueLabel: MeshLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!
    
    @IBOutlet weak var doneLabel: MeshLabel!
    @IBOutlet weak var doneButton: MeshSetupButton!
    
    @IBOutlet var splitterView: UIView!

    private var callback: ((Bool) -> ())!

    override var allowBack: Bool {
        return false
    }

    func setup(didSelectDone: @escaping (Bool) -> (), deviceName: String, networkName: String? = nil) {
        self.callback = didSelectDone
        self.deviceName = deviceName
        self.networkName = networkName
    }

    override func setStyle() {
        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

        continueLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)

        doneLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        doneButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
    }

    override func setContent() {
        successTitleLabel.text = MeshSetupStrings.Success.SuccessTitle
        successTextLabel.text = MeshSetupStrings.Success.SuccessText

        if (self.networkName != nil) {
            continueLabel.text = MeshSetupStrings.Success.SetupAnotherLabel
        } else {
            continueLabel.text = ""
        }
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
