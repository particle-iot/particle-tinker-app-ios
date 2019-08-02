//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation
import CoreBluetooth

class StepConnectToCommissionerDevice: MeshSetupStep {

    private var reconnect: Bool = false

    var reconnectAfterForcedReboot: Bool = false
    var reconnectAfterForcedRebootRetry: Int = 0

    override func start() {
        guard let context = self.context else {
            return
        }


        if (context.commissionerDevice?.transceiver == nil) {
            if (context.bluetoothManager.state != .Ready) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    self.fail(withReason: .BluetoothDisabled)
                }
                return
            }

            self.log("connecting to device: \(context.commissionerDevice!.credentials!)")
            context.bluetoothManager.createConnection(with: context.commissionerDevice!.credentials!)
            context.delegate.meshSetupDidEnterState(self, state: .CommissionerDeviceConnected)
        } else if (context.commissionerDevice?.isListeningMode == nil || context.commissionerDevice?.isListeningMode! == true) {
            self.stopCommissionerDeviceListening()
        } else {
            self.stepCompleted()
        }
    }

    override func reset() {
        reconnect = false

        self.reconnectAfterForcedReboot = false
        self.reconnectAfterForcedRebootRetry = 0
    }

    private func commissionerDeviceConnected(connection: MeshSetupBluetoothConnection) {
        guard let context = self.context else {
            return
        }

        context.commissionerDevice!.isListeningMode = true
        context.commissionerDevice!.transceiver = MeshSetupProtocolTransceiver(connection: connection)

        self.start()
    }

    private func stopCommissionerDeviceListening() {
        context?.commissionerDevice?.transceiver!.sendStopListening { [weak self, weak context] result in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("commissionerDevice.sendStopListening: \(result.description())")

            if (context.canceled) {
                return
            }

            if (result == .NONE) {
                context.commissionerDevice?.isListeningMode = false
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
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



    override func handleBluetoothConnectionManagerConnectionCreated(_ connection: MeshSetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        context.commissionerDevice?.state = .connected
        context.delegate.meshSetupDidEnterState(self, state: .CommissionerDeviceConnected)

        return true
    }

    override func handleBluetoothConnectionManagerPeripheralDiscovered(_ peripheral: CBPeripheral) -> Bool {
        guard let context = self.context else {
            return false
        }

        context.commissionerDevice?.state = .discovered
        context.delegate.meshSetupDidEnterState(self, state: .CommissionerDeviceDiscovered)

        return true
    }

    override func handleBluetoothConnectionManagerConnectionBecameReady(_ connection: MeshSetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        context.commissionerDevice?.state = .ready
        context.delegate.meshSetupDidEnterState(self, state: .CommissionerDeviceReady)

        commissionerDeviceConnected(connection: connection)

        return true
    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: MeshSetupBluetoothConnection) -> Bool {
        guard let context = self.context else {
            return false
        }

        context.commissionerDevice?.state = .credentialsSet

        if (reconnect) {
            reconnect = false
            start()
        }

        return true
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.commissionerDevice?.state = .credentialsSet
    }
}
