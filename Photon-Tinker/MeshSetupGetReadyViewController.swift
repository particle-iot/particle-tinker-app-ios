//
//  MeshSetupGetReadyViewController.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/18/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import UIKit



class MeshSetupGetReadyViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var videoView: UIView!

    private var callback: (() -> ())?

    func setup(didPressReady: @escaping () -> ()) {
        self.callback = didPressReady
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        //replaceMeshSetupStringTemplates(view: self.view, deviceType: self.deviceType, networkName: nil, deviceName: nil)
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        if let callback = callback {
            callback()
        }
    }

}
