//
//  MeshSetupJoiningNetworkViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/23/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupJoiningNetworkViewController: MeshSetupViewController {

    var networkPassword : String?
    
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var successImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.successImageView.isHidden = true
        step1Label.alpha = 1.0
        step2Label.alpha = 0.5
        step3Label.alpha = 0.5
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear - commissionDeviceToNetwork")
        
        self.flowManager!.commissionDeviceToNetwork()
        ParticleSpinner.show(self.view)
    }
    
    override func joinerPrepared() {
        step1Label.alpha = 0.5
        step2Label.alpha = 1.0
        
    }
    
    override func joinedNetwork() {
        step2Label.alpha = 0.5
        step3Label.alpha = 1.0
    }
    
    override func deviceOnlineClaimed() {
        step3Label.alpha = 0.5
        self.successImageView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // delay is needed otherwise joiner returns -1
            self.performSegue(withIdentifier: "nameDevice", sender: self)
        }

    }

  

}
