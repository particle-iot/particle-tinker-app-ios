//
//  MeshSetupBluetoothConnection.swift
//  Particle
//
//  Created by Ido Kleinman on 7/12/18.
//  Maintained by Raimundas Sakalauskas
//  Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import CoreBluetooth


protocol MeshSetupBluetoothConnectionDelegate {
    func bluetoothConnectionBecameReady(sender: MeshSetupBluetoothConnection)
    func bluetoothConnectionError(sender: MeshSetupBluetoothConnection, error: BluetoothConnectionError, severity: MeshSetupErrorSeverity)
}

protocol MeshSetupBluetoothConnectionDataDelegate {
    func bluetoothConnectionDidReceiveData(sender: MeshSetupBluetoothConnection, data: Data)
}

enum BluetoothConnectionError: Error, CustomStringConvertible {
    case FailedToHandshake
    case FailedToDiscoverServices
    case FailedToDiscoverParticleMeshService
    case FailedToDiscoverCharacteristics
    case FailedToDiscoverParticleMeshCharacteristics
    case FailedToEnableBluetoothConnectionNotifications
    case FailedToWriteValueForCharacteristic
    case FailedToReadValueForCharacteristic


    public var description: String {
        switch self {
            case .FailedToHandshake : return "Failed to perform handshake"
            case .FailedToDiscoverServices : return "Failed to discover bluetooth services"
            case .FailedToDiscoverParticleMeshService : return "Particle Mesh commissioning Service not found. Try to turn bluetooth Off and On again to clear the cache."
            case .FailedToDiscoverCharacteristics : return "Failed to discover bluetooth characteristics"
            case .FailedToDiscoverParticleMeshCharacteristics : return "UART service does not have required characteristics. Try to turn Bluetooth Off and On again to clear cache."
            case .FailedToEnableBluetoothConnectionNotifications : return "Failed to enable bluetooth characteristic notifications"
            case .FailedToWriteValueForCharacteristic : return "Writing value for bluetooth characteristic has failed (sending data to device failed)"
            case .FailedToReadValueForCharacteristic : return "Reading value for bluetooth characteristic has failed (receiving data to device failed)"
        }
    }
}

class MeshSetupBluetoothConnection: NSObject, CBPeripheralDelegate, MeshSetupBluetoothConnectionHandshakeManagerDelegate {


    fileprivate let MTU = 20

    var delegate: MeshSetupBluetoothConnectionDelegate?
    var dataDelegate: MeshSetupBluetoothConnectionDataDelegate?

    var isReady: Bool = false

    var peripheralName: String
    var mobileSecret: String
    var derivedSecret: Data?

    var cbPeripheral: CBPeripheral {
        get {
            return peripheral
        }
    }

    private var peripheral: CBPeripheral
    private var handshakeRetry: Int = 0

    private var handshakeManager: MeshSetupBluetoothConnectionHandshakeManager?
    private var particleMeshRXCharacteristic: CBCharacteristic!
    private var particleMeshTXCharacteristic: CBCharacteristic!

    required init(connectedPeripheral: CBPeripheral, credentials: MeshSetupPeripheralCredentials) {

        self.peripheral = connectedPeripheral
        self.peripheralName = peripheral.name!
        self.mobileSecret = credentials.mobileSecret

        super.init()

        self.peripheral.delegate = self
        self.discoverServices()
    }

    private func log(_ message: String) {
        if (MeshSetup.LogBluetoothConnection) {
            NSLog(message)
        }
    }

    private func fail(withReason reason: BluetoothConnectionError, severity: MeshSetupErrorSeverity) {
        log("Bluetooth connection error: \(reason), severity: \(severity)")
        self.delegate?.bluetoothConnectionError(sender: self, error: reason, severity: severity)

    }

    func discoverServices() {
        self.peripheral.discoverServices([MeshSetup.particleMeshServiceUUID])
    }

