//
// Created by Raimundas Sakalauskas on 2019-03-02.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepConnectToCommissionerDevice: MeshSetupStep {

    private var reconnect: Bool = false

    override func start() {
        if (context.commissionerDevice?.transceiver != nil) {
            self.stepCompleted()
            return
        }

        if (context.bluetoothManager.state != .Ready) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.fail(withReason: .BluetoothDisabled)
            }
            return
        }

        self.log("connecting to device: \(context.commissionerDevice!.credentials!)")
        context.bluetoothManager.createConnection(with: context.commissionerDevice!.credentials!)
        context.delegate.meshSetupDidEnterState(state: .CommissionerDeviceConnected)
    }

    private func commissionerDeviceConnected(connection: MeshSetupBluetoothConnection) {
        context.commissionerDevice!.transceiver = MeshSetupProtocolTransceiver(connection: connection)

        self.stepCompleted()
    }

    override func handleBluetoothConnectionManagerConnectionCreated(_ connection: MeshSetupBluetoothConnection) -> Bool {
        context.delegate.meshSetupDidEnterState(state: .CommissionerDeviceConnected)
        return true
    }

    override func handleBluetoothConnectionManagerConnectionBecameReady(_ connection: MeshSetupBluetoothConnection) -> Bool {
        context.delegate.meshSetupDidEnterState(state: .CommissionerDeviceReady)
        commissionerDeviceConnected(connection: connection)
        return true
    }

    override func handleBluetoothConnectionManagerConnectionDropped(_ connection: MeshSetupBluetoothConnection) -> Bool {
        if (reconnect) {
            reconnect = false
            start()
        }
        return true
    }
}
