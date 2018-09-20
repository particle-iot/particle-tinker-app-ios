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

    internal var networkName: String!

    func setup(didPressScan: @escaping () -> (), deviceType: ParticleDeviceType!, networkName: String) {
        self.callback = didPressScan
        self.deviceType = deviceType
        self.networkName = networkName
    }

    override func setContent() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        titleLabel.text = MeshSetupStrings.FindCommissionerSticker.Title

        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.text = MeshSetupStrings.FindCommissionerSticker.Text

        noteLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        noteLabel.text = MeshSetupStrings.FindCommissionerSticker.Note

        continueButton.setTitle(MeshSetupStrings.FindCommissionerSticker.Button.uppercased(), for: .normal)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)

        replaceMeshSetupStringTemplates(view: self.view, deviceType: self.deviceType.description, networkName: self.networkName)
    }

}
