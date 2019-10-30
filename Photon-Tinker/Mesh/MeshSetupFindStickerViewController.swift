//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupFindStickerViewController: MeshSetupViewController, Storyboardable {

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
        titleLabel.text = MeshStrings.FindSticker.Title
        textLabel.text = MeshStrings.FindSticker.Text

        continueButton.setTitle(MeshStrings.FindSticker.Button, for: .normal)
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        callback()
    }
}
