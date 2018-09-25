//
//  MeshSetupScanStickerViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/19/18.
//  Copyright © 2018 spark. All rights reserved.
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
