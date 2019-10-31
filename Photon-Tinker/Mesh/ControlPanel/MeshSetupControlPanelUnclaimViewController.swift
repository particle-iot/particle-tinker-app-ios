//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class MeshSetupControlPanelUnclaimViewController : MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: ParticleLabel!
    @IBOutlet weak var textLabel: ParticleLabel!
    @IBOutlet weak var continueButton: ParticleButton!

    private var unclaimCallback: ((Bool) -> ())!

    override var customTitle: String {
        return MeshStrings.ControlPanel.Unclaim.Title
    }

    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }

    func setup(deviceName: String, callback: @escaping (Bool) -> ()) {
        self.deviceName = deviceName
        self.unclaimCallback = callback
    }

    override func setStyle() {
        titleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.ExtraLargeSize, color: ParticleStyle.PrimaryTextColor)
        textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshStrings.ControlPanel.Unclaim.TextTitle
        textLabel.text = MeshStrings.ControlPanel.Unclaim.Text
        continueButton.setTitle(MeshStrings.ControlPanel.Unclaim.UnclaimButton, for: .normal)
    }

    
    @IBAction func continueButtonClicked(_ sender: Any) {
        self.fade()
        self.unclaimCallback(true)
    }
}
