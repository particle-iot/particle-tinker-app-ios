//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class Gen3SetupControlPanelInfoActivateSimViewController : Gen3SetupControlPanelInfoDeactivateSimViewController {

    @IBOutlet weak var priceInfo1Label: ParticleLabel!
    @IBOutlet weak var priceInfo2Label: ParticleLabel!
    
    override var customTitle: String {
        return Gen3SetupStrings.ControlPanel.Cellular.ActivateSim.Title
    }

    override func setContent() {
        titleLabel.text = Gen3SetupStrings.ControlPanel.Cellular.ActivateSim.TextTitle
        textLabel.text = Gen3SetupStrings.ControlPanel.Cellular.ActivateSim.Text.replacingOccurrences(of: "{{iccid}}", with: context.targetDevice.sim!.iccidEnding()!)

        continueButton.setTitle(Gen3SetupStrings.ControlPanel.Cellular.ActivateSim.ContinueButton, for: .normal)
        noteLabel.text = Gen3SetupStrings.ControlPanel.Cellular.ActivateSim.Note
    }
}
