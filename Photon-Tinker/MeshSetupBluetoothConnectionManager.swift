//
//  NORBluetoothManager.swift
//  nRF Toolbox
//  Particle
//
//  Created by Mostafa Berg on 06/05/16.
//  Maintained by Raimundas Sakalauskas
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth



protocol MeshSetupBluetoothConnectionManagerDelegate {
    func bluetoothConnectionManagerStateChanged(sender: MeshSetupBluetoothConnectionManager, state: MeshSetupBluetoothConnectionManagerState)
    func bluetoothConnectionManagerError(sender: MeshSetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity)

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
    case DeviceWasConnected //TODO: need to reconnect to the device
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

    private lazy var scanTimeoutWorker: DispatchWorkItem  = DispatchWorkItem() {
        [weak self] in

        if let sSelf = self {
            sSelf.centralManager.stopScan()
            sSelf.fail(withReason: .FailedToScanBecauseOfTimeout, severity: .Error)
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
        scanTimeoutWorker.cancel()
        self.dropAllConnections()
    }

    private func fail(withReason reason: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity) {
        self.delegate.bluetoothConnectionManagerError(sender: self, error: reason, severity: severity)
        log("Bluetooth connection manager error: \(reason)")
    }

    private func log(_ message: String) {
        if (MeshSetup.LogBluetoothConnectionManager) {
            NSLog("MeshSetupBluetoothConnectionManager: \(message)")
        }
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

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + MeshSetup.bluetoothScanTimeoutValue,
                execute: scanTimeoutWorker)
    }

    func dropConnection(with connection: MeshSetupBluetoothConnection) {
        //this will trigger delegate callback for dropped connection
        centralManager.cancelPeripheralConnection(connection.cbPeripheral)
    }

    func dropConnection(with connection: CBPeripheral) {
        //this will trigger delegate callback for dropped connection
        centralManager.cancelPeripheralConnection(connection)
    }


    func dropAllConnections() {
        log("Dropping all BLE connections...")
        for conn in self.connections {
            self.dropConnection(with: conn)
        }
    }

    func stopScan(completed: @escaping () -> ()) {
        guard self.state == .Scanning else {
            return
        }

        self.centralManager.stopScan()

        if (self.centralManager.state == .poweredOn) {
            self.state = .Ready
        } else {
            self.state = .Disabled
        }

        //stopScan takes some time
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: DispatchWorkItem (block: completed))
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

        if peripheral.name == self.peripheralToConnectCredentials!.name {
            central.stopScan()
            log("stop scan")

            scanTimeoutWorker.cancel()

            if RSSI.int32Value < -90  {
                NSLog("Device too far.. sent warning to user")
                self.fail(withReason: .DeviceTooFar, severity: .Warning)
            }

            if peripheral.state == .connected {
                self.fail(withReason: .DeviceWasConnected, severity: .Warning)
                self.dropConnection(with: peripheral)
            } else {
                self.state = .PeripheralDiscovered
                self.centralManager.connect(peripheral, options: nil)
                peripheralToConnect = peripheral
                log("Pairing to \(peripheral.name!)...")
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
            return
        }

        //this was only needed, beacuse CBManager would drop connection if we lose all strong references to the device
        self.peripheralToConnect = nil

        let newConnection = MeshSetupBluetoothConnection(connectedPeripheral: peripheral, credentials: peripheralToConnectCredentials!)
        newConnection.delegate = self

        self.connections.append(newConnection)
        self.delegate.bluetoothConnectionManagerConnectionCreated(sender:self, connection: newConnection)
        self.state = .Ready
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            log("Failed to disconnect from to an unknown device: \(error)")
            return
        }

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
        self.delegate.bluetoothConnectionManagerConnectionBecameReady(sender: self, connection: sender)
        //at this point connection will be passed to transceiver and transceiver will become data delegate
    }

    func bluetoothConnectionError(sender: MeshSetupBluetoothConnection, error: BluetoothConnectionError, severity: MeshSetupErrorSeverity) {
        log("Bluetooth connection \(sender.peripheralName) error, dropping connection:\n\(error)")
        self.dropConnection(with: sender)
    }
}
