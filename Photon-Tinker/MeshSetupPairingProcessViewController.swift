//
//  MeshSetupPairingProcessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/21/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupPairingProcessViewController: MeshSetupViewController {

    var mobileSecret : String?
    var peripheralName : String?
    
    
    override func viewDidLoad() {
        // TODO:
//        Performs BLE scan filtering out only Xenon service UUID devices
//        Automatically tries to BLE pair to the device by comparing the scan list result to peripheral name (Xenon-<setupCode>)
//        [Golden firmware - Initiates a secure session key by JPAKE with the device over BLE]
//        Encrypts and sends the first command request  - GetDeviceIdRequest, phone receives device ID
//        Phone hits API endpoint
//        GET /v1/devices to verify device is not already claimed to user (is device ID already in the retrieved list?) if so, prompts users on action
//        Phone sends SetClaimCodeRequest to the device using the  [Golden firmware - negotiated JPAKE session key] mobile_secret using AES-128-CCM-8 cipher, waits for a valid reply.
//
//        If any of the steps fail - display a descriptive message to the user and back out. Otherwise display the “Successful” icon for 2 seconds and progress to next screen

    }
}
