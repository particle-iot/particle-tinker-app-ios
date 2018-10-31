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
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        noteTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        noteTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.DetailSize, color: MeshSetupStyle.PrimaryTextColor)

        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
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
