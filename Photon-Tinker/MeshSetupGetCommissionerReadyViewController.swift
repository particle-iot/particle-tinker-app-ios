//
//  MeshSetupAddToNetworkViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupGetCommissionerReadyViewController: MeshSetupGetReadyViewController {



    func setup(didPressReady: @escaping () -> (), deviceType: ParticleDeviceType!, networkName: String) {
        self.callback = didPressReady
        self.deviceType = deviceType
        self.networkName = networkName
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.GetCommissionerReady.Title
        textLabel1.text = MeshSetupStrings.GetCommissionerReady.Text1
        textLabel2.text = MeshSetupStrings.GetCommissionerReady.Text2
        textLabel3.text = MeshSetupStrings.GetCommissionerReady.Text3

        continueButton.setTitle(MeshSetupStrings.GetCommissionerReady.Button, for: .normal)
        
        initializeVideoPlayerWithVideo(videoFileName: "commissioner_to_listening_mode")
    }
}
