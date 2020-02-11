//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupFindCommissionerStickerViewController: MeshSetupFindStickerViewController {

    @IBOutlet weak var noteTitleLabel: ParticleLabel!
    @IBOutlet weak var noteTextLabel: ParticleLabel!

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
        titleLabel.text = Gen3SetupStrings.FindCommissionerSticker.Title
        textLabel.text = Gen3SetupStrings.FindCommissionerSticker.Text
        noteTextLabel.text = Gen3SetupStrings.FindCommissionerSticker.NoteText
        noteTitleLabel.text = Gen3SetupStrings.FindCommissionerSticker.NoteTitle

        continueButton.setTitle(Gen3SetupStrings.FindCommissionerSticker.Button, for: .normal)
    }
}
