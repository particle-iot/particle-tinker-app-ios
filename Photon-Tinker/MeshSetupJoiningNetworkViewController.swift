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
    
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear - commissionDeviceToNetwork")
        
        self.flowManager!.commissionDeviceToNetwork()
        ParticleSpinner.show(self.view)
    }

  

}
