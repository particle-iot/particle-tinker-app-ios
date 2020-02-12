//
// Created by Ido Kleinman on 7/12/18.
// Maintained by Raimundas Sakalauskas
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit
import CoreBluetooth


protocol Gen3SetupBluetoothConnectionDelegate {
    func bluetoothConnectionBecameReady(sender: Gen3SetupBluetoothConnection)
    func bluetoothConnectionError(sender: Gen3SetupBluetoothConnection, error: BluetoothConnectionError, severity: Gen3SetupErrorSeverity)
}

protocol Gen3SetupBluetoothConnectionDataDelegate {
    func bluetoothConnectionDidReceiveData(sender: Gen3SetupBluetoothConnection, data: Data)
}

enum BluetoothConnectionError: Error, CustomStringConvertible {
    case FailedToHandshake
    case FailedToDiscoverServices
    case FailedToDiscoverParticleGen3Service
    case FailedToDiscoverCharacteristics
    case FailedToDiscoverParticleGen3Characteristics
    case FailedToEnableBluetoothConnectionNotifications
    case FailedToWriteValueForCharacteristic
    case FailedToReadValueForCharacteristic


    public var description: String {
        switch self {
            case .FailedToHandshake : return "Failed to perform handshake"
            case .FailedToDiscoverServices : return "Failed to discover bluetooth services"
            case .FailedToDiscoverParticleGen3Service : return "Particle Gen 3 commissioning Service not found. Try to turn bluetooth Off and On again to clear the cache."
            case .FailedToDiscoverCharacteristics : return "Failed to discover bluetooth characteristics"
            case .FailedToDiscoverParticleGen3Characteristics : return "UART service does not have required characteristics. Try to turn Bluetooth Off and On again to clear cache."
            case .FailedToEnableBluetoothConnectionNotifications : return "Failed to enable bluetooth characteristic notifications"
            case .FailedToWriteValueForCharacteristic : return "Writing value for bluetooth characteristic has failed (sending data to device failed)"
            case .FailedToReadValueForCharacteristic : return "Reading value for bluetooth characteristic has failed (receiving data to device failed)"
        }
    }
}

class Gen3SetupBluetoothConnection: NSObject, CBPeripheralDelegate, Gen3SetupBluetoothConnectionHandshakeManagerDelegate {




    var delegate: Gen3SetupBluetoothConnectionDelegate?
    var dataDelegate: Gen3SetupBluetoothConnectionDataDelegate?

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

    private var handshakeManager: Gen3SetupBluetoothConnectionHandshakeManager?
    private var particleGen3RXCharacteristic: CBCharacteristic!
    private var particleGen3TXCharacteristic: CBCharacteristic!

    required init(connectedPeripheral: CBPeripheral, credentials: Gen3SetupPeripheralCredentials) {

        self.peripheral = connectedPeripheral
        self.peripheralName = peripheral.name!
        self.mobileSecret = credentials.mobileSecret

        super.init()

        self.peripheral.delegate = self
        self.discoverServices()
    }

    private func log(_ message: String) {
        ParticleLogger.logInfo("BluetoothConnection", format: message, withParameters: getVaList([]))
    }

    private func fail(withReason reason: BluetoothConnectionError, severity: Gen3SetupErrorSeverity) {
        log("Bluetooth connection error: \(reason), severity: \(severity)")
        self.delegate?.bluetoothConnectionError(sender: self, error: reason, severity: severity)

    }

    func discoverServices() {
        self.peripheral.discoverServices([Gen3Setup.particleGen3ServiceUUID])
    }

