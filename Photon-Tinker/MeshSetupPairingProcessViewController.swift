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
   
    func errorFlow(error: String, severity: flowErrorSeverity, action: flowErrorAction) {
        //..
    }
    
    func errorPeripheralNotSupported() {
        //..
    }
    
    func errorBluetoothDisabled() {
        //..
    }
    
    func errorPeripheralDisconnected() {
        //..
    }
    
    func scannedNetworks(networkNames: [String]?) {
        //..
    }
    

    var flowManager : MeshSetupFlowManager?
    
//    var peripherals      : [MeshSetupScannedPeripheral] = []
    var particleMeshServiceUUID : CBUUID?
    var connectedPeripheral : CBPeripheral?
    
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

    
    /**
     * Starts scanning for peripherals with rscServiceUUID.
     * - parameter enable: If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
     * - returns: true if success, false if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
     */
   
    
//    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // we don't need a back button while trying to pair/start setup
        self.navigationItem.hidesBackButton = true
        ParticleSpinner.show(self.view)
//        self.connectRetries = 0
        
        
        self.flowManager?.delegate = self
        
    }
    
   
    func abort() {
//        MeshSetupParameters.shared.bluetoothManager = nil
        self.navigationController?.popViewController(animated: true)
    }

    
    func messageToUser(level: RMessageType, message: String) {
          RMessage.showNotification(withTitle: "Pairing", subtitle: message, type: level, customTypeName: nil, callback: nil)
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
