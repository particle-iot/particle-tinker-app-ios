//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class MeshSetupControlPanelInfoActivateSimViewController : MeshSetupControlPanelInfoDeactivateSimViewController {

    @IBOutlet weak var priceInfo1Label: ParticleLabel!
    @IBOutlet weak var priceInfo2Label: ParticleLabel!
    
    override var customTitle: String {
        return MeshStrings.ControlPanel.Cellular.ActivateSim.Title
    }

    override func setContent() {
        titleLabel.text = MeshStrings.ControlPanel.Cellular.ActivateSim.TextTitle
        textLabel.text = MeshStrings.ControlPanel.Cellular.ActivateSim.Text.replacingOccurrences(of: "{{iccid}}", with: context.targetDevice.sim!.iccidEnding()!)

        continueButton.setTitle(MeshStrings.ControlPanel.Cellular.ActivateSim.ContinueButton, for: .normal)
        noteLabel.text = MeshStrings.ControlPanel.Cellular.ActivateSim.Note
    }
}
