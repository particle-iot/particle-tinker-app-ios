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
        
        // temporary hack to segue to next screen:
        if code.isEmpty {
            self.setupCode = "123456"
        } else {
            // regular code
            self.setupCode = String(code.suffix(6))
        }

        let deviceID = "12345678abcdefg"
        getMobileSecretAndSegue(deviceID: deviceID)
        
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
        
        if segue.identifier == "typeCode" {
            guard let vc = segue.destination as? MeshSetupTypeCodeViewController  else {
                return
            }
            
            vc.delegate = self
        }
        
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
