//
//  MeshSetupPairDeviceViewController.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/19/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import UIKit

class MeshSetupPairDeviceViewController: MeshSetupViewController, MeshSetupScanCodeDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    var deviceType : ParticleDeviceType?
    var flowManager : MeshSetupFlowManager?
    
    
    func didScanCode(code: String) {
        if !code.isEmpty {
            // TODO: initialize flow manager here
            // Split code into deviceID and SN
        
            self.flowManager = MeshSetupFlowManager(deviceType : self.deviceType!, stickerData: code)
            self.performSegue(withIdentifier: "pairing", sender: self)
         
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        if segue.identifier == "scanCode" {
            guard let vc = segue.destination as? MeshSetupScanCodeViewController  else {
                return
            }
            
            vc.delegate = self
        }
        
        if segue.identifier == "pairing" {
            guard let vc = segue.destination as? MeshSetupPairingProcessViewController  else {
                return
            }
            
            vc.flowManager = self.flowManager
        }
            
            
    }
    

}
