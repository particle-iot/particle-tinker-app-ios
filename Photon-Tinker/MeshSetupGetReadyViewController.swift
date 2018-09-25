//
//  MeshSetupGetReadyViewController.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/18/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import UIKit



class MeshSetupGetReadyViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var textLabel1: MeshLabel!
    @IBOutlet weak var textLabel2: MeshLabel!
    @IBOutlet weak var textLabel3: MeshLabel!
    
    @IBOutlet weak var continueButton: MeshSetupButton!
    
    internal var callback: (() -> ())!

    func setup(didPressReady: @escaping () -> (), deviceType: ParticleDeviceType?) {
        self.callback = didPressReady
        self.deviceType = deviceType
    }

    override func setStyle() {
        videoView.backgroundColor = MeshSetupStyle.VideoBackgroundColor
        videoView.layer.cornerRadius = 5
        videoView.clipsToBounds = true

        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel2.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
        textLabel3.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)

        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)
    }


    override func setContent() {
        titleLabel.text = MeshSetupStrings.GetReady.Title
        textLabel1.text = MeshSetupStrings.GetReady.Text1
        textLabel2.text = MeshSetupStrings.GetReady.Text2
        textLabel3.text = MeshSetupStrings.GetReady.Text3

        continueButton.setTitle(MeshSetupStrings.GetReady.Button, for: .normal)
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        callback()
    }

}
