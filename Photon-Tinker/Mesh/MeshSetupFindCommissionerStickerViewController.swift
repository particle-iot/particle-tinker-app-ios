//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupFindCommissionerStickerViewController: MeshSetupFindStickerViewController {

    @IBOutlet weak var noteTitleLabel: MeshLabel!
    @IBOutlet weak var noteTextLabel: MeshLabel!

    @IBOutlet weak var noteView: UIView!

    override var allowBack: Bool {
        return true
    }

    func setup(didPressScan: @escaping () -> (), deviceType: ParticleDeviceType?, networkName: String) {
        self.callback = didPressScan
        self.deviceType = deviceType
        self.networkName = networkName
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        noteTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        noteTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.DetailSize, color: MeshSetupStyle.PrimaryTextColor)

        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.FindCommissionerSticker.Title
        textLabel.text = MeshSetupStrings.FindCommissionerSticker.Text
        noteTextLabel.text = MeshSetupStrings.FindCommissionerSticker.NoteText
        noteTitleLabel.text = MeshSetupStrings.FindCommissionerSticker.NoteTitle

        continueButton.setTitle(MeshSetupStrings.FindCommissionerSticker.Button, for: .normal)
    }
}
