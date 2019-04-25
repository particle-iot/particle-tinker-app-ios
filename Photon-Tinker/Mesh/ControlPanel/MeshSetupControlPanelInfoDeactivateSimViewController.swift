//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelInfoDeactivateSimViewController : MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var textLabel: MeshLabel!

    @IBOutlet weak var continueButton: MeshSetupButton!
    @IBOutlet weak var noteLabel: MeshLabel!

    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Cellular.DeactivateSim.Title
    }

    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }

    internal weak var context: MeshSetupContext!
    internal var infoCallback: (() -> ())!

    func setup(context: MeshSetupContext, didFinish: @escaping () -> ()) {
        self.context = context
        self.deviceType = context.targetDevice.type
        self.infoCallback = didFinish
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.ExtraLargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
        noteLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.DetailsTextColor)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ControlPanel.Cellular.DeactivateSim.TextTitle
        textLabel.text = MeshSetupStrings.ControlPanel.Cellular.DeactivateSim.Text.replacingOccurrences(of: "{{iccid}}", with: context.targetDevice.sim!.iccidEnding()!)
        noteLabel.text = MeshSetupStrings.ControlPanel.Cellular.DeactivateSim.Note
        continueButton.setTitle(MeshSetupStrings.ControlPanel.Cellular.DeactivateSim.ContinueButton, for: .normal)
    }

    @IBAction func continueButtonClicked(_ sender: Any) {
        self.fade()

        self.infoCallback()
    }


}
