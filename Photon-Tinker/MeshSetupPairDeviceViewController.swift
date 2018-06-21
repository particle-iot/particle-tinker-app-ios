//
//  MeshSetupPairDeviceViewController.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/19/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import UIKit

class MeshSetupPairDeviceViewController: MeshSetupViewController, MeshSetupScanCodeDelegate, MeshSetupTypeCodeDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var mobileSecret : String?
    
    

    func didReceiveTypedSerialNumber(code: String) {
        // ParticleCloud.sharedInstance().getDeviceIDfromSN(code)...
    }
    
    var setupCode : String?
    
    func didTypeCode(code: String) {
        // TODO:
        // ParticleCloud.sharedInstance().getDeviceIDfromSN(code)...
        self.setupCode = String(code.suffix(6))
        
    }
    
    func getMobileSecretAndSegue(deviceID : String) {
        // ParticleCloud.sharedInstance().getMobileSecret(deviceID)...
        self.mobileSecret = "12345678123456781234567812345678"
        self.performSegue(withIdentifier: "pairing", sender: self)
    }
    
    func didScanCode(code: String) {
        if !code.isEmpty {
            // TODO:
            // Split code into deviceID and SN
            let arr = code.split(separator: "_")
            let deviceID = String(arr[0])//"12345678abcdefg"
            let serialNumber = String(arr[1])//"ABCDEFGHIJKLMN"
            
            self.setupCode = String(serialNumber.suffix(6))
            getMobileSecretAndSegue(deviceID: deviceID)
         
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pairing" {
            var vc: MeshSetupPairingProcessViewController = (segue.destination as! MeshSetupPairingProcessViewController) {
                vc.mobileSecret = self.mobileSecret!
                let peripheralNameString = (MeshSetupParameters.shared.deviceType?.description)!+"-"+self.setupCode!
                vc.peripheralName = peripheralNameString
            }
        }
    }
    

}
