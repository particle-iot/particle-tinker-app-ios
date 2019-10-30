//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupFirmwareUpdateViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: ParticleLabel!
    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var textLabel: ParticleLabel!
    @IBOutlet weak var continueButton: ParticleButton!

    @IBOutlet weak var noteTitleLabel: ParticleLabel!
    @IBOutlet weak var noteTextLabel: ParticleLabel!

    @IBOutlet weak var noteView: UIView!

    internal var callback: (() -> ())!

    func setup(didPressContinue: @escaping () -> ()) {
        self.callback = didPressContinue
    }

    override func setStyle() {
        titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)
        textLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

        noteTextLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        noteTitleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.DetailSize, color: ParticleStyle.PrimaryTextColor)

        continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshStrings.UpdateFirmware.Title
        textLabel.text = MeshStrings.UpdateFirmware.Text

        noteTextLabel.text = MeshStrings.UpdateFirmware.NoteText
        noteTitleLabel.text = MeshStrings.UpdateFirmware.NoteTitle

        continueButton.setTitle(MeshStrings.UpdateFirmware.Button, for: .normal)
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        callback()
    }
}
