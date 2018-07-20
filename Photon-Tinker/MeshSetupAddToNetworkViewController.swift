//
//  MeshSetupAddToNetworkViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupAddToNetworkViewController: MeshSetupViewController, MeshSetupScanCodeDelegate, MeshSetupFlowManagerDelegate {
    
    func flowError(error: String, severity: MeshSetupErrorSeverity, action: flowErrorAction) {
        print(error)
    }
    /*
    func scannedNetworks(networks: [String]?) {
        // ..
    }
    
    func flowManagerReady() {
        // ..
    }
 */
    
    func networkMatch() {
        // commissioner scanned is on the network user has chosen on previous screen - can advance
        performSegue(withIdentifier: "networkPassword", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    var commissionerDataMatrix : String?
    
    func didScanCode(code: String) {
        if !code.isEmpty {
            // TODO: initialize flow manager here
            // Split code into deviceID and SN
            self.commissionerDataMatrix = code
            self.flowManager?.startFlow(with: .xenon, as: .Commissioner, dataMatrix: code)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "networkPassword" {
            guard let vc = segue.destination as? MeshSetupNetworkPasswordViewController  else {
                return
            }
            
            vc.flowManager = self.flowManager
            
        }
        
        if segue.identifier == "scanJoinerSticker" {
            guard let vc = segue.destination as? MeshSetupScanCodeViewController  else {
                return
            }
            
            vc.delegate = self
        }
        
        
        
    }
    

}
