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
    @IBOutlet weak var successTitleLabel: ParticleLabel!
    @IBOutlet weak var successTextLabel: ParticleLabel!
    
    
    @IBOutlet weak var continueLabel: ParticleLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!
    
    @IBOutlet weak var doneLabel: ParticleLabel!
    @IBOutlet weak var doneButton: MeshSetupButton!
    
    @IBOutlet var splitterView: UIView!

    private var callback: ((Bool) -> ())!

    func setup(didSelectDone: @escaping (Bool) -> (), deviceName: String, networkName: String? = nil) {
        self.callback = didSelectDone
        self.deviceName = deviceName
        self.networkName = networkName
    }

    override func setStyle() {
        successTitleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

        continueLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)

        doneLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        doneButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
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
