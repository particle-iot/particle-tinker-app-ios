//
// Created by Raimundas Sakalauskas on 23/08/2018.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit
import CoreBluetooth



protocol Gen3SetupBluetoothConnectionManagerDelegate {
    func bluetoothConnectionManagerStateChanged(sender: Gen3SetupBluetoothConnectionManager, state: Gen3SetupBluetoothConnectionManagerState)
    func bluetoothConnectionManagerError(sender: Gen3SetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: Gen3SetupErrorSeverity)

    func bluetoothConnectionManagerPeripheralDiscovered(sender: Gen3SetupBluetoothConnectionManager, peripheral: CBPeripheral)
    func bluetoothConnectionManagerConnectionCreated(sender: Gen3SetupBluetoothConnectionManager, connection: Gen3SetupBluetoothConnection)
    func bluetoothConnectionManagerConnectionBecameReady(sender: Gen3SetupBluetoothConnectionManager, connection: Gen3SetupBluetoothConnection)
    func bluetoothConnectionManagerConnectionDropped(sender: Gen3SetupBluetoothConnectionManager, connection: Gen3SetupBluetoothConnection)
}

enum Gen3SetupBluetoothConnectionManagerState {
    case Disabled
    case Ready
    case Scanning
    case PeripheralDiscovered
}


enum BluetoothConnectionManagerError: Error, CustomStringConvertible {
    case FailedToStartScan
    case FailedToScanBecauseOfTimeout
    case DeviceTooFar
    case DeviceWasConnected //need to reconnect to the device
    case FailedToConnect

    public var description: String {
        switch self {
            case .FailedToStartScan : return "Failed to start scan, please make sure manager state is Ready"
            case .FailedToScanBecauseOfTimeout: return "BLE scan timeout"
            case .DeviceTooFar: return "Device is too far from phone, get closer with your phone to the setup device"
            case .DeviceWasConnected: return "Device was connected when it shouldn't be"
            case .FailedToConnect: return "Failed to connect to bluetooth peripheral"
        }
    }
}


class Gen3SetupBluetoothConnectionManager: NSObject, CBCentralManagerDelegate, Gen3SetupBluetoothConnectionDelegate {

    var delegate: Gen3SetupBluetoothConnectionManagerDelegate
    var state: Gen3SetupBluetoothConnectionManagerState = .Disabled {
        didSet {
            self.delegate.bluetoothConnectionManagerStateChanged(sender: self, state: self.state)
        }
    }

    private var centralManager: CBCentralManager
    private var connections: [Gen3SetupBluetoothConnection]

    private var peripheralToConnectCredentials: Gen3SetupPeripheralCredentials?
    private var peripheralToConnect: CBPeripheral?


    private var scanTimeoutWorker: DispatchWorkItem?
    private var scanTimeoutWorkerFactory: DispatchWorkItem {
        get {
            return DispatchWorkItem() {
                [weak self] in

                if let sSelf = self {
                    sSelf.peripheralToConnect = nil
                    sSelf.peripheralToConnectCredentials = nil
                    sSelf.centralManager.stopScan()
                    if (sSelf.state != .Disabled) {
                        sSelf.state = .Ready
                    }
                    sSelf.fail(withReason: .FailedToScanBecauseOfTimeout, severity: .Error)
                }
            }
        }
    }


    required init(delegate: Gen3SetupBluetoothConnectionManagerDelegate) {
        let centralQueue = DispatchQueue(label: "io.particle.gen3", attributes: [])

        self.connections = []
        self.centralManager = CBCentralManager(delegate: nil, queue: centralQueue)
        self.delegate = delegate

        super.init()

        self.centralManager.delegate = self
    }
    
    deinit {
        self.cancelTimeout()
        self.dropAllConnections()
    }

    private func fail(withReason reason: BluetoothConnectionManagerError, severity: Gen3SetupErrorSeverity) {
        log("Bluetooth connection manager error: \(reason)")
        self.delegate.bluetoothConnectionManagerError(sender: self, error: reason, severity: severity)
    }

    private func log(_ message: String) {
        ParticleLogger.logInfo("Gen3SetupBluetoothConnectionManager", format: message, withParameters: getVaList([]))
    }


    func createConnection(with peripheralCredentials: Gen3SetupPeripheralCredentials) {
        if (self.state != .Ready){
            fail(withReason: .FailedToStartScan, severity: .Error)
            return
        }

        self.peripheralToConnectCredentials = peripheralCredentials
        self.scanForPeripherals()
    }

    private func scanForPeripherals() {
        self.state = .Scanning

        log("BluetoothConnectionManager -- scanForPeripherals with services \(Gen3Setup.particleGen3ServiceUUID)")
        let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
        self.centralManager.scanForPeripherals(withServices: [Gen3Setup.particleGen3ServiceUUID], options: options as? [String: AnyObject]) // []

        self.restartTimeout()
    }

