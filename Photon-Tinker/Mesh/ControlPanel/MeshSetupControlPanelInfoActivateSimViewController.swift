//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelInfoActivateSimViewController : MeshSetupControlPanelInfoDeactivateSimViewController {

    @IBOutlet weak var priceInfo1Label: MeshLabel!
    @IBOutlet weak var priceInfo2Label: MeshLabel!
    
    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Cellular.ActivateSim.Title
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ControlPanel.Cellular.ActivateSim.TextTitle
        textLabel.text = MeshSetupStrings.ControlPanel.Cellular.ActivateSim.Text.replacingOccurrences(of: "{{iccid}}", with: context.targetDevice.sim!.iccidEnding()!)

        continueButton.setTitle(MeshSetupStrings.ControlPanel.Cellular.ActivateSim.ContinueButton, for: .normal)
        noteLabel.text = MeshSetupStrings.ControlPanel.Cellular.ActivateSim.Note
    }
}
