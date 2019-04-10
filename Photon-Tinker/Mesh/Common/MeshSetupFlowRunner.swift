//
// Created by Raimundas Sakalauskas on 2019-03-21.
// Copyright (c) 2019 spark. All rights reserved.
//

//
// Created by Raimundas Sakalauskas on 2019-03-01.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation
import CoreBluetooth


class MeshSetupFlowRunner : MeshSetupBluetoothConnectionManagerDelegate, MeshSetupStepDelegate {

    internal var context: MeshSetupContext

    internal var currentFlow: [MeshSetupStep]!
    internal var currentStepIdx: Int = 0
    internal var currentStep: MeshSetupStep? {
        if let currentFlow = currentFlow {
            return currentFlow[currentStepIdx]
        }
        return nil
    }


    init(delegate: MeshSetupFlowRunnerDelegate, context: MeshSetupContext? = nil) {
        if (context == nil) {
            self.context = MeshSetupContext()
            self.context.bluetoothManager = MeshSetupBluetoothConnectionManager(delegate: self)
        } else {
            self.context = context!
        }

        self.context.delegate = delegate
        self.context.stepDelegate = self
    }

    //MARK: public interface
    func pauseSetup() {
        context.paused = true
    }

    func continueSetup() {
        if (context.paused) {
            context.paused = false
            self.runCurrentStep()
        }
    }

    func cancelSetup() {
        context.canceled = true

        context.bluetoothManager.stopScan()
        context.bluetoothManager.dropAllConnections()
    }

    internal func finishSetup() {
        context.canceled = true

        context.bluetoothManager.stopScan()
        context.bluetoothManager.dropAllConnections()
    }


    //this is for internal use only, because it requires a lot of internal knowledge to use and is nearly impossible to expose to external developers
    internal func rewindTo(step: MeshSetupStep.Type, runStep: Bool = true) -> MeshSetupFlowError? {

        currentStep!.rewindFrom()

        for i in 0 ..< self.currentFlow.count {
            if (self.currentFlow[i].isKind(of: step)) {
                if (i >= self.currentStepIdx) {
                    //trying to "rewind" forward
                    return .IllegalOperation
                }

                self.currentStepIdx = i
                self.log("returning to step: \(self.currentStepIdx)")
                self.currentStep!.rewindTo(context: self.context)
                if (runStep) {
                    self.runCurrentStep()
                }

                return nil
            }
        }

        return .IllegalOperation
    }

    func retryLastAction() {
        self.log("Retrying action: \(self.currentStep!)")
        self.currentStep!.retry()
    }


    internal func log(_ message: String) {
        ParticleLogger.logInfo("MeshSetupFlowRunner", format: message, withParameters: getVaList([]))
    }

    internal func fail(withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity = .Error, nsError: Error? = nil) {
        if context.canceled == false {
            if (severity == .Fatal) {
                self.cancelSetup()
            }

            self.log("error: \(reason.description), nsError: \(nsError?.localizedDescription as Optional)")
            context.delegate.meshSetupError(self.currentStep!, error: reason, severity: severity, nsError: nsError)
        }
    }


    internal func runCurrentStep() {
        if (context.canceled) {
            return
        }

        //if we reached the end of current flow
        if (currentStepIdx == currentFlow.count) {
            self.switchFlow()
        }

        log("stepComplete\n\n" +
                "--------------------------------------------------------------------------------------------\n" +
                "currentStepIdx = \(currentStepIdx), currentStep = \(currentStep)")

        self.currentStep?.reset()
        self.currentStep?.run(context: self.context)
    }

    internal func switchFlow() {
        fatalError("not implemented")
    }



