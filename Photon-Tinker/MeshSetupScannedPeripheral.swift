//
//  NORScannedPeripheral.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 28/04/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupScannedPeripheral: NSObject {
    
    var peripheral  : CBPeripheral
    var RSSI        : Int32
    var isConnected : Bool
    
    init(withPeripheral aPeripheral: CBPeripheral, andRSSI anRSSI:Int32 = 0, andIsConnected aConnectionStatus: Bool) {
        peripheral = aPeripheral
        RSSI = anRSSI
        isConnected = aConnectionStatus
    }

    func name()->String{
        let peripheralName = peripheral.name
        if peripheral.name == nil {
            return "No name"
        }else{
            return peripheralName!
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let otherPeripheral = object as? MeshSetupScannedPeripheral {
            return peripheral == otherPeripheral.peripheral
        }
        return false
    }
}

class MeshSetupServiceIdentifiers: NSObject {
    
    //MARK: - Particle mesh Identifiers
    static let particleMeshServiceUUIDString                        = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    static let particleMeshTXCharacteristicUUIDString               = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    static let particleMeshRXCharacteristicUUIDString               = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    
}


