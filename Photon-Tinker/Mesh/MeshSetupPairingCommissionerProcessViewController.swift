//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupPairingCommissionerProcessViewController: MeshSetupPairingProcessViewController {

//    static var nibName: String {
//        return "MeshSetupPairingView"
//    }

    override func setContent() {
        pairingTextLabel.text = MeshStrings.PairingCommissioner.PairingText
        successTitleLabel.text = MeshStrings.PairingCommissioner.SuccessTitle
        successTextLabel.text = MeshStrings.PairingCommissioner.SuccessText
    }
}
