//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupScanCommissionerStickerViewController: MeshSetupScanStickerViewController {

//    static var nibName: String {
//        return "MeshSetupScanStickerView"
//    }

    override func setContent() {
        titleLabel.text = Gen3SetupStrings.ScanCommissionerSticker.Title
        textLabel.text = Gen3SetupStrings.ScanCommissionerSticker.Text
    }
}
