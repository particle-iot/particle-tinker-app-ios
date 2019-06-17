//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupFindCommissionerStickerViewController: MeshSetupFindStickerViewController {

    @IBOutlet weak var noteTitleLabel: MeshLabel!
    @IBOutlet weak var noteTextLabel: MeshLabel!

    @IBOutlet weak var noteView: UIView!

    func setup(didPressScan: @escaping () -> (), networkName: String) {
        self.callback = didPressScan

        self.networkName = networkName
    }

    override func setStyle() {
        titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

        noteTextLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        noteTitleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.DetailSize, color: ParticleStyle.PrimaryTextColor)

        continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.FindCommissionerSticker.Title
        textLabel.text = MeshSetupStrings.FindCommissionerSticker.Text
        noteTextLabel.text = MeshSetupStrings.FindCommissionerSticker.NoteText
        noteTitleLabel.text = MeshSetupStrings.FindCommissionerSticker.NoteTitle

        continueButton.setTitle(MeshSetupStrings.FindCommissionerSticker.Button, for: .normal)
    }
}
