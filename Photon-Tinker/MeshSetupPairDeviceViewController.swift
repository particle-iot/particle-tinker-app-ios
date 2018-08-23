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
    
    
    var dataMatrix: String?
    
    func didScanCode(code: String) {
        if !code.isEmpty {
            // TODO: initialize flow manager here
            // Split code into deviceID and SN
            self.dataMatrix = code
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "pairing", sender: self)
            }
         
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        if segue.identifier == "scanJoinerSticker" {
            guard let vc = segue.destination as? MeshSetupScanCodeViewController  else {
                return
            }
            
            vc.delegate = self
        }
        
        if segue.identifier == "pairing" {
            guard let vc = segue.destination as? MeshSetupPairingProcessViewController else {
                return
            }
            
            vc.deviceType = self.deviceType
            vc.dataMatrix = self.dataMatrix
        }
            
            
    }
    

}
