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
        if ScreenUtils.getPhoneScreenSizeClass() < .iPhone6 {
            titleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
            textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.PrimaryTextColor)

            continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
            noteLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.DetailSize, color: ParticleStyle.DetailsTextColor)
        } else {
            titleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.ExtraLargeSize, color: ParticleStyle.PrimaryTextColor)
            textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

            continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
            noteLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.DetailsTextColor)
        }

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
