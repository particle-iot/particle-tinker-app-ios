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
    
    private var callback: (() -> ())?
    private var deviceType: ParticleDeviceType!

    func setup(didPressReady: @escaping () -> (), deviceType: ParticleDeviceType) {
        self.callback = didPressReady
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
        titleLabel.text = MeshSetupStrings.GetReady.Title

        textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel1.text = MeshSetupStrings.GetReady.Text1

        textLabel2.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
        textLabel2.text = MeshSetupStrings.GetReady.Text2

        textLabel3.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.SecondaryTextColor)
        textLabel3.text = MeshSetupStrings.GetReady.Text3

        var buttonTitle = replaceMeshSetupStringTemplates(string: MeshSetupStrings.GetReady.Button, deviceType: self.deviceType.description)
        continueButton.setTitle(buttonTitle.uppercased(), for: .normal)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)

        replaceMeshSetupStringTemplates(view: self.view, deviceType: self.deviceType.description)
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        if let callback = callback {
            callback()
        }
    }

}
