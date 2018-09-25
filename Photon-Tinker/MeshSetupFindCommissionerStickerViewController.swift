//
//  MeshSetupPairAssistingViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/25/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupFindCommissionerStickerViewController: MeshSetupFindStickerViewController {

    @IBOutlet weak var noteLabel: MeshLabel!
    @IBOutlet weak var noteView: UIView!


    func setup(didPressScan: @escaping () -> (), deviceType: ParticleDeviceType?, networkName: String) {
        self.callback = didPressScan
        self.deviceType = deviceType
        self.networkName = networkName
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        noteLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.FindCommissionerSticker.Title
        textLabel.text = MeshSetupStrings.FindCommissionerSticker.Text
        noteLabel.text = MeshSetupStrings.FindCommissionerSticker.Note

        continueButton.setTitle(MeshSetupStrings.FindCommissionerSticker.Button, for: .normal)
    }
}
