//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class Gen3SetupScanCommissionerStickerViewController: Gen3SetupScanStickerViewController {

//    static var nibName: String {
//        return "Gen3SetupScanStickerView"
//    }

    override func setContent() {
        titleLabel.text = Gen3SetupStrings.ScanCommissionerSticker.Title
        textLabel.text = Gen3SetupStrings.ScanCommissionerSticker.Text
    }
}
