//
//  MeshSetupScanStickerViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import AVFoundation

class MeshSetupScanCommissionerStickerViewController: MeshSetupScanStickerViewController {

    func setup(didFindStickerCode: @escaping (String) -> ()) {
        self.callback = didFindStickerCode
    }

    override func setContent() {
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        titleLabel.text = MeshSetupStrings.ScanCommissionerSticker.Title

        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.text = MeshSetupStrings.ScanCommissionerSticker.Text
    }

}
