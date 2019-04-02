//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation
import CoreBluetooth

class StepConnectToTargetDevice: MeshSetupStep {

    var reconnect: Bool = false
    var reconnectAfterForcedReboot: Bool = false
    var reconnectAfterForcedRebootRetry: Int = 0

    override func start() {
        guard let context = self.context else {
            return
        }

        if (context.targetDevice.transceiver == nil) {
            if (context.bluetoothManager.state != .Ready) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    self.fail(withReason: .BluetoothDisabled)
                }
                return
            }

            self.log("connecting to device: \(context.targetDevice.credentials!)")

            context.bluetoothManager.createConnection(with: context.targetDevice.credentials!)
            if (!self.reconnectAfterForcedReboot) {
                context.delegate.meshSetupDidEnterState(self, state: .TargetDeviceConnecting)
            }
        } else {
            self.stepCompleted()
        }
    }

    override func reset() {
        self.reconnect = false

        self.reconnectAfterForcedReboot = false
        self.reconnectAfterForcedRebootRetry = 0

        self.context?.bluetoothManager.stopScan()
    }

    private func targetDeviceConnected(connection: MeshSetupBluetoothConnection) {
        guard let context = self.context else {
            return
        }

        context.targetDevice.isListeningMode = true
        context.targetDevice.transceiver = MeshSetupProtocolTransceiver(connection: connection)

        self.stepCompleted()
    }

    override func handleBluetoothConnectionManagerError(_ error: BluetoothConnectionManagerError) -> Bool {
            if (error == .DeviceWasConnected) {
                self.reconnect = true
                //this will be used in connection dropped to restart the step
            } else if (error == .DeviceTooFar) {
                self.fail(withReason: .DeviceTooFar)
                //after showing promt, step should be repeated
            } else if (error == .FailedToScanBecauseOfTimeout && self.reconnectAfterForcedReboot) {
                if (self.reconnectAfterForcedRebootRetry < 4) {
                    self.reconnectAfterForcedRebootRetry += 1

                    //coming online after a flash might take a while, if for some reason we timeout, we should retry the step
                    self.start()
                } else {
                    //this is taking way too long.
                    self.fail(withReason: .FailedToFlashBecauseOfTimeout)
                }
            } else {
                if (error == .FailedToStartScan) {
                    self.fail(withReason: .FailedToStartScan)
                } else if (error == .FailedToScanBecauseOfTimeout) {
                    self.fail(withReason: .FailedToScanBecauseOfTimeout)
                } else { //FailedToConnect
                    self.fail(withReason: .FailedToConnect)
                }
            }

        return true
    }

    override func handleBluetoothConnectionManagerConnectionCreated(_ connection: MeshSetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        if (!self.reconnectAfterForcedReboot) {
            context.delegate.meshSetupDidEnterState(self, state: .TargetDeviceConnected)
        }

        return true
    }

    override func handleBluetoothConnectionManagerPeripheralDiscovered(_ peripheral: CBPeripheral) -> Bool {
        guard let context = self.context else {
            return false
        }

        if (peripheral.name == context.targetDevice.credentials!.name) {
            if (!self.reconnectAfterForcedReboot) {
                context.delegate.meshSetupDidEnterState(self, state: .TargetDeviceDiscovered)
            }
        }

        return true
    }

    override func handleBluetoothConnectionManagerConnectionBecameReady(_ connection: MeshSetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        if (!self.reconnectAfterForcedReboot) {
            context.delegate.meshSetupDidEnterState(self, state: .TargetDeviceReady)
        }

        targetDeviceConnected(connection: connection)

        return true
    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: MeshSetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        if (reconnect) {
            reconnect = false
            start()
        }

        return true
    }
}

