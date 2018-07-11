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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var mobileSecret : String?
    var setupCode : String?
    
    func didScanCode(code: String) {
        if !code.isEmpty {
            // TODO: initialize flow manager here
            // Split code into deviceID and SN

            MeshSetupParameters.shared.flowManager = MeshSetupFlowManager(deviceType : MeshSetupParameters.shared.deviceType, stickerData: code, claimCode: MeshSetupParameters.shared.claimCode)
            
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
            
            vc.mobileSecret = self.mobileSecret!
            let peripheralNameString = (MeshSetupParameters.shared.deviceType?.description)!+"-"+self.setupCode!
            vc.peripheralName = peripheralNameString

        }
            
            
    }
    

}
