//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupPairingCommissionerProcessViewController: MeshSetupPairingProcessViewController {

//    static var nibName: String {
//        return "MeshSetupPairingView"
//    }

    override func setContent() {
        pairingTextLabel.text = Gen3SetupStrings.PairingCommissioner.PairingText
        successTitleLabel.text = Gen3SetupStrings.PairingCommissioner.SuccessTitle
        successTextLabel.text = Gen3SetupStrings.PairingCommissioner.SuccessText
    }
}
