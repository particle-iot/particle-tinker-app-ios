//
//  MeshSetupViewController.swift
//  
//
//  Created by Ido Kleinman on 6/19/18.
//

import UIKit

class MeshSetupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        replaceMeshSetupStringTemplates(view: self.view, deviceType: self.setupDeviceType!, networkName: setupNetworkName, deviceName: setupDeviceName)

        // Do any additional setup after loading the view.
    }

    var setupDeviceType : ParticleDeviceType?
    var setupNetworkName : String?
    var setupDeviceName : String?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
