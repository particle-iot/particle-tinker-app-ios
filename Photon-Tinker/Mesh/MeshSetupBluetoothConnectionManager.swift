//
// Created by Raimundas Sakalauskas on 23/08/2018.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit
import CoreBluetooth



protocol MeshSetupBluetoothConnectionManagerDelegate {
    func bluetoothConnectionManagerStateChanged(sender: MeshSetupBluetoothConnectionManager, state: MeshSetupBluetoothConnectionManagerState)
    func bluetoothConnectionManagerError(sender: MeshSetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity)

    func bluetoothConnectionManagerPeripheralDiscovered(sender: MeshSetupBluetoothConnectionManager, peripheral: CBPeripheral)
    func bluetoothConnectionManagerConnectionCreated(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection)
    func bluetoothConnectionManagerConnectionBecameReady(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection)
    func bluetoothConnectionManagerConnectionDropped(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection)
}

enum MeshSetupBluetoothConnectionManagerState {
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


class MeshSetupBluetoothConnectionManager: NSObject, CBCentralManagerDelegate, MeshSetupBluetoothConnectionDelegate {

    var delegate: MeshSetupBluetoothConnectionManagerDelegate
    var state: MeshSetupBluetoothConnectionManagerState = .Disabled {
        didSet {
            self.delegate.bluetoothConnectionManagerStateChanged(sender: self, state: self.state)
        }
    }

    private var centralManager: CBCentralManager
    private var connections: [MeshSetupBluetoothConnection]

    private var peripheralToConnectCredentials: MeshSetupPeripheralCredentials?
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


    required init(delegate: MeshSetupBluetoothConnectionManagerDelegate) {
        let centralQueue = DispatchQueue(label: "io.particle.mesh", attributes: [])

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

    private func fail(withReason reason: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity) {
        log("Bluetooth connection manager error: \(reason)")
        self.delegate.bluetoothConnectionManagerError(sender: self, error: reason, severity: severity)
    }

    private func log(_ message: String) {
        ParticleLogger.logInfo("MeshSetupBluetoothConnectionManager", format: message, withParameters: getVaList([]))
    }


    func createConnection(with peripheralCredentials: MeshSetupPeripheralCredentials) {
        if (self.state != .Ready){
            fail(withReason: .FailedToStartScan, severity: .Error)
            return
        }

        self.peripheralToConnectCredentials = peripheralCredentials
        self.scanForPeripherals()
    }

    private func scanForPeripherals() {
        self.state = .Scanning

        log("BluetoothConnectionManager -- scanForPeripherals with services \(MeshSetup.particleMeshServiceUUID)")
        let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
        self.centralManager.scanForPeripherals(withServices: [MeshSetup.particleMeshServiceUUID], options: options as? [String: AnyObject]) // []

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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + MeshSetup.bluetoothScanTimeoutValue,
                execute: scanTimeoutWorker!)
    }

    func dropConnection(with connection: MeshSetupBluetoothConnection) {
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
        var newState: MeshSetupBluetoothConnectionManagerState = .Disabled

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

        if peripheral.name == self.peripheralToConnectCredentials!.name {
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

        guard self.peripheralToConnectCredentials != nil, let name = peripheral.name, name == peripheralToConnectCredentials?.name else {
            //all mesh devices have names, if peripheral has no name, it's not our device
            dropPeripheralConnection(with: peripheral)
            log("Dropping connection on purpose :(")
            return
        }

        self.restartTimeout()

        //this was only needed, beacuse CBManager would drop connection if we lose all strong references to the device
        self.peripheralToConnect = nil

        let newConnection = MeshSetupBluetoothConnection(connectedPeripheral: peripheral, credentials: peripheralToConnectCredentials!)
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


    //MARK: MeshSetupBluetoothConnectionDelegate
    func bluetoothConnectionBecameReady(sender: MeshSetupBluetoothConnection) {
        log("Bluetooth connection \(sender.peripheralName) became ready")

        self.cancelTimeout()

        self.delegate.bluetoothConnectionManagerConnectionBecameReady(sender: self, connection: sender)
        //at this point connection will be passed to transceiver and transceiver will become data delegate
    }

    func bluetoothConnectionError(sender: MeshSetupBluetoothConnection, error: BluetoothConnectionError, severity: MeshSetupErrorSeverity) {
        log("Bluetooth connection \(sender.peripheralName) error, dropping connection:\n\(error)")
        self.dropConnection(with: sender)
    }
}
