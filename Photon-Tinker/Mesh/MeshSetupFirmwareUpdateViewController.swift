//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupFirmwareUpdateViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var textLabel: MeshLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!

    @IBOutlet weak var noteTitleLabel: MeshLabel!
    @IBOutlet weak var noteTextLabel: MeshLabel!

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
        titleLabel.text = MeshSetupStrings.UpdateFirmware.Title
        textLabel.text = MeshSetupStrings.UpdateFirmware.Text

        noteTextLabel.text = MeshSetupStrings.UpdateFirmware.NoteText
        noteTitleLabel.text = MeshSetupStrings.UpdateFirmware.NoteTitle

        continueButton.setTitle(MeshSetupStrings.UpdateFirmware.Button, for: .normal)
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        callback()
    }
}
