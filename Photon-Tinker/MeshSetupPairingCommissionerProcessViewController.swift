//
//  MeshSetupPairingProcessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/21/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupPairingCommissionerProcessViewController: MeshSetupPairingProcessViewController {

    override func setContent() {
        pairingTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        pairingTextLabel.text = MeshSetupStrings.PairingCommissioner.PairingText

        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTitleLabel.text = MeshSetupStrings.PairingCommissioner.SuccessTitle

        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.text = MeshSetupStrings.PairingCommissioner.SuccessText

        replaceMeshSetupStringTemplates(view: self.view, deviceType: self.deviceType.description, deviceName: self.deviceName)
    }
}
