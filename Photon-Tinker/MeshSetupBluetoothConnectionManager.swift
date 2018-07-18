//
//  NORBluetoothManager.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 06/05/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth

// TODO: nuke this after BLE debug
enum BLELogLevel : String {
    
    case debugLogLevel = "debug"
    case verboseLogLevel = "verbose"
    case infoLogLevel = "info"
    case appLogLevel = "app"
    case warningLogLevel = "warning"
    case errorLogLevel = "error"
}

enum MeshSetupBluetoothConnectionManagerState {
    case Disabled
    case Ready
    case Scanning
    case DiscoveredPeripheral
}


protocol MeshSetupBluetoothConnectionManagerDelegate {
    // Manager
    func bluetoothConnectionManagerReady()
    func bluetoothConnectionManagerError(error : String, severity : MeshSetupErrorSeverity)

    // Connections
    func bluetoothConnectionReady(connection : MeshSetupBluetoothConnection)
    func bluetoothConnectionCreated(connection : MeshSetupBluetoothConnection)
    func bluetoothConnectionDropped(connection : MeshSetupBluetoothConnection)
    func bluetoothConnectionError(connection : MeshSetupBluetoothConnection, error: String, severity : MeshSetupErrorSeverity)
}


let particleMeshServiceUUID : CBUUID = CBUUID(string: "6FA90001-5C4E-48A8-94F4-8030546F36FC")

let particleMeshRXCharacterisiticUUID   : CBUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
let particleMeshTXCharacterisiticUUID   : CBUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")



class MeshSetupBluetoothConnectionManager: NSObject, CBCentralManagerDelegate {
    
    var delegate : MeshSetupBluetoothConnectionManagerDelegate?
    
    private var state : MeshSetupBluetoothConnectionManagerState = .Disabled
    private var centralManager          : CBCentralManager?
    private var peripheralNameToConnect : String?
    private var connections             : [MeshSetupBluetoothConnection]?
    private var connectingPeripheral    : CBPeripheral?
    
    //MARK: - BluetoothManager API
    
    required init(delegate : MeshSetupBluetoothConnectionManagerDelegate) {
        super.init()
        self.delegate = delegate
        let centralQueue = DispatchQueue(label: "io.particle.mesh", attributes: [])
        self.centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        
    }
    
    func createConnection(with peripheralName : String) -> Bool {
        if self.state == .Ready {
            self.peripheralNameToConnect = peripheralName
            return self.scanForPeripherals()
            // started scanning
        } else {
            // not ready / still working on previous request
            return false
        }
    }

    
    /**
     * Disconnects or cancels pending connection.
     * The delegate's didDisconnectPeripheral() method will be called when device got disconnected.
     */
    func dropConnection(with connection : MeshSetupBluetoothConnection) {
        if let p = connection._getPeripheral() {
            centralManager!.cancelPeripheralConnection(p)
        }
    }
    
    
    private func scanForPeripherals() -> Bool {
        guard self.centralManager?.state == .poweredOn else {
            return false
        }
        
        self.state = .Scanning
        
        print ("BluetoothConnectionManager -- scanForPeripherals with services \(particleMeshServiceUUID)")
        let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
        
        self.centralManager!.scanForPeripherals(withServices: [particleMeshServiceUUID], options: options as? [String : AnyObject]) // []
        
        
        return true
    }
    
    //MARK: - Logger API
    // TODO: remove after debug
    private func log(level : BLELogLevel, message : String) {
//        logger?.log(level: aLevel, message: aMessage)
        print("[\(level.rawValue)]: \(message)")
    }
    
    private func logError(error anError : Error) {
        if let e = anError as? CBError {
            self.log(level: .errorLogLevel, message: "Error \(e.code): \(e.localizedDescription)")
        } else {
            self.log(level: .errorLogLevel, message: "Error \(anError.localizedDescription)")
        }
    }
    
    //MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var textState : String
        
