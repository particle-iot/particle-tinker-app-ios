//
//  MeshSetupBluetoothConnection.swift
//  Particle
//
//  Created by Ido Kleinman on 7/12/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol MeshSetupBluetoothConnectionDelegate {
    func bluetoothConnectionError(sender : MeshSetupBluetoothConnection, error: String, severity : MeshSetupErrorSeverity)
    func bluetoothConnectionReceivedData(sender : MeshSetupBluetoothConnection,  data : Data)
//    func didDisconnect(sender : MeshSetupBluetoothConnection)
    func bluetoothConnectionReady(sender : MeshSetupBluetoothConnection)
}



extension Data {
    
    internal var hexString: String {
        let pointer = self.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> UnsafePointer<UInt8> in
            return bytes
        }
        let array = getByteArray(pointer)
        
        return array.reduce("") { (result, byte) -> String in
            result + String(format: "%02x", byte)
        }
    }
    
    fileprivate func getByteArray(_ pointer: UnsafePointer<UInt8>) -> [UInt8] {
        let buffer = UnsafeBufferPointer<UInt8>(start: pointer, count: count)
        return [UInt8](buffer)
    }
}

class MeshSetupBluetoothConnection: NSObject, CBPeripheralDelegate {
    
    var delegate : MeshSetupBluetoothConnectionDelegate?
    var isReady : Bool = false

    private var peripheral : CBPeripheral?
    private var connectionManager : MeshSetupBluetoothConnectionManager?
    private var particleMeshRXCharacterisitic        : CBCharacteristic?
    private var particleMeshTXCharacterisitic        : CBCharacteristic?
    fileprivate let MTU = 20
    var y : Int?
    
    required init(bluetoothConnectionManager : MeshSetupBluetoothConnectionManager, connectedPeripheral : CBPeripheral) {
        super.init()
        self.connectionManager = bluetoothConnectionManager
        self.peripheral = connectedPeripheral
        self.peripheral?.delegate = self
        
        
    }
    
    func _getPeripheral() -> CBPeripheral? {
        return self.peripheral
    }
    
    
    func disconnect() {
        // TODO: memory management / releasing
        self.connectionManager?.dropConnection(with: self)
    }
    
    // TODO: scrap this
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
    
    func discoverServices() {
        self.peripheral?.discoverServices([particleMeshServiceUUID])
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
                
                self.peripheral!.discoverCharacteristics(nil, for: aService)
                return
            }
        }
        
        //No UART service discovered
        log(level: .warningLogLevel, message: "Particle Mesh commissioning Service not found. Try to turn bluetooth Off and On again to clear the cache.")
        delegate?.bluetoothConnectionError(sender : self, error : "Device unsupported - services mismatch", severity: .Error)
        self.connectionManager?.dropConnection(with: self)
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
                self.peripheral!.setNotifyValue(true, for: particleMeshTXCharacterisitic!)
            } else {
                
                log(level: .warningLogLevel, message: "UART service does not have required characteristics. Try to turn Bluetooth Off and On again to clear cache.")
                delegate?.bluetoothConnectionError(sender: self, error: "Device unsupported - characteristics mismatch", severity: .Error)
                self.connectionManager?.dropConnection(with: self)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            log(level: .warningLogLevel, message: "Enabling notifications failed")
            logError(error: error!)
            return
        }
        
        self.isReady = true
        self.delegate?.bluetoothConnectionReady(sender: self)
        
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
        
        self.delegate?.bluetoothConnectionReceivedData(sender: self, data: bytesReceived as Data)
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
                self.peripheral!.writeValue(part, for: self.particleMeshRXCharacterisitic!, type: type)
//                log(withLevel: .appLogLevel, andMessage: "\"\(part.hexString)\" sent")
            }
        }
    }


   

}
