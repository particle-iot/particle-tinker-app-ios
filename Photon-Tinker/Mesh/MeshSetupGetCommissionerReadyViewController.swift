//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupGetCommissionerReadyViewController: MeshSetupGetReadyViewController {



    func setup(didPressReady: @escaping () -> (), deviceType: ParticleDeviceType!, networkName: String) {
        self.callback = didPressReady
        self.deviceType = deviceType
        self.networkName = networkName
    }
    
    override func setStyle() {
        videoView.backgroundColor = MeshSetupStyle.VideoBackgroundColor
        videoView.layer.cornerRadius = 5
        videoView.clipsToBounds = true
        
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel2.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel3.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel4.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.GetCommissionerReady.Title
        textLabel1.text = MeshSetupStrings.GetCommissionerReady.Text1
        textLabel2.text = MeshSetupStrings.GetCommissionerReady.Text2
        textLabel3.text = MeshSetupStrings.GetCommissionerReady.Text3
        textLabel3.text = MeshSetupStrings.GetCommissionerReady.Text4

        hideEmptyLabels()

        continueButton.setTitle(MeshSetupStrings.GetCommissionerReady.Button, for: .normal)
        
        initializeVideoPlayerWithVideo(videoFileName: "commissioner_to_listening_mode")
    }
}
