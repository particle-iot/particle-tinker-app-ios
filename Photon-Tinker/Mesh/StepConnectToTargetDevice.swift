//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation
import CoreBluetooth

class StepConnectToTargetDevice: Gen3SetupStep {

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
                context.delegate.gen3SetupDidEnterState(self, state: .TargetDeviceConnecting)
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

    private func targetDeviceConnected(connection: Gen3SetupBluetoothConnection) {
        guard let context = self.context else {
            return
        }

        context.targetDevice.isListeningMode = true
        context.targetDevice.transceiver = Gen3SetupProtocolTransceiver(connection: connection)

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
                    if let context = self.context, context.targetDevice.state == .connected {
                        self.fail(withReason: .FailedToHandshakeBecauseOfTimeout, severity: .Fatal)
                    } else {
                        self.fail(withReason: .FailedToScanBecauseOfTimeout)
                    }
                } else { //FailedToConnect
                    self.fail(withReason: .FailedToConnect)
                }
            }

        return true
    }

    override func handleBluetoothConnectionManagerConnectionCreated(_ connection: Gen3SetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        context.targetDevice.state = .connected

        if (!self.reconnectAfterForcedReboot) {
            context.delegate.gen3SetupDidEnterState(self, state: .TargetDeviceConnected)
        }

        return true
    }

    override func handleBluetoothConnectionManagerPeripheralDiscovered(_ peripheral: CBPeripheral) -> Bool {
        guard let context = self.context else {
            return false
        }

        context.targetDevice.state = .discovered

        if (peripheral.name?.lowercased() == context.targetDevice.credentials!.name.lowercased() || peripheral.identifier == context.targetDevice.credentials!.identifier) {
            if (!self.reconnectAfterForcedReboot) {
                context.delegate.gen3SetupDidEnterState(self, state: .TargetDeviceDiscovered)
            }
        }

        return true
    }

    override func handleBluetoothConnectionManagerConnectionBecameReady(_ connection: Gen3SetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        context.targetDevice.state = .ready

        if (!self.reconnectAfterForcedReboot) {
            context.delegate.gen3SetupDidEnterState(self, state: .TargetDeviceReady)
        }

        targetDeviceConnected(connection: connection)

        return true
    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: Gen3SetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        context.targetDevice.state = .credentialsSet

        if (reconnect) {
            reconnect = false
            start()
        }

        return true
    }

    override func rewindTo(context: Gen3SetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.targetDevice.state = .credentialsSet
    }
}

