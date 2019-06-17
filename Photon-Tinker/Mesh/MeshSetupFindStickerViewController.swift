//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupFindStickerViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var textLabel: MeshLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!

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
        titleLabel.text = MeshSetupStrings.FindSticker.Title
        textLabel.text = MeshSetupStrings.FindSticker.Text

        continueButton.setTitle(MeshSetupStrings.FindSticker.Button, for: .normal)
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        callback()
    }
}
