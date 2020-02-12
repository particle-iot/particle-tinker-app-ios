//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class Gen3SetupFindStickerViewController: Gen3SetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: ParticleLabel!
    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var textLabel: ParticleLabel!
    @IBOutlet weak var continueButton: ParticleButton!

    internal var callback: (() -> ())!

    func setup(didPressScan: @escaping () -> ()) {
        self.callback = didPressScan
    }

    override func setStyle() {
        titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

        continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = Gen3SetupStrings.FindSticker.Title
        textLabel.text = Gen3SetupStrings.FindSticker.Text

        continueButton.setTitle(Gen3SetupStrings.FindSticker.Button, for: .normal)
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        callback()
    }
}
