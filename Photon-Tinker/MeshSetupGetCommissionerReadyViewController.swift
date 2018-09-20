//
//  MeshSetupAddToNetworkViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupGetCommissionerReadyViewController: MeshSetupGetReadyViewController {

    internal var networkName: String!

    func setup(didPressReady: @escaping () -> (), deviceType: ParticleDeviceType!, networkName: String) {
        self.callback = didPressReady
        self.deviceType = deviceType
        self.networkName = networkName
    }

    override func setContent() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        titleLabel.text = MeshSetupStrings.GetCommissionerReady.Title

        textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel1.text = MeshSetupStrings.GetCommissionerReady.Text1

        textLabel2.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
        textLabel2.text = MeshSetupStrings.GetCommissionerReady.Text2

        textLabel3.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
        textLabel3.text = MeshSetupStrings.GetCommissionerReady.Text3

        continueButton.setTitle(MeshSetupStrings.GetCommissionerReady.Button.uppercased(), for: .normal)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)

        replaceMeshSetupStringTemplates(view: self.view, deviceType: self.deviceType.description, networkName: self.networkName)
    }
}