        var newState : MeshSetupBluetoothConnectionManagerState = .Disabled
        switch(central.state){
        case .poweredOn:
            textState = "Powered ON"
            newState = .Ready
        case .poweredOff:
            textState = "Powered OFF"
            newState = .Disabled
        case .resetting:
            textState = "Resetting"
            newState = .Disabled
        case .unauthorized:
            textState = "Unauthorized"
            newState = .Disabled
        case .unsupported:
            textState = "Unsupported"
            newState = .Disabled
        case .unknown:
            textState = "Unknown"
            newState = .Disabled
        }
        
        // TODO: remove debug
        print("centralManagerDidUpdateState: \(textState)")
        
        if (newState == .Disabled) && (self.state != .Disabled) {
            self.state = newState
            self.delegate?.bluetoothConnectionManagerError(error: "Bluetooth is disabled", severity: .Warning)
        }
        
        if (newState == .Ready) && (self.state != .Ready) {
            self.state = newState
            self.delegate?.bluetoothConnectionManagerReady()
        }
        
        self.state = newState
        
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log(level: .debugLogLevel, message: "[Callback] Central Manager did connect peripheral")
        if let name = peripheral.name {
            log(level: .infoLogLevel, message: "Paired to: \(name)")
        } else {
            log(level: .infoLogLevel, message: "Paired to device")
        }
        
        // no need to retain periphral if it is connected since it is being passed to the Connection class instance
        if (self.connectingPeripheral == peripheral) {
            self.connectingPeripheral = nil
        }

        // retain connections in array - create if does not exist yet
        if self.connections == nil {
            self.connections = [MeshSetupBluetoothConnection]()
        }
        
        let newConnection = MeshSetupBluetoothConnection(bluetoothConnectionManager: self, connectedPeripheral: peripheral)
        self.connections?.append(newConnection)
        self.delegate?.bluetoothConnectionCreated(connection: newConnection)
        newConnection.discoverServices()
        
        self.state = .Ready
        self.delegate?.bluetoothConnectionManagerReady()

    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            log(level: .debugLogLevel, message: "[Callback] Central Manager did disconnect peripheral")
            logError(error: error!)
            return
        }
        log(level: .debugLogLevel, message: "[Callback] Central Manager did disconnect peripheral successfully")
        log(level: .infoLogLevel, message: "Disconnected")

        
        if let connectionsArray = self.connections {
            for connectionElement in connectionsArray {
                if connectionElement._getPeripheral() == peripheral {
                    self.delegate?.bluetoothConnectionDropped(connection: connectionElement)
                    let index = connectionsArray.index(of: connectionElement)
                    self.connections?.remove(at: index!)
                }
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            log(level: .debugLogLevel, message: "[Callback] Central Manager did fail to connect to peripheral")
            logError(error: error!)
            return
        }
        log(level: .debugLogLevel, message: "[Callback] Central Manager did fail to connect to peripheral without errors")
        log(level: .infoLogLevel, message: "Failed to connect")
        
        delegate?.bluetoothConnectionManagerError(error: "Failed to connect to bluetooth peripheral", severity: .Error)
    }
    
    ///#
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let n = peripheral.name {
            print("centralManager didDiscover peripheral \(n)")
        } else {
            print("centralManager didDiscover peripheral")
        }
        print (advertisementData)
        // Scanner uses other queue to send events
        
        if peripheral.name == self.peripheralNameToConnect {
            if RSSI.int32Value < -90  {
                // TODO: message to user to come closer to device
                self.delegate?.bluetoothConnectionManagerError(error: "Device is too far from phone, get closer with your phone to the setup device", severity: .Warning)
//                self.delegate.message(...)
            }
            
            if peripheral.state == .connected {
                // TODO: save this peripheral and try to connect in "didDisconnectPeripheral"
                self.centralManager?.cancelPeripheralConnection(peripheral)
                self.delegate?.bluetoothConnectionManagerError(error: "Reinitializing connection to device", severity: .Warning)

            } else {
                self.state = .DiscoveredPeripheral
                self.centralManager!.stopScan()
                print ("Pairing to \(peripheral.name ?? "device")...")
                self.connectingPeripheral = peripheral
                self.centralManager!.connect(peripheral, options: nil)
            }
            
        }
        
    }
  
    
    
   
}
