//
//  MeshSetupAddToNetworkViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupAddToNetworkViewController: MeshSetupViewController, MeshSetupScanCodeDelegate {
    
   
    var commissionerDataMatrix : String?
    
    override func networkMatch() {
        print("networkMatch - commissioner is on user selected mesh network")
        // commissioner scanned is on the network user has chosen on previous screen - can advance
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "networkPassword", sender: self)
        }
    }
    
   
    
    
    func didScanCode(code: String) {
        if !code.isEmpty {
            // TODO: initialize flow manager here
            // Split code into deviceID and SN
            self.commissionerDataMatrix = code
            // TODO: specift wildcard for with: (commissioner can be any type of device)
            self.flowManager!.startFlow(with: .xenon, as: .Commissioner, dataMatrix: code)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "networkPassword" :
            guard let vc = segue.destination as? MeshSetupNetworkPasswordViewController  else {
                return
            }
            vc.flowManager = self.flowManager
            
        case "scanCommissionerSticker" :
            guard let vc = segue.destination as? MeshSetupScanCodeViewController  else {
                return
            }
            vc.delegate = self
            
        default:
            print("Error segue")
        
        }
    }
}
