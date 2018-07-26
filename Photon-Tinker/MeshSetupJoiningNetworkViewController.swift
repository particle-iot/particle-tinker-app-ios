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
    
    
    func growLabel(label : UILabel) {
        label.font = UIFont(name: "Gotham-Medium", size: 16.0)
        label.alpha = 1.0
    }
    
    func shrinkLabel(label : UILabel) {
        label.font = UIFont(name: "Gotham-Book", size: 15.0)
        label.alpha = 0.4
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.successImageView.isHidden = true
        growLabel(label: step1Label)
        shrinkLabel(label: step2Label)
        shrinkLabel(label: step3Label)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear - commissionDeviceToNetwork")
        
        self.flowManager!.commissionDeviceToNetwork()
        ParticleSpinner.show(self.view)
    }
    
    override func joinerPrepared() {
        DispatchQueue.main.async {
            self.growLabel(label: self.step2Label)
            self.shrinkLabel(label: self.step1Label)
            self.shrinkLabel(label: self.step3Label)
        }
        
    }
    
    override func joinedNetwork() {
        DispatchQueue.main.async {
            self.growLabel(label: self.step3Label)
            self.shrinkLabel(label: self.step1Label)
            self.shrinkLabel(label: self.step2Label)
        }
    }
    
    override func deviceOnlineClaimed() {
        DispatchQueue.main.async {
            self.shrinkLabel(label: self.step1Label)
            self.shrinkLabel(label: self.step1Label)
            self.shrinkLabel(label: self.step3Label)
            ParticleSpinner.hide(self.view)
            self.successImageView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // delay is needed otherwise joiner returns -1
                self.performSegue(withIdentifier: "nameDevice", sender: self)
            }
        }

    }

  

}
