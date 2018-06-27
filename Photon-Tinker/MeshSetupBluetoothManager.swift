//
//  NORBluetoothManager.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 06/05/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth


class MeshSetupServiceIdentifiers: NSObject {
    //MARK: - Particle mesh Identifiers
    static let particleMeshServiceUUIDString                        = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    static let particleMeshTXCharacteristicUUIDString               = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    static let particleMeshRXCharacteristicUUIDString               = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
}

enum BLELogLevel : String {
    
    case debugLogLevel = "debug"
    case verboseLogLevel = "verbose"
    case infoLogLevel = "info"
    case appLogLevel = "app"
    case warningLogLevel = "warning"
    case errorLogLevel = "error"
}

protocol MeshSetupBluetoothManagerDelegate {
    func didUpdateState(state : CBCentralManagerState)
    func didConnectPeripheral(deviceName aName : String?)
    func didDisconnectPeripheral()
    func peripheralReady()
    func peripheralNotSupported()
    func didReceiveData(data buffer : Data)
}



class MeshSetupBluetoothManager: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    //MARK: - Delegate Properties
    var delegate : MeshSetupBluetoothManagerDelegate?
    
    fileprivate let particleMeshServiceUUID              : CBUUID = CBUUID(string: MeshSetupServiceIdentifiers.particleMeshServiceUUIDString)
    fileprivate let particleMeshRXCharacterisiticUUID    : CBUUID = CBUUID(string: MeshSetupServiceIdentifiers.particleMeshRXCharacteristicUUIDString)
    fileprivate let particleMeshTXCharacterisiticUUID    : CBUUID = CBUUID(string: MeshSetupServiceIdentifiers.particleMeshTXCharacteristicUUIDString)
    
    //MARK: - Class Properties
    fileprivate let MTU = 20
    fileprivate var centralManager                       : CBCentralManager?
    fileprivate var bluetoothPeripheral                  : CBPeripheral?
   
    fileprivate var particleMeshRXCharacterisitic        : CBCharacteristic?
    fileprivate var particleMeshTXCharacterisitic        : CBCharacteristic?
    fileprivate var peripheralNameToConnect              : String?
    
    
    fileprivate var connected = false
    
    //MARK: - BluetoothManager API
    
    required override init() {
        
        super.init()
        
        let centralQueue = DispatchQueue(label: "io.particle.mesh", attributes: [])
        self.centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        
////        particleMeshServiceUUID
//        particleMeshTXCharacterisiticUUID =
//        particleMeshRXCharacterisiticUUID =
        
        

    }
    
    /**
     * Connects to the given peripheral.
     * 
     * - parameter aPeripheral: target peripheral to connect to
     */
    func connectPeripheral(peripheral aPeripheral : CBPeripheral) {
        bluetoothPeripheral = aPeripheral
        
        // we assign the bluetoothPeripheral property after we establish a connection, in the callback
        if let name = aPeripheral.name {
            log(level: .verboseLogLevel, message: "Connecting to: \(name)...")
        } else {
            log(level: .verboseLogLevel, message: "Connecting to device...")
        }
        log(level: .debugLogLevel, message: "centralManager.connect(peripheral, options:nil)")
        centralManager?.connect(aPeripheral, options: nil)
    }
    
    /**
     * Disconnects or cancels pending connection.
     * The delegate's didDisconnectPeripheral() method will be called when device got disconnected.
     */
    func cancelPeripheralConnection() {
        guard bluetoothPeripheral != nil else {
            log(level: .warningLogLevel, message: "Peripheral not set")
            return
        }
        if connected {
            log(level: .verboseLogLevel, message: "Disconnecting...")
        } else {
            log(level: .verboseLogLevel, message: "Cancelling connection...")
        }
        log(level: .debugLogLevel, message: "centralManager.cancelPeripheralConnection(peripheral)")
        centralManager?.cancelPeripheralConnection(bluetoothPeripheral!)
        
        // In case the previous connection attempt failed before establishing a connection
        if !connected {
            bluetoothPeripheral = nil
            delegate?.didDisconnectPeripheral()
        }
    }
    
    /**
     * Returns true if the peripheral device is connected, false otherwise
     * - returns: true if device is connected
     */
    func isConnected() -> Bool {
        return connected
    }
    
    /**
     * This method sends the given test to the UART RX characteristic.
     * Depending on whether the characteristic has the Write Without Response or Write properties the behaviour is different.
     * In the latter case the Long Write may be used. To enable it you have to change the flag below in the code.
     * Otherwise, in both cases, texts longer than 20 (MTU) bytes (not characters) will be splitted into up-to 20-byte packets.
     *
     * - parameter aText: text to be sent to the peripheral using Nordic UART Service
     */
    func send(text aText : String) {
        guard self.particleMeshRXCharacterisitic != nil else {
            log(level: .warningLogLevel, message: "UART RX Characteristic not found")
            return
        }
        
        // Check what kind of Write Type is supported. By default it will try Without Response.
        // If the RX charactereisrtic have Write property the Write Request type will be used.
        var type = CBCharacteristicWriteType.withoutResponse
        if (self.particleMeshRXCharacterisitic!.properties.rawValue & CBCharacteristicProperties.write.rawValue) > 0 {
            type = CBCharacteristicWriteType.withResponse
        }
        
        // In case of Write Without Response the text needs to be splited in up-to 20-bytes packets.
        // When Write Request (with response) is used, the Long Write may be used. 
        // It will be handled automatically by the iOS, but must be supported on the device side.
        // If your device does support Long Write, change the flag below to true.
        let longWriteSupported = false
        
        // The following code will split the text to packets
        let textData = aText.data(using: String.Encoding.utf8)!
        textData.withUnsafeBytes { (u8Ptr: UnsafePointer<CChar>) in
            var buffer = UnsafeMutableRawPointer(mutating: UnsafeRawPointer(u8Ptr))
            var len = textData.count
            
            while(len != 0){
                var part : String
                if len > MTU && (type == CBCharacteristicWriteType.withoutResponse || longWriteSupported == false) {
                    // If the text contains national letters they may be 2-byte long. 
                    // It may happen that only 19 (MTU) bytes can be send so that not of them is splited into 2 packets.
                    var builder = NSMutableString(bytes: buffer, length: MTU, encoding: String.Encoding.utf8.rawValue)
                    if builder != nil {
                        // A 20-byte string has been created successfully
                        buffer  = buffer + MTU
                        len     = len - MTU
                    } else {
                        // We have to create 19-byte string. Let's ignore some stranger UTF-8 characters that have more than 2 bytes...
                        builder = NSMutableString(bytes: buffer, length: (MTU - 1), encoding: String.Encoding.utf8.rawValue)
                        buffer = buffer + (MTU - 1)
                        len    = len - (MTU - 1)
                    }
                    
                    part = String(describing: builder!)
                } else {
                    let builder = NSMutableString(bytes: buffer, length: len, encoding: String.Encoding.utf8.rawValue)
                    part = String(describing: builder!)
                    len = 0
                }
                send(text: part, withType: type)
            }
        }
    }
    
    func send(data aData : Data) {
        guard self.particleMeshRXCharacterisitic != nil else {
            log(level: .warningLogLevel, message: "UART RX Characteristic not found")
            return
        }
        
        // Check what kind of Write Type is supported. By default it will try Without Response.
        // If the RX charactereisrtic have Write property the Write Request type will be used.
        var type = CBCharacteristicWriteType.withoutResponse
        if (self.particleMeshRXCharacterisitic!.properties.rawValue & CBCharacteristicProperties.write.rawValue) > 0 {
            type = CBCharacteristicWriteType.withResponse
        }
        
        // In case of Write Without Response the text needs to be splited in up-to 20-bytes packets.
        // When Write Request (with response) is used, the Long Write may be used.
        // It will be handled automatically by the iOS, but must be supported on the device side.
        // If your device does support Long Write, change the flag below to true.
        let longWriteSupported = false
        
        // The following code will split the text to packets
        aData.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            var buffer = UnsafeMutableRawPointer(mutating: UnsafeRawPointer(u8Ptr))
            var len = aData.count
            
            while(len != 0){
                var part : Data
                if len > MTU && (type == CBCharacteristicWriteType.withoutResponse || longWriteSupported == false) {
                    // If the text contains national letters they may be 2-byte long.
                    // It may happen that only 19 (MTU) bytes can be send so that not of them is splited into 2 packets.
//                    var builder = NSMutableString(bytes: buffer, length: MTU, encoding: String.Encoding.utf8.rawValue)
                    part = Data(bytes: buffer, count: MTU)
                        // A 20-byte string has been created successfully
                    buffer  = buffer + MTU
                    len     = len - MTU
                    
                    
                } else {
                    part = Data(bytes: buffer, count: len)
                    len = 0
                }
                send(data: part, withType: type)
            }
        }
    }
    
    /**
     * Sends the given text to the UART RX characteristic using the given write type.
     * This method does not split the text into parts. If the given write type is withResponse
     * and text is longer than 20-bytes the long write will be used.
     *
     * - parameters:
     *     - aText: text to be sent to the peripheral using Nordic UART Service
     *     - aType: write type to be used
     */
    func send(text aText : String, withType aType : CBCharacteristicWriteType) {
        guard self.particleMeshRXCharacterisitic != nil else {
            log(level: .warningLogLevel, message: "UART RX Characteristic not found")
            return
        }
        
        let typeAsString = aType == .withoutResponse ? ".withoutResponse" : ".withResponse"
        let data = aText.data(using: String.Encoding.utf8)!
        
        //do some logging
        log(level: .verboseLogLevel, message: "Writing to characteristic: \(particleMeshRXCharacterisitic!.uuid.uuidString)")
        log(level: .debugLogLevel, message: "peripheral.writeValue(0x\(data.hexString), for: \(particleMeshRXCharacterisitic!.uuid.uuidString), type: \(typeAsString))")
        self.bluetoothPeripheral!.writeValue(data, for: self.particleMeshRXCharacterisitic!, type: aType)
        // The transmitted data is not available after the method returns. We have to log the text here.
        // The callback peripheral:didWriteValueForCharacteristic:error: is called only when the Write Request type was used,
        // but even if, the data is not available there.
        log(level: .appLogLevel, message: "\"\(aText)\" sent")
    }
    
    
    func send(data aData : Data, withType aType : CBCharacteristicWriteType) {
        guard self.particleMeshRXCharacterisitic != nil else {
            log(level: .warningLogLevel, message: "UART RX Characteristic not found")
            return
        }
        
        let typeAsString = aType == .withoutResponse ? ".withoutResponse" : ".withResponse"
        
        //do some logging
        log(level: .verboseLogLevel, message: "Writing to characteristic: \(particleMeshRXCharacterisitic!.uuid.uuidString)")
        log(level: .debugLogLevel, message: "peripheral.writeValue(0x\(aData.hexString), for: \(particleMeshRXCharacterisitic!.uuid.uuidString), type: \(typeAsString))")
        self.bluetoothPeripheral!.writeValue(aData, for: self.particleMeshRXCharacterisitic!, type: aType)
        // The transmitted data is not available after the method returns. We have to log the text here.
        // The callback peripheral:didWriteValueForCharacteristic:error: is called only when the Write Request type was used,
        // but even if, the data is not available there.
        log(level: .appLogLevel, message: "\"\(aData.hexString)\" sent")
    }
    
    //MARK: - Logger API
    
    func log(level : BLELogLevel, message : String) {
//        logger?.log(level: aLevel, message: aMessage)
        print("[\(level.rawValue)]: \(message)")
    }
    
    func logError(error anError : Error) {
        if let e = anError as? CBError {
            self.log(level: .errorLogLevel, message: "Error \(e.code): \(e.localizedDescription)")
        } else {
            self.log(level: .errorLogLevel, message: "Error \(anError.localizedDescription)")
        }
    }
    
    //MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state : String
        switch(central.state){
        case .poweredOn:
            state = "Powered ON"
            break
        case .poweredOff:
            state = "Powered OFF"
            break
        case .resetting:
            state = "Resetting"
            break
        case .unauthorized:
            state = "Unautthorized"
            break
        case .unsupported:
            state = "Unsupported"
            break
        case .unknown:
            state = "Unknown"
            break
        }
        
