//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
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