    private func cancelTimeout() {
        if let worker = scanTimeoutWorker {
            worker.cancel()
            scanTimeoutWorker = nil
        }
    }
    private func restartTimeout() {
        self.log("Restarting timeout")
        self.cancelTimeout()

        scanTimeoutWorker = scanTimeoutWorkerFactory
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Gen3Setup.bluetoothScanTimeoutValue,
                execute: scanTimeoutWorker!)
    }

    func dropConnection(with connection: Gen3SetupBluetoothConnection) {
        //this will trigger delegate callback for dropped connection
        centralManager.cancelPeripheralConnection(connection.cbPeripheral)
    }

    func dropPeripheralConnection(with peripheral: CBPeripheral) {
        //this will trigger delegate callback for dropped connection
        centralManager.cancelPeripheralConnection(peripheral)
    }


    func dropAllConnections() {
        log("Dropping all BLE connections...")
        for conn in self.connections {
            self.dropConnection(with: conn)
        }
    }

    func stopScan() {
        guard self.state == .Scanning else {
            return
        }

        self.centralManager.stopScan()

        if (self.centralManager.state == .poweredOn) {
            self.state = .Ready
        } else {
            self.state = .Disabled
        }
    }

    //MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var newState: Gen3SetupBluetoothConnectionManagerState = .Disabled

        switch(central.state){
            case .poweredOn:
                newState = .Ready
            case .poweredOff, .resetting, .unauthorized, .unsupported, .unknown:
                newState = .Disabled
        }
        
        log("centralManagerDidUpdateState: \(newState)")
        self.state = newState
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {

        if let n = peripheral.name {
            log("centralManager didDiscover peripheral \(n)")
        } else {
            log("centralManager didDiscover peripheral")
        }

        guard (self.peripheralToConnectCredentials != nil) else {
            return
        }

        if peripheral.name?.lowercased() == self.peripheralToConnectCredentials!.name.lowercased() {
            central.stopScan()
            log("stop scan")

            self.restartTimeout()

            if RSSI.int32Value < -90  {
                self.log("Device too far.. sent warning to user")
                self.fail(withReason: .DeviceTooFar, severity: .Error)
            }

            if peripheral.state == .connected {
                self.fail(withReason: .DeviceWasConnected, severity: .Error)
                self.dropPeripheralConnection(with: peripheral)
            } else {
                self.state = .PeripheralDiscovered
                self.delegate.bluetoothConnectionManagerPeripheralDiscovered(sender: self, peripheral: peripheral)
                self.centralManager.connect(peripheral, options: nil)
                peripheralToConnect = peripheral
                self.log("Pairing to \(peripheral.name!)...")
            }

        }

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let name = peripheral.name {
            log("Paired to: \(name)")
        } else {
            log("Paired to device")
        }

        guard self.peripheralToConnectCredentials != nil, let name = peripheral.name?.lowercased(), name == peripheralToConnectCredentials?.name.lowercased() else {
            //all gen3 devices have names, if peripheral has no name, it's not our device
            dropPeripheralConnection(with: peripheral)
            log("Dropping connection on purpose :(")
            return
        }

        self.restartTimeout()

        //this was only needed, beacuse CBManager would drop connection if we lose all strong references to the device
        self.peripheralToConnect = nil

        let newConnection = Gen3SetupBluetoothConnection(connectedPeripheral: peripheral, credentials: peripheralToConnectCredentials!)
        newConnection.delegate = self

        self.connections.append(newConnection)
        self.delegate.bluetoothConnectionManagerConnectionCreated(sender:self, connection: newConnection)
        self.state = .Ready
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            log("Disconnected from: \(name)")
        } else {
            log("Disconnected from a device")
        }

        for connectionElement in self.connections {
            if connectionElement.cbPeripheral == peripheral {
                self.delegate.bluetoothConnectionManagerConnectionDropped(sender: self, connection: connectionElement)
                let index = self.connections.index(of: connectionElement)
                self.connections.remove(at: index!)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            log("Failed to connect to an unknown device: \(error)")
            return
        }

        if let name = peripheral.name {
            log("Failed to connect to: \(name)")
        } else {
            log("Failed to connect to a device")
        }

        self.fail(withReason: .FailedToConnect, severity: .Error)
    }


    //MARK: Gen3SetupBluetoothConnectionDelegate
    func bluetoothConnectionBecameReady(sender: Gen3SetupBluetoothConnection) {
        log("Bluetooth connection \(sender.peripheralName) became ready")

        self.cancelTimeout()

        self.delegate.bluetoothConnectionManagerConnectionBecameReady(sender: self, connection: sender)
        //at this point connection will be passed to transceiver and transceiver will become data delegate
    }

    func bluetoothConnectionError(sender: Gen3SetupBluetoothConnection, error: BluetoothConnectionError, severity: Gen3SetupErrorSeverity) {
        log("Bluetooth connection \(sender.peripheralName) error, dropping connection:\n\(error)")
        self.dropConnection(with: sender)
    }
}
