//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupGetCommissionerReadyViewController: MeshSetupGetReadyViewController {


    private var callback: (() -> ())!

    func setup(didPressReady: @escaping () -> (), deviceType: ParticleDeviceType!, networkName: String) {
        self.callback = didPressReady
        self.deviceType = deviceType
        self.networkName = networkName
    }

    @IBAction override func nextButtonTapped(_ sender: Any) {
        callback()
    }
    
    override func setStyle() {
        videoView.layer.cornerRadius = 5
        videoView.clipsToBounds = true
        
        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel2.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel3.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel4.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.GetCommissionerReady.Title
        textLabel1.text = MeshSetupStrings.GetCommissionerReady.Text1
        textLabel2.text = MeshSetupStrings.GetCommissionerReady.Text2
        textLabel3.text = MeshSetupStrings.GetCommissionerReady.Text3
        textLabel3.text = MeshSetupStrings.GetCommissionerReady.Text4

        hideEmptyLabels()

        continueButton.setTitle(MeshSetupStrings.GetCommissionerReady.Button, for: .normal)

        view.setNeedsLayout()
        view.layoutIfNeeded()

        initializeVideoPlayerWithVideo(videoFileName: "commissioner_to_listening_mode")
    }
}