    func send(data aData: Data, writeType: CBCharacteristicWriteType = .withResponse) {
        guard self.particleGen3RXCharacteristic != nil else {
            log("UART RX Characteristic not found")
            return
        }

        var MTU = peripheral.maximumWriteValueLength(for: .withoutResponse)
        //using MTU for different write type is bad idea, but since xenons report bad MTU for
        //withResponse, it's either that or 20byte hardcoded value. Tried this with iPhone 5 / iOS 9
        //and it worked so left it this way to improve communication speed.
//        if (writeType == .withResponse) {
//            //withResponse reports wrong MTU and xenon triggers disconnect
//            MTU = 20
//        }

        // The following code will split the text to packets
        aData.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            var buffer = UnsafeMutableRawPointer(mutating: UnsafeRawPointer(u8Ptr))
            var len = aData.count

            while(len != 0){
                var part: Data
                if len > MTU {
                    part = Data(bytes: buffer, count: MTU)
                    buffer  = buffer + MTU
                    len     = len - MTU
                } else {
                    part = Data(bytes: buffer, count: len)
                    len = 0
                }
                self.peripheral.writeValue(part, for: self.particleGen3RXCharacteristic!, type: writeType)
            }
        }
        log("Sent data: \(aData.count) Bytes")
    }
    
    //MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            log("error = \(error)")
            fail(withReason: .FailedToDiscoverServices, severity: .Error)
            return
        }

        log("Services discovered")
        for aService in peripheral.services! {
            if aService.uuid.isEqual(Gen3Setup.particleGen3ServiceUUID) {
                log("Particle Gen 3 commissioning Service found")
                self.peripheral.discoverCharacteristics(nil, for: aService)
                return
            }
        }
        
        fail(withReason: .FailedToDiscoverParticleGen3Service, severity: .Error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            NSLog("error = \(error)")
            fail(withReason: .FailedToDiscoverCharacteristics, severity: .Error)
            return
        }
        log("Characteristics discovered")
        
        if service.uuid.isEqual(Gen3Setup.particleGen3ServiceUUID) {
            for aCharacteristic in service.characteristics! {
                if aCharacteristic.uuid.isEqual(Gen3Setup.particleGen3TXCharacterisiticUUID) {
                    log("Particle gen 3 setup TX Characteristic found")
                    particleGen3TXCharacteristic = aCharacteristic
                } else if aCharacteristic.uuid.isEqual(Gen3Setup.particleGen3RXCharacterisiticUUID) {
                    log("Particle gen 3 setup RX Characteristic found")
                    particleGen3RXCharacteristic = aCharacteristic
                }
            }

            //Enable notifications on TX Characteristic
            if (particleGen3TXCharacteristic != nil && particleGen3RXCharacteristic != nil) {
                log("Enabling notifications for \(particleGen3TXCharacteristic!.uuid.uuidString)")
                self.peripheral.setNotifyValue(true, for: particleGen3TXCharacteristic!)
            } else {
                fail(withReason: .FailedToDiscoverParticleGen3Characteristics, severity: .Error)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, characteristic.isNotifying == true else {
            NSLog("error = \(error)")
            fail(withReason: .FailedToEnableBluetoothConnectionNotifications, severity: .Error)

            return
        }

        self.handshakeManager = Gen3SetupBluetoothConnectionHandshakeManager(connection: self, mobileSecret: mobileSecret)
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

                log("Bytes received from: \(characteristic.uuid.uuidString), \(bytesReceived.count) Bytes")
            }

            if (self.isReady) {
                self.dataDelegate?.bluetoothConnectionDidReceiveData(sender: self, data: bytesReceived as Data)
            } else {
                self.handshakeManager!.readBytes(bytesReceived as Data)
            }
        }
    }

    //MARK: Gen3SetupBluetoothConnectionHandshakeManagerDelegate
    func handshakeDidFail(sender: Gen3SetupBluetoothConnectionHandshakeManager, error: HandshakeManagerError, severity: Gen3SetupErrorSeverity) {
        log("Handshake Error: \(error)")

        if (handshakeRetry < 3) {
            handshakeRetry += 1
        } else {
            fail(withReason: .FailedToHandshake, severity: .Error)
        }

        //retry handshake
        self.handshakeManager!.delegate = nil
        self.handshakeManager = nil

        self.handshakeManager = Gen3SetupBluetoothConnectionHandshakeManager(connection: self, mobileSecret: mobileSecret)
        self.handshakeManager!.delegate = self
        self.handshakeManager!.startHandshake()
    }


    func handshakeDidSucceed(sender: Gen3SetupBluetoothConnectionHandshakeManager, derivedSecret: Data) {
        self.derivedSecret = derivedSecret

        self.handshakeManager!.delegate = nil
        self.handshakeManager = nil

        self.isReady = true
        self.delegate?.bluetoothConnectionBecameReady(sender: self)
    }

   

}
