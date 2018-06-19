//
//  NORServiceIdentifiers.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 18/05/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//
import Foundation

class NORServiceIdentifiers: NSObject {

    //MARK: - Battery Identifiers
    static let batteryServiceUUIDString                             = "0000180F-0000-1000-8000-00805F9B34FB"
    static let batteryLevelCharacteristicUUIDString                 = "00002A19-0000-1000-8000-00805F9B34FB"
    
    //MARK: - UART Identifiers
//    static let uartServiceUUIDString                                = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
//    static let uartTXCharacteristicUUIDString                       = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
//    static let uartRXCharacteristicUUIDString                       = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
//    
    //MARK: - Particle mesh Identifiers
    static let particleMeshServiceUUIDString                        = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    static let particleMeshTXCharacteristicUUIDString               = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    static let particleMeshRXCharacteristicUUIDString               = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    
}
