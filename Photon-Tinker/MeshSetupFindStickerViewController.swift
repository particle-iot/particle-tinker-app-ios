//
//  MeshSetupFindStickerViewController.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/19/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import UIKit

class MeshSetupFindStickerViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var textLabel: MeshLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!
    
    private var callback: (() -> ())?
    private var deviceType: ParticleDeviceType!

    func setup(didPressScan: @escaping () -> (), deviceType: ParticleDeviceType) {
        self.callback = didPressScan
        self.deviceType = deviceType
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MeshSetupStyle.ViewBackgroundColor

        videoView.backgroundColor = MeshSetupStyle.GrayBackgroundColor
        videoView.layer.cornerRadius = 5
        videoView.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        titleLabel.text = MeshSetupStrings.FindSticker.Title

        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.text = MeshSetupStrings.FindSticker.Text

        var buttonTitle = replaceMeshSetupStringTemplates(string: MeshSetupStrings.FindSticker.Button, deviceType: self.deviceType.description)
        continueButton.setTitle(buttonTitle.uppercased(), for: .normal)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)

        replaceMeshSetupStringTemplates(view: self.view, deviceType: self.deviceType.description)
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        if let callback = callback {
            callback()
        }
    }
}
