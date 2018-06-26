//
//  MeshSetupPairingProcessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/21/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupPairingProcessViewController: MeshSetupViewController, CBCentralManagerDelegate {

    var mobileSecret : String?
    var peripheralName : String?
    
    //MARK: - ViewController Properties
    var bluetoothManager : CBCentralManager?
    var peripherals      : [MeshSetupScannedPeripheral] = []
    var particleMeshServiceUUID : CBUUID?
    
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
    func scanForPeripherals() -> Bool {
        guard bluetoothManager?.state == .poweredOn else {
            return false
        }
        
        DispatchQueue.main.async {
                let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
            
            self.bluetoothManager?.scanForPeripherals(withServices: [self.particleMeshServiceUUID!], options: options as? [String : AnyObject])
        }
        
        return true
    }
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // we don't need a back button while trying to pair/start setup
        self.navigationItem.hidesBackButton = true
        
        activityIndicatorView.startAnimating()
        
        let centralQueue = DispatchQueue(label: "io.particle.mesh", attributes: [])
        self.bluetoothManager = CBCentralManager(delegate: self, queue: centralQueue)
        self.particleMeshServiceUUID = CBUUID(string: MeshSetupServiceIdentifiers.particleMeshServiceUUIDString)
        let success = self.scanForPeripherals()
        if !success {
            // TODO: display something to user
        }
    }
    
    
    //MARK: - CBCentralManagerDelgate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("Bluetooth is powered off")
            return
        }
        
        let connectedPeripherals = self.getConnectedPeripherals()
        var newScannedPeripherals: [MeshSetupScannedPeripheral] = []
        connectedPeripherals.forEach { (connectedPeripheral: CBPeripheral) in
            let connected = connectedPeripheral.state == .connected
            let scannedPeripheral = MeshSetupScannedPeripheral(withPeripheral: connectedPeripheral, andIsConnected: connected )
            newScannedPeripherals.append(scannedPeripheral)
        }
        peripherals = newScannedPeripherals
        let success = self.scanForPeripherals()
        if !success {
            print("Bluetooth is powered off!")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Scanner uses other queue to send events
        DispatchQueue.main.async(execute: {
            var peripheral = MeshSetupScannedPeripheral(withPeripheral: peripheral, andRSSI: RSSI.int32Value, andIsConnected: false)
            if ((self.peripherals.contains(peripheral)) == false) {
                self.peripherals.append(peripheral)
            } else {
                peripheral = self.peripherals[self.peripherals.index(of: peripheral)!]
                peripheral.RSSI = RSSI.int32Value
            }
            print(self.peripherals)
        })
    }
    
    
    func getConnectedPeripherals() -> [CBPeripheral] {
        guard let bluetoothManager = bluetoothManager else {
            return []
        }
        
        var retreivedPeripherals : [CBPeripheral]
        
        retreivedPeripherals = bluetoothManager.retrieveConnectedPeripherals(withServices: [self.particleMeshServiceUUID!])
        
        return retreivedPeripherals
    }
    
    
    
}