    func send(data aData: Data) {
        guard self.particleMeshRXCharacteristic != nil else {
            log("UART RX Characteristic not found")
            return
        }

        // Check what kind of Write Type is supported. By default it will try Without Response.
        // If the RX charactereisrtic have Write property the Write Request type will be used.
        var type = CBCharacteristicWriteType.withoutResponse
        if (self.particleMeshRXCharacteristic!.properties.rawValue & CBCharacteristicProperties.write.rawValue) > 0 {
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
                var part: Data
                if len > MTU && (type == CBCharacteristicWriteType.withoutResponse || longWriteSupported == false) {
                    // If the text contains national letters they may be 2-byte long.
                    // It may happen that only 19 (MTU) bytes can be send so that not of them is splited into 2 packets.
                    // var builder = NSMutableString(bytes: buffer, length: MTU, encoding: String.Encoding.utf8.rawValue)
                    part = Data(bytes: buffer, count: MTU)
                    // A 20-byte string has been created successfully
                    buffer  = buffer + MTU
                    len     = len - MTU


                } else {
                    part = Data(bytes: buffer, count: len)
                    len = 0
                }
                self.peripheral.writeValue(part, for: self.particleMeshRXCharacteristic!, type: type)
            }
        }
        NSLog("Sent data: \(aData.count) Bytes")
    }
    
    //MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            NSLog("error = \(error)")
            fail(withReason: .FailedToDiscoverServices, severity: .Error)
            return
        }

        log("Services discovered")
        for aService in peripheral.services! {
            if aService.uuid.isEqual(MeshSetup.particleMeshServiceUUID) {
                log("Particle Mesh commissioning Service found")
                self.peripheral.discoverCharacteristics(nil, for: aService)
                return
            }
        }
        
        fail(withReason: .FailedToDiscoverParticleMeshService, severity: .Error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            NSLog("error = \(error)")
            fail(withReason: .FailedToDiscoverCharacteristics, severity: .Error)
            return
        }
        log("Characteristics discovered")
        
        if service.uuid.isEqual(MeshSetup.particleMeshServiceUUID) {
            for aCharacteristic in service.characteristics! {
                if aCharacteristic.uuid.isEqual(MeshSetup.particleMeshTXCharacterisiticUUID) {
                    log("Particle mesh TX Characteristic found")
                    particleMeshTXCharacteristic = aCharacteristic
                } else if aCharacteristic.uuid.isEqual(MeshSetup.particleMeshRXCharacterisiticUUID) {
                    log("Particle mesh RX Characteristic found")
                    particleMeshRXCharacteristic = aCharacteristic
                }
            }

            //Enable notifications on TX Characteristic
            if (particleMeshTXCharacteristic != nil && particleMeshRXCharacteristic != nil) {
                log("Enabling notifications for \(particleMeshTXCharacteristic!.uuid.uuidString)")
                self.peripheral.setNotifyValue(true, for: particleMeshTXCharacteristic!)
            } else {
                fail(withReason: .FailedToDiscoverParticleMeshCharacteristics, severity: .Error)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, characteristic.isNotifying == true else {
            NSLog("error = \(error)")
            fail(withReason: .FailedToEnableBluetoothConnectionNotifications, severity: .Error)

            return
        }

        self.handshakeManager = MeshSetupBluetoothConnectionHandshakeManager(connection: self, mobileSecret: mobileSecret)
        self.handshakeManager!.delegate = self
        self.handshakeManager!.startHandshake()
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            NSLog("error = \(error)")
            fail(withReason: .FailedToWriteValueForCharacteristic, severity: .Error)

            return
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            NSLog("error = \(error)")
            fail(withReason: .FailedToReadValueForCharacteristic, severity: .Error)

            return
        }

        if let bytesReceived = characteristic.value {
            bytesReceived.withUnsafeBytes { (utf8Bytes: UnsafePointer<CChar>) in
                var len = bytesReceived.count
                if utf8Bytes[len - 1] == 0 {
                    len -= 1 // if the string is null terminated, don't pass null terminator into NSMutableString constructor
                }

                NSLog("Bytes received from: \(characteristic.uuid.uuidString), \(bytesReceived.count) Bytes")
            }

            if (self.isReady) {
                self.dataDelegate?.bluetoothConnectionDidReceiveData(sender: self, data: bytesReceived as Data)
            } else {
                self.handshakeManager!.readBytes(bytesReceived as Data)
            }
        }
    }

    //MARK: MeshSetupBluetoothConnectionHandshakeManagerDelegate
    func handshakeDidFail(sender: MeshSetupBluetoothConnectionHandshakeManager, error: HandshakeManagerError, severity: MeshSetupErrorSeverity) {
        log("Handshake Error: \(error)")

        if (handshakeRetry < 3) {
            handshakeRetry += 1
        } else {
            fail(withReason: .FailedToHandshake, severity: .Error)
        }

        //retry handshake
        self.handshakeManager!.delegate = nil
        self.handshakeManager = nil

        self.handshakeManager = MeshSetupBluetoothConnectionHandshakeManager(connection: self, mobileSecret: mobileSecret)
        self.handshakeManager!.delegate = self
        self.handshakeManager!.startHandshake()
    }


    func handshakeDidSucceed(sender: MeshSetupBluetoothConnectionHandshakeManager, derivedSecret: Data) {
        self.derivedSecret = derivedSecret

        self.handshakeManager!.delegate = nil
        self.handshakeManager = nil

        self.isReady = true
        self.delegate?.bluetoothConnectionBecameReady(sender: self)
    }

   

}
