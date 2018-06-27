//
//  MeshSetupPairingProcessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/21/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupPairingProcessViewController: MeshSetupViewController, MeshSetupBluetoothManagerDelegate {
    func didUpdateState(state: CBCentralManagerState) {
        //
    }
    
    func didConnectPeripheral(deviceName aName: String?) {
        //
    }
    
    func didDisconnectPeripheral() {
        //
    }
    
    func peripheralReady() {
        //
    }
    
    func peripheralNotSupported() {
        //
    }
    
    func didReceiveData(data buffer: Data) {
        //
    }
    

    var mobileSecret : String?
    var peripheralName : String?
    
    //MARK: - ViewController Properties
    var bluetoothManager : MeshSetupBluetoothManager?
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
        
        self.bluetoothManager = MeshSetupBluetoothManager.init()
        
//        activityIndicatorView.startAnimating()
//        ParticleSpinner.hide(self.view)
        
        
       
//        let success = self.bluetoothManager.scanForPeripherals()
//        if !success {
//            // TODO: display something to user
//        }
    }
    
    
    //MARK: - CBCentralManagerDelgate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("Bluetooth is powered off")
            return
        }
        
        print("centralManagerDidUpdateState")
        
        /*
        let connectedPeripherals = self.getConnectedPeripherals()
        var newScannedPeripherals: [MeshSetupScannedPeripheral] = []
        connectedPeripherals.forEach { (connectedPeripheral: CBPeripheral) in
            let connected = connectedPeripheral.state == .connected
            let scannedPeripheral = MeshSetupScannedPeripheral(withPeripheral: connectedPeripheral, andIsConnected: connected )
            newScannedPeripherals.append(scannedPeripheral)
        }
        peripherals = newScannedPeripherals
//         */
//        let success = self.scanForPeripherals()
//        if !success {
//            print("Bluetooth is powered off!")
//        }
    }
    
   
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        self.getPairedDeviceID()
        
    }
    
    
    func getPairedDeviceID() {
        
    }
    

    
    
}
