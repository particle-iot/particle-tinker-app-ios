//
//  MeshSetupPairingProcessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/21/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupPairingProcessViewController: MeshSetupViewController, MeshSetupFlowManagerDelegate {
  
   
  
    var deviceType : ParticleDeviceType?
    var dataMatrix : String?
    
    
    func flowError(error: String, severity: MeshSetupErrorSeverity, action: flowErrorAction) {
        print("flowError: \(error)")
        
        var messageType : RMessageType
        switch severity {
            case .Info: messageType = .normal
            case .Warning: messageType = .warning
            case .Error: messageType = .error
            case .Fatal: messageType = .error
        }
        RMessage.showNotification(withTitle: "Pairing", subtitle: error, type: messageType, customTypeName: nil, callback: nil)
    }
    
    
    func scannedNetworks(networkNames: [String]?) {
        //..
    }
    
    
        // TODO:
//        - Performs BLE scan filtering out only Xenon service UUID devices
//        Automatically tries to BLE pair to the device by comparing the scan list result to peripheral name (Xenon-<setupCode>)
//        [Golden firmware - Initiates a secure session key by JPAKE with the device over BLE]
//        Encrypts and sends the first command request  - GetDeviceIdRequest, phone receives device ID
//        Phone hits API endpoint
//        GET /v1/devices to verify device is not already claimed to user (is device ID already in the retrieved list?) if so, prompts users on action
//        Phone sends SetClaimCodeRequest to the device using the  [Golden firmware - negotiated JPAKE session key] mobile_secret using AES-128-CCM-8 cipher, waits for a valid reply.
//
//        If any of the steps fail - display a descriptive message to the user and back out. Otherwise display the “Successful” icon for 2 seconds and progress to next screen

    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // we don't need a back button while trying to pair/start setup
        self.navigationItem.hidesBackButton = true
        ParticleSpinner.show(self.view)
//        self.connectRetries = 0
        
        self.flowManager = MeshSetupFlowManager(delegate : self)
        print("flowManager initialized")
        
    }
    
    func flowManagerReady() {
        print("Starting flow with a \(self.deviceType!.description) as Joiner ")
        let ok = self.flowManager!.startFlow(with: self.deviceType!, as: .Joiner, dataMatrix: self.dataMatrix!)
        
        if !ok {
            print("ERROR: Cannot start flow!")
            self.abort()
        }
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.flowManager?.abortFlow()
        self.abort()
    }
    
    func abort() {
//        MeshSetupParameters.shared.bluetoothManager = nil
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    func messageToUser(level: RMessageType, message: String) {
        
    }
    
    // move this retries code to BLE manager
    /*
    func didDisconnectPeripheral() {
         RMessage.showNotification(withTitle: "Pairing", subtitle: "Device disconnected, retrying...", type: .error, customTypeName: nil, callback: nil)
        
        connectRetries += 1
        if connectRetries >= 5 {
            self.abort()
        }
        
        if MeshSetupParameters.shared.bluetoothManager?.scanForPeripherals() == false {
            self.abort()
        }
    }
    
    func peripheralReadyForData() {
        // start mesh setup
        self.getPairedDeviceID()
    }
    
    
    func peripheralNotSupported() {
          RMessage.showNotification(withTitle: "Pairing", subtitle: "This device device does not seem to be a Particle device, please try again", type: .error, customTypeName: nil, callback: nil)
        
        self.abort()
    }
    
    func bluetoothDisabled() {
        RMessage.showNotification(withTitle: "Bluetooth", subtitle: "Bluetooth must be enabled for setup to complete, please turn on Bluetooth on your phone", type: .error, customTypeName: nil, callback: nil)
        
        self.abort()
    }
    
    func didReceiveData(data buffer: Data) {
        // setup step...
        print("didReceiveData")
    }
    
    func getPairedDeviceID() {
        print ("starting setup")
    }
    */
 
}
