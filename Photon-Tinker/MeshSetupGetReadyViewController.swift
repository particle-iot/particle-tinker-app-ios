//
//  MeshSetupGetReadyViewController.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/18/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import UIKit



class MeshSetupGetReadyViewController: MeshSetupViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        replaceMeshSetupStringTemplates(view: self.view, deviceType: self.deviceType, networkName: nil, deviceName: nil)
        
    }

    @IBOutlet weak var videoView: UIView!
    @IBAction func nextButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "pairDevice", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MeshSetupPairDeviceViewController  else {
            return
        }
        
        vc.deviceType = self.deviceType
        
    }
}
