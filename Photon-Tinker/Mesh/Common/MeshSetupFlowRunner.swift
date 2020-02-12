//
// Created by Raimundas Sakalauskas on 2019-03-21.
// Copyright (c) 2019 Particle. All rights reserved.
//

//
// Created by Raimundas Sakalauskas on 2019-03-01.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation
import CoreBluetooth


class Gen3SetupFlowRunner : Gen3SetupBluetoothConnectionManagerDelegate, Gen3SetupStepDelegate {

    internal var context: Gen3SetupContext

    internal var currentFlow: [Gen3SetupStep]?
    internal var currentStepIdx: Int = 0
    internal var currentStep: Gen3SetupStep? {
        if let currentFlow = currentFlow {
            return currentFlow[currentStepIdx]
        }
        return nil
    }


    init(delegate: Gen3SetupFlowRunnerDelegate, context: Gen3SetupContext? = nil) {
        if (context == nil) {
            self.context = Gen3SetupContext()
            self.context.bluetoothManager = Gen3SetupBluetoothConnectionManager(delegate: self)
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
    internal func rewindTo(step: Gen3SetupStep.Type, runStep: Bool = true) -> Gen3SetupFlowError? {

        currentStep!.rewindFrom()

        guard let currentFlow = self.currentFlow else {
            return .IllegalOperation
        }

        for i in 0 ..< currentFlow.count {
            if (currentFlow[i].isKind(of: step)) {
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
        ParticleLogger.logInfo("Gen3SetupFlowRunner", format: message, withParameters: getVaList([]))
    }

    internal func fail(withReason reason: Gen3SetupFlowError, severity: Gen3SetupErrorSeverity = .Error, nsError: Error? = nil) {
        if context.canceled == false {
            if (severity == .Fatal) {
                self.cancelSetup()
            }

            self.log("error: \(reason.description), nsError: \(nsError?.localizedDescription as Optional)")
            context.delegate.gen3SetupError(self.currentStep!, error: reason, severity: severity, nsError: nsError)
        }
    }


    internal func runCurrentStep() {
        if (context.canceled) {
            return
        }

        guard let currentFlow = self.currentFlow else {
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
    func setTargetDeviceInfo(dataMatrix: Gen3SetupDataMatrix) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetTargetDeviceInfo.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetTargetDeviceInfo)?.setTargetDeviceInfo(dataMatrix: dataMatrix)
    }

    func setTargetUseEthernet(useEthernet: Bool) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureCorrectEthernetFeatureStatus.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepEnsureCorrectEthernetFeatureStatus)?.setTargetUseEthernet(useEthernet: useEthernet)
    }

    func setTargetSimStatus(simActive: Bool) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureCorrectSimState.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepEnsureCorrectSimState)?.setTargetSimStatus(simActive: simActive)
    }

