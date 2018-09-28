//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupScanCommissionerStickerViewController: MeshSetupScanStickerViewController {

    func setup(didFindStickerCode: @escaping (String) -> ()) {
        self.callback = didFindStickerCode
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ScanCommissionerSticker.Title
        textLabel.text = MeshSetupStrings.ScanCommissionerSticker.Text
    }
}
