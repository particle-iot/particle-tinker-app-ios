//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelInfoActivateSimViewController : MeshSetupControlPanelInfoDeactivateSimViewController {

    @IBOutlet weak var priceInfo1Label: MeshLabel!
    @IBOutlet weak var priceInfo2Label: MeshLabel!
    
    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Cellular.DeactivateSim.Title
    }

    override func setStyle() {
        super.setStyle()

        priceInfo1Label.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        priceInfo2Label.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ControlPanel.Cellular.ActivateSim.TextTitle
        textLabel.text = MeshSetupStrings.ControlPanel.Cellular.ActivateSim.Text.replacingOccurrences(of: "{{iccid}}", with: context.targetDevice.sim!.iccidEnding()!)
        priceInfo1Label.text = MeshSetupStrings.ControlPanel.Cellular.ActivateSim.PriceInfo1
        priceInfo2Label.text = MeshSetupStrings.ControlPanel.Cellular.ActivateSim.PriceInfo2

        continueButton.setTitle(MeshSetupStrings.ControlPanel.Cellular.ActivateSim.ContinueButton, for: .normal)
        noteLabel.text = MeshSetupStrings.ControlPanel.Cellular.ActivateSim.Note
    }
}