    //MARK: Delegate responses
    func setTargetDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetTargetDeviceInfo.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetTargetDeviceInfo)?.setTargetDeviceInfo(dataMatrix: dataMatrix)
    }

    func setTargetUseEthernet(useEthernet: Bool) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureCorrectEthernetFeatureStatus.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepEnsureCorrectEthernetFeatureStatus)?.setTargetUseEthernet(useEthernet: useEthernet)
    }

    func setTargetSimStatus(simActive: Bool) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureCorrectSimState.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepEnsureCorrectSimState)?.setTargetSimStatus(simActive: simActive)
    }

    func setSimDataLimit(dataLimit: Int) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepSetSimDataLimit.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepSetSimDataLimit)?.setSimDataLimit(dataLimit: dataLimit)
    }



    func setTargetPerformFirmwareUpdate(update: Bool) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureLatestFirmware.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepEnsureLatestFirmware)?.setTargetPerformFirmwareUpdate(update: update)
    }

    func setTargetDeviceLeaveNetwork(leave: Bool) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureNotOnMeshNetwork.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepEnsureNotOnMeshNetwork)?.setTargetDeviceLeaveNetwork(leave: leave)
    }

    func setSwitchToControlPanel(switchToCP: Bool) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepOfferToSwitchToControlPanel.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepOfferToSwitchToControlPanel)?.setSwitchToControlPanel(switchToCP: switchToCP)
    }


    func setSelectStandAloneOrMeshSetup(meshSetup: Bool) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepOfferSetupStandAloneOrWithNetwork.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepOfferSetupStandAloneOrWithNetwork)?.setSelectStandAloneOrMeshSetup(meshSetup: meshSetup)
    }

    func setOptionalSelectedNetwork(selectedNetworkExtPanID: String?) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepOfferSelectOrCreateNetwork.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepOfferSelectOrCreateNetwork)?.setOptionalSelectedNetwork(selectedNetworkExtPanID: selectedNetworkExtPanID)
    }

    func setPricingImpactDone() -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepShowPricingImpact.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepShowPricingImpact)?.setPricingImpactDone()
    }

    func setInfoDone() -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepShowInfo.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepShowInfo)?.setInfoDone()
    }

    func setDeviceName(name: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetNewDeviceName.self else {
            onComplete(.IllegalOperation)
            return
        }

        (currentStep as? StepGetNewDeviceName)?.setDeviceName(name: name, onComplete: onComplete)
    }

    func setAddOneMoreDevice(addOneMoreDevice: Bool) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepOfferToAddOneMoreDevice.self else {
            return .IllegalOperation
        }

        return nil
    }


    func setNewNetworkName(name: String) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetNewNetworkName.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetNewNetworkName)?.setNewNetworkName(name: name)
    }


    func setNewNetworkPassword(password: String) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetNewNetworkPassword.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetNewNetworkPassword)?.setNewNetworkPassword(password: password)
    }

    func setSelectedWifiNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureCorrectSelectedWifiNetworkPassword.self else {
            onComplete(.IllegalOperation)
            return
        }

        (currentStep as? StepEnsureCorrectSelectedWifiNetworkPassword)?.setSelectedWifiNetworkPassword(password, onComplete: onComplete)
    }

    func setSelectedWifiNetwork(selectedNetwork: MeshSetupNewWifiNetworkInfo) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetUserWifiNetworkSelection.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetUserWifiNetworkSelection)?.setSelectedWifiNetwork(selectedNetwork: selectedNetwork)
    }

    func setSelectedNetwork(selectedNetworkExtPanID: String) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetUserNetworkSelection.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetUserNetworkSelection)?.setSelectedNetwork(selectedNetworkExtPanID: selectedNetworkExtPanID)
    }

    func setCommissionerDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetCommissionerDeviceInfo.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetCommissionerDeviceInfo)?.setCommissionerDeviceInfo(dataMatrix: dataMatrix)

    }

    func setSelectedNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureCorrectSelectedNetworkPassword.self else {
            onComplete(.IllegalOperation)
            return
        }

        (currentStep as? StepEnsureCorrectSelectedNetworkPassword)?.setSelectedNetworkPassword(password, onComplete: onComplete)
    }

    func rescanNetworks() -> MeshSetupFlowError? {
        guard let currentStep = currentStep else {
            return .IllegalOperation
        }

        if (type(of: currentStep) == StepOfferSelectOrCreateNetwork.self) {
            (currentStep as! StepOfferSelectOrCreateNetwork).scanNetworks()
        } else if (type(of: currentStep) == StepGetUserNetworkSelection.self) {
            (currentStep as! StepGetUserNetworkSelection).scanNetworks()
        } else if (type(of: currentStep) == StepGetUserWifiNetworkSelection.self) {
            (currentStep as! StepGetUserWifiNetworkSelection).scanWifiNetworks()
        } else {
            return .IllegalOperation
        }

        return nil
    }

    //MARK: BluetoothConnectionManagerDelegate
    internal func bluetoothConnectionManagerStateChanged(sender: MeshSetupBluetoothConnectionManager, state: MeshSetupBluetoothConnectionManagerState) {
        if (context.canceled) {
            return
        }

        self.log("bluetoothConnectionManagerStateChanged = \(state)")
        if (context.bluetoothManager.state == .Ready) {
            context.bluetoothReady = true
        } else if (context.bluetoothManager.state == .Disabled) {
            context.bluetoothReady = false

            //if we are waiting for the reply = trigger timeout
            if let targetDeviceTransceiver = context.targetDevice.transceiver {
                targetDeviceTransceiver.triggerTimeout()
            }

            //if we are waiting for the reply = trigger timeout
            if let commissionerDeviceTransceiver = context.commissionerDevice?.transceiver {
                commissionerDeviceTransceiver.triggerTimeout()
            }
        }
    }

    internal func bluetoothConnectionManagerError(sender: MeshSetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerError = \(error), severity = \(severity)")
        if let currentStep = currentStep, !currentStep.handleBluetoothConnectionManagerError(error) {
            self.fail(withReason: .BluetoothError, severity: .Fatal)
        }
    }

    internal func bluetoothConnectionManagerConnectionCreated(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerConnectionCreated = \(connection)")

        if let currentStep = currentStep, !currentStep.handleBluetoothConnectionManagerConnectionCreated(connection) {
            //do nothing
        }
    }

    internal func bluetoothConnectionManagerPeripheralDiscovered(sender: MeshSetupBluetoothConnectionManager, peripheral: CBPeripheral) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerPeripheralDiscovered = \(peripheral)")

        if let currentStep = currentStep, !currentStep.handleBluetoothConnectionManagerPeripheralDiscovered(peripheral) {
            //do nothing
        }
    }

    internal func bluetoothConnectionManagerConnectionBecameReady(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerConnectionBecameReady = \(connection)")

        if let currentStep = currentStep, !currentStep.handleBluetoothConnectionManagerConnectionBecameReady(connection) {
            //do nothing
        }
    }

    internal func bluetoothConnectionManagerConnectionDropped(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerConnectionDropped = \(connection)")

        if (connection == context.targetDevice.transceiver?.connection || connection == context.commissionerDevice?.transceiver?.connection) {
            if (connection == context.targetDevice.transceiver?.connection) {
                context.targetDevice.transceiver = nil
            }

            if (connection == context.commissionerDevice?.transceiver?.connection) {
                context.commissionerDevice?.transceiver = nil
            }

            if let currentStep = currentStep, !currentStep.handleBluetoothConnectionManagerConnectionDropped(connection) {
                self.fail(withReason: .BluetoothConnectionDropped, severity: .Fatal)
            }
        }
        //if some other connection was dropped - we dont care
    }


    //MARK: MeshSetupStepDelegate
    internal func rewindTo(_ sender: MeshSetupStep, step: MeshSetupStep.Type, runStep: Bool = true) -> MeshSetupStep {
        if let error = self.rewindTo(step: step, runStep: runStep) {
            fatalError("flow tried to perform illegal back")
        } else {
            return self.currentStep!
        }
    }

    internal func fail(_ sender: MeshSetupStep, withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?) {
        self.fail(withReason: reason, severity: severity, nsError: nsError)
    }

    internal func stepCompleted(_ sender: MeshSetupStep) {
        if (context.canceled) {
            return
        }

        if type(of: sender) != type(of: currentStep!) {
            self.log("Flow order is broken :(. Current command: \(self.currentStep!), Parameter command: \(sender)")
            self.log("Stack:\n\(Thread.callStackSymbols.joined(separator: "\n"))")
            self.fail(withReason: .CriticalFlowError, severity: .Fatal)
        }

        self.currentStepIdx += 1

        if (context.paused) {
            return
        }

        self.runCurrentStep()
    }
}