//        self.delegate?.didUpdateState(state: central.state)
        
        log(level: .debugLogLevel, message: "[Callback] Central Manager did update state to: \(state)")
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log(level: .debugLogLevel, message: "[Callback] Central Manager did connect peripheral")
        if let name = peripheral.name {
            log(level: .infoLogLevel, message: "Connected to: \(name)")
        } else {
            log(level: .infoLogLevel, message: "Connected to device")
        }
        
        connected = true
        bluetoothPeripheral = peripheral
        bluetoothPeripheral!.delegate = self
        delegate?.didConnectPeripheral(deviceName: peripheral.name)
        log(level: .verboseLogLevel, message: "Discovering services...")
        log(level: .debugLogLevel, message: "peripheral.discoverServices([\(particleMeshServiceUUID.uuidString)])")
        peripheral.discoverServices([particleMeshServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            log(level: .debugLogLevel, message: "[Callback] Central Manager did disconnect peripheral")
            logError(error: error!)
            return
        }
        log(level: .debugLogLevel, message: "[Callback] Central Manager did disconnect peripheral successfully")
        log(level: .infoLogLevel, message: "Disconnected")
        
        connected = false
        delegate?.didDisconnectPeripheral()
        bluetoothPeripheral!.delegate = nil
        bluetoothPeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            log(level: .debugLogLevel, message: "[Callback] Central Manager did fail to connect to peripheral")
            logError(error: error!)
            return
        }
        log(level: .debugLogLevel, message: "[Callback] Central Manager did fail to connect to peripheral without errors")
        log(level: .infoLogLevel, message: "Failed to connect")
        
        connected = false
        delegate?.didDisconnectPeripheral()
        bluetoothPeripheral!.delegate = nil
        bluetoothPeripheral = nil
    }
    
    ///#
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("centralManager didDiscover")
        print (advertisementData)
        // Scanner uses other queue to send events
        
        if peripheral.name == self.peripheralNameToConnect {
            if RSSI.int32Value < -90  {
                // TODO: message to user to come closer to device
                print ("Device is too far from phone, come closer")
            } else if peripheral.state == .connected {
                self.centralManager?.cancelPeripheralConnection(peripheral)
            } else {
                self.centralManager?.stopScan()
                print ("Pairing to \(peripheral.name ?? "device")...")
                self.centralManager?.connect(peripheral, options: nil)
            }
            
        }
        
    }
    
    func scanForPeripherals() -> Bool {
        guard self.centralManager?.state == .poweredOn else {
            return false
        }
        
        print ("scanForPeripherals")
        DispatchQueue.main.async {
            let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
            
            self.centralManager?.scanForPeripherals(withServices: [self.particleMeshServiceUUID], options: options as? [String : AnyObject])
        }
        
        return true
    }
    
    
    //MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            log(level: .warningLogLevel, message: "Service discovery failed")
            logError(error: error!)
            //TODO: Disconnect?
            return
        }
        
        log(level: .infoLogLevel, message: "Services discovered")
        
        for aService: CBService in peripheral.services! {
            if aService.uuid.isEqual(particleMeshServiceUUID) {
                log(level: .verboseLogLevel, message: "Particle Mesh commissioning Service found")
                log(level: .verboseLogLevel, message: "Discovering characteristics...")
                log(level: .debugLogLevel, message: "peripheral.discoverCharacteristics(nil, for: \(aService.uuid.uuidString))")
                bluetoothPeripheral!.discoverCharacteristics(nil, for: aService)
                return
            }
        }
        
        //No UART service discovered
        log(level: .warningLogLevel, message: "Particle Mesh commissioning Service not found. Try to turn bluetooth Off and On again to clear the cache.")
        delegate?.peripheralNotSupported()
        cancelPeripheralConnection()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            log(level: .warningLogLevel, message: "Characteristics discovery failed")
            logError(error: error!)
            return
        }
        log(level: .infoLogLevel, message: "Characteristics discovered")
        
        if service.uuid.isEqual(particleMeshServiceUUID) {
            for aCharacteristic : CBCharacteristic in service.characteristics! {
                if aCharacteristic.uuid.isEqual(particleMeshTXCharacterisiticUUID) {
                    log(level: .verboseLogLevel, message: "Particle mesh TX Characteristic found")
                    particleMeshTXCharacterisitic = aCharacteristic
                } else if aCharacteristic.uuid.isEqual(particleMeshRXCharacterisiticUUID) {
                    log(level: .verboseLogLevel, message: "Particle mesh RX Characteristic found")
                    particleMeshRXCharacterisitic = aCharacteristic
                }
            }
            //Enable notifications on TX Characteristic
            if (particleMeshTXCharacterisitic != nil && particleMeshRXCharacterisitic != nil) {
                log(level: .verboseLogLevel, message: "Enabling notifications for \(particleMeshTXCharacterisitic!.uuid.uuidString)")
                log(level: .debugLogLevel, message: "peripheral.setNotifyValue(true, for: \(particleMeshTXCharacterisitic!.uuid.uuidString))")
                bluetoothPeripheral!.setNotifyValue(true, for: particleMeshTXCharacterisitic!)
            } else {
                log(level: .warningLogLevel, message: "UART service does not have required characteristics. Try to turn Bluetooth Off and On again to clear cache.")
                delegate?.peripheralNotSupported()
                cancelPeripheralConnection()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            log(level: .warningLogLevel, message: "Enabling notifications failed")
            logError(error: error!)
            return
        }
        
        if characteristic.isNotifying {
            log(level: .infoLogLevel, message: "Notifications enabled for characteristic: \(characteristic.uuid.uuidString)")
        } else {
            log(level: .infoLogLevel, message: "Notifications disabled for characteristic: \(characteristic.uuid.uuidString)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            log(level: .warningLogLevel, message: "Writing value to characteristic has failed")
            logError(error: error!)
            return
        }
        log(level: .infoLogLevel, message: "Data written to characteristic: \(characteristic.uuid.uuidString)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            log(level: .warningLogLevel, message: "Writing value to descriptor has failed")
            logError(error: error!)
            return
        }
        log(level: .infoLogLevel, message: "Data written to descriptor: \(descriptor.uuid.uuidString)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            log(level: .warningLogLevel, message: "Updating characteristic has failed")
            logError(error: error!)
            return
        }
        
        // try to print a friendly string of received bytes if they can be parsed as UTF8
        guard let bytesReceived = characteristic.value else {
            log(level: .infoLogLevel, message: "Notification received from: \(characteristic.uuid.uuidString), with empty value")
            log(level: .appLogLevel, message: "Empty packet received")
            return
        }
        bytesReceived.withUnsafeBytes { (utf8Bytes: UnsafePointer<CChar>) in
            var len = bytesReceived.count
            if utf8Bytes[len - 1] == 0 {
                len -= 1 // if the string is null terminated, don't pass null terminator into NSMutableString constructor
            }
            
            log(level: .infoLogLevel, message: "Notification received from: \(characteristic.uuid.uuidString), with value: 0x\(bytesReceived.hexString)")
            if let validUTF8String = String(utf8String: utf8Bytes) {//  NSMutableString(bytes: utf8Bytes, length: len, encoding: String.Encoding.utf8.rawValue) {
                log(level: .appLogLevel, message: "\"\(validUTF8String)\" received")
            } else {
                log(level: .appLogLevel, message: "\"0x\(bytesReceived.hexString)\" received")
            }
        }
        
        self.delegate?.didReceiveData(data: bytesReceived as Data)
    }
}