    func setSimDataLimit(dataLimit: Int) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepSetSimDataLimit.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepSetSimDataLimit)?.setSimDataLimit(dataLimit: dataLimit)
    }



    func setTargetPerformFirmwareUpdate(update: Bool) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureLatestFirmware.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepEnsureLatestFirmware)?.setTargetPerformFirmwareUpdate(update: update)
    }

    func setTargetDeviceLeaveNetwork(leave: Bool) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureNotOnMeshNetwork.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepEnsureNotOnMeshNetwork)?.setTargetDeviceLeaveNetwork(leave: leave)
    }

    func setSwitchToControlPanel(switchToCP: Bool) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepOfferToSwitchToControlPanel.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepOfferToSwitchToControlPanel)?.setSwitchToControlPanel(switchToCP: switchToCP)
    }


    func setSelectStandAloneOrMeshSetup(meshSetup: Bool) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepOfferSetupStandAloneOrWithNetwork.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepOfferSetupStandAloneOrWithNetwork)?.setSelectStandAloneOrMeshSetup(meshSetup: meshSetup)
    }

    func setOptionalSelectedNetwork(selectedNetworkExtPanID: String?) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepOfferSelectOrCreateNetwork.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepOfferSelectOrCreateNetwork)?.setOptionalSelectedNetwork(selectedNetworkExtPanID: selectedNetworkExtPanID)
    }

    func setPricingImpactDone() -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepShowPricingImpact.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepShowPricingImpact)?.setPricingImpactDone()
    }

    func setInfoDone() -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepShowInfo.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepShowInfo)?.setInfoDone()
    }

    func setDeviceName(name: String, onComplete:@escaping (Gen3SetupFlowError?) -> ()) {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetNewDeviceName.self else {
            onComplete(.IllegalOperation)
            return
        }

        (currentStep as? StepGetNewDeviceName)?.setDeviceName(name: name, onComplete: onComplete)
    }

    func setAddOneMoreDevice(addOneMoreDevice: Bool) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepOfferToAddOneMoreDevice.self else {
            return .IllegalOperation
        }

        return nil
    }


    func setNewNetworkName(name: String) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetNewNetworkName.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetNewNetworkName)?.setNewNetworkName(name: name)
    }


    func setNewNetworkPassword(password: String) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetNewNetworkPassword.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetNewNetworkPassword)?.setNewNetworkPassword(password: password)
    }

    func setSelectedWifiNetworkPassword(_ password: String, onComplete:@escaping (Gen3SetupFlowError?) -> ()) {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureCorrectSelectedWifiNetworkPassword.self else {
            onComplete(.IllegalOperation)
            return
        }

        (currentStep as? StepEnsureCorrectSelectedWifiNetworkPassword)?.setSelectedWifiNetworkPassword(password, onComplete: onComplete)
    }

    func setSelectedWifiNetwork(selectedNetwork: Gen3SetupNewWifiNetworkInfo) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetUserWifiNetworkSelection.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetUserWifiNetworkSelection)?.setSelectedWifiNetwork(selectedNetwork: selectedNetwork)
    }

    func setSelectedNetwork(selectedNetworkExtPanID: String) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetUserNetworkSelection.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetUserNetworkSelection)?.setSelectedNetwork(selectedNetworkExtPanID: selectedNetworkExtPanID)
    }

    func setCommissionerDeviceInfo(dataMatrix: Gen3SetupDataMatrix) -> Gen3SetupFlowError? {
        guard let currentStep = currentStep, type(of: currentStep) == StepGetCommissionerDeviceInfo.self else {
            return .IllegalOperation
        }

        return (currentStep as? StepGetCommissionerDeviceInfo)?.setCommissionerDeviceInfo(dataMatrix: dataMatrix)

    }

    func setSelectedNetworkPassword(_ password: String, onComplete:@escaping (Gen3SetupFlowError?) -> ()) {
        guard let currentStep = currentStep, type(of: currentStep) == StepEnsureCorrectSelectedNetworkPassword.self else {
            onComplete(.IllegalOperation)
            return
        }

        (currentStep as? StepEnsureCorrectSelectedNetworkPassword)?.setSelectedNetworkPassword(password, onComplete: onComplete)
    }

    func rescanNetworks() -> Gen3SetupFlowError? {
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
    internal func bluetoothConnectionManagerStateChanged(sender: Gen3SetupBluetoothConnectionManager, state: Gen3SetupBluetoothConnectionManagerState) {
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

    internal func bluetoothConnectionManagerError(sender: Gen3SetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: Gen3SetupErrorSeverity) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerError = \(error), severity = \(severity)")
        if let currentStep = currentStep, !currentStep.handleBluetoothConnectionManagerError(error) {
            self.fail(withReason: .BluetoothError, severity: .Fatal)
        }
    }

    internal func bluetoothConnectionManagerConnectionCreated(sender: Gen3SetupBluetoothConnectionManager, connection: Gen3SetupBluetoothConnection) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerConnectionCreated = \(connection)")

        if let currentStep = currentStep, !currentStep.handleBluetoothConnectionManagerConnectionCreated(connection) {
            //do nothing
        }
    }

    internal func bluetoothConnectionManagerPeripheralDiscovered(sender: Gen3SetupBluetoothConnectionManager, peripheral: CBPeripheral) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerPeripheralDiscovered = \(peripheral)")

        if let currentStep = currentStep, !currentStep.handleBluetoothConnectionManagerPeripheralDiscovered(peripheral) {
            //do nothing
        }
    }

    internal func bluetoothConnectionManagerConnectionBecameReady(sender: Gen3SetupBluetoothConnectionManager, connection: Gen3SetupBluetoothConnection) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerConnectionBecameReady = \(connection)")

        if let currentStep = currentStep, !currentStep.handleBluetoothConnectionManagerConnectionBecameReady(connection) {
            //do nothing
        }
    }

    internal func bluetoothConnectionManagerConnectionDropped(sender: Gen3SetupBluetoothConnectionManager, connection: Gen3SetupBluetoothConnection) {
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


    //MARK: Gen3SetupStepDelegate
    internal func rewindTo(_ sender: Gen3SetupStep, step: Gen3SetupStep.Type, runStep: Bool = true) -> Gen3SetupStep {
        if let error = self.rewindTo(step: step, runStep: runStep) {
            fatalError("flow tried to perform illegal back")
        } else {
            return self.currentStep!
        }
    }

    internal func fail(_ sender: Gen3SetupStep, withReason reason: Gen3SetupFlowError, severity: Gen3SetupErrorSeverity, nsError: Error?) {
        self.fail(withReason: reason, severity: severity, nsError: nsError)
    }

    internal func stepCompleted(_ sender: Gen3SetupStep) {
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
