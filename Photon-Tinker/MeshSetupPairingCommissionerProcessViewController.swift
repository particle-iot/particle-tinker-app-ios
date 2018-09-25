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
        pairingTextLabel.text = MeshSetupStrings.PairingCommissioner.PairingText
        successTitleLabel.text = MeshSetupStrings.PairingCommissioner.SuccessTitle
        successTextLabel.text = MeshSetupStrings.PairingCommissioner.SuccessText
    }
}
