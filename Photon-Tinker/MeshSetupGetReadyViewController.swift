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
        
        // Todo: remove hard coding
        self.setupDeviceType = .xenon
        
        // Todo: get claim code
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

    @IBOutlet weak var videoView: UIView!
    @IBAction func nextButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "pairDevice", sender: self)
    }
}
