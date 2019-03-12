//
// Created by Raimundas Sakalauskas on 2019-03-01.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation


class MeshSetupFlowManager: NSObject, MeshSetupBluetoothConnectionManagerDelegate, MeshSetupStepDelegate, MeshSetupFlowManagerDelegateResponseConsumer {


    private let preflow:[MeshSetupStep] = [
        StepGetTargetDeviceInfo(),
        StepConnectToTargetDevice(),
        StepEnsureCorrectEthernetFeatureStatus(),
        StepEnsureLatestFirmware(),
        StepGetAPINetworks(),
        StepEnsureTargetDeviceCanBeClaimed(),
        StepEnsureTargetDeviceIsNotOnMeshNetwork(),
        SetClaimCode(),
        StepCheckTargetDeviceHasNetworkInterfaces(),
    ]

    private let joinerFlow: [MeshSetupStep] = [
        StepShowInfo(),
        StepGetUserNetworkSelection(),
        StepGetCommissionerDeviceInfo(),
        StepConnectToCommissionerDevice(),
        StepEnsureCommissionerNetworkMatches(),
        StepEnsureCorrectSelectedNetworkPassword(),
        StepJoinSelectedNetwork(),
        StepFinishJoinSelectedNetwork(),
        StepCheckDeviceGotClaimed(),
        StepPublishDeviceSetupDoneEvent(),
        StepGetNewDeviceName(),
        StepOfferToAddOneMoreDevice()
    ]

    //runs before ethernet/wifi/cellular flows
    private let internetConnectedPreflow: [MeshSetupStep] = [
        StepOfferSetupStandAloneOrWithNetwork(),
        StepOfferSelectOrCreateNetwork()
    ]


    private let ethernetFlow: [MeshSetupStep] = [
        StepShowPricingImpact(),
        StepShowInfo(),
        StepEnsureHasInternetAccess(),
        StepCheckDeviceGotClaimed(),
        StepPublishDeviceSetupDoneEvent()
    ]

    private let wifiFlow: [MeshSetupStep] = [
        StepShowPricingImpact(),
        StepShowInfo(),
        StepGetUserWifiNetworkSelection(),
        StepEnsureCorrectSelectedWifiNetworkPassword(),
        StepEnsureHasInternetAccess(),
        StepCheckDeviceGotClaimed(),
        StepPublishDeviceSetupDoneEvent()
    ]

    private let cellularFlow: [MeshSetupStep] = [
        StepShowPricingImpact(),
        StepShowInfo(),
        StepEnsureHasInternetAccess(),
        StepCheckDeviceGotClaimed(),
        StepPublishDeviceSetupDoneEvent()
    ]

    //runs post ethernet/wifi/cellular flows
    private let networkCreatorPostflow: [MeshSetupStep] = [
        StepGetNewDeviceName(),
        StepGetNewNetworkName(),
        StepGetNewNetworkPassword(),
        StepCreateNetwork(),
        StepEnsureHasInternetAccess(),
        StepMakeTargetACommissioner(),
        StepOfferToAddOneMoreDevice()
    ]

    //runs post ethernet/wifi/cellular flows
    private let standalonePostflow: [MeshSetupStep] = [
        StepGetNewDeviceName(),
        StepOfferToAddOneMoreDevice()
    ]


    private (set) public var context: MeshSetupContext

    private var currentFlow: [MeshSetupStep]!
    private var currentStepIdx: Int = 0
    private var currentStep: MeshSetupStep {
        return currentFlow[currentStepIdx]
    }


    init(delegate: MeshSetupFlowManagerDelegate) {
        self.context = MeshSetupContext()

        super.init()

        context.delegate = delegate
        context.stepDelegate = self
        context.bluetoothManager = MeshSetupBluetoothConnectionManager(delegate: self)
    }

    func log(_ message: String) {
        ParticleLogger.logInfo("MeshSetupFlow", format: message, withParameters: getVaList([]))
    }

    func fail(_ sender: MeshSetupStep, withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?) {
        self.fail(withReason: reason, severity: severity, nsError: nsError)
    }

    func fail(withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity = .Error, nsError: Error? = nil) {
        if context.canceled == false {
            if (severity == .Fatal) {
                self.cancelSetup()
            }

            self.log("error: \(reason.description), nsError: \(nsError?.localizedDescription as Optional)")
            context.delegate.meshSetupError(self.currentStep, error: reason, severity: severity, nsError: nsError)
        }
    }


    //MARK: public interface
    //entry to the flow
    func startSetup() {
        currentFlow = preflow
        currentStepIdx = 0

        self.runCurrentStep()
    }

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

    private func finishSetup() {
        context.canceled = true

        context.bluetoothManager.stopScan()
        context.bluetoothManager.dropAllConnections()
    }

    func rewindTo(_ sender: MeshSetupStep, step: MeshSetupStep.Type) -> MeshSetupStep {
        return self.rewindTo(step: step)
    }

    func rewindTo(step: MeshSetupStep.Type) -> MeshSetupStep {

        currentStep.rewindFrom()

        if (currentStepIdx == 0) {
            //if we are backing from one of these flows, we need to switch the flow type.
            if (currentFlow == joinerFlow || currentFlow == ethernetFlow || currentFlow == wifiFlow || currentFlow == cellularFlow) {
                currentFlow = internetConnectedPreflow
            }
            self.log("Rewinding flow to internetConnectedPreflow")
        }

        for i in 0 ..< self.currentFlow.count {
            if (self.currentFlow[i].isKind(of: step)) {
                self.currentStepIdx = i
                self.log("returning to step: \(self.currentStepIdx)")
                self.currentStep.rewindTo(context: self.context)
                self.runCurrentStep()

                return self.currentStep
            }
        }

        fatalError("You are trying to rewind to a step that is not part of current flow")
    }

    func retryLastAction() {
        self.log("Retrying action: \(self.currentStep)")
        self.currentStep.retry()
    }

    //MARK: Flow control
    private func runCurrentStep() {
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

        self.currentStep.reset()
        self.currentStep.run(context: self.context)
    }

    private func switchFlow() {
        log("stepComplete\n\n" +
                "--------------------------------------------------------------------------------------------\n" +
                "Switching flow!!!")

        if (currentFlow == preflow) {
            if (context.targetDevice.hasActiveInternetInterface() && context.selectedNetworkMeshInfo == nil) {
                self.currentFlow = internetConnectedPreflow
                log("setting gateway flow")
            } else {
                //if context.targetDevice.hasActiveInternetInterface() == argon/boron/ethernet joiner flow
                //we don't need internet interface to run this flow and having it
                //makes it hard for steps to determine what is happening
                context.targetDevice.activeInternetInterface = nil

                log("setting xenon joiner flow")
                self.currentFlow = joinerFlow
            }
        } else if (currentFlow == internetConnectedPreflow) {
            if (context.userSelectedToSetupMesh! == false || context.userSelectedToCreateNetwork! == true) {
                //if user wants to go standalone or create network
                if (context.targetDevice.activeInternetInterface! == .ethernet) {
                    self.currentFlow = ethernetFlow
                    log("setting ethernetFlow flow")
                } else if (context.targetDevice.activeInternetInterface! == .wifi) {
                    self.currentFlow = wifiFlow
                    log("setting wifiFlow flow")
                } else if (context.targetDevice.activeInternetInterface! == .ppp) {
                    self.currentFlow = cellularFlow
                    log("setting cellularFlow flow")
                } else {
                    fatalError("wrong state?")
                }
            } else {  //if (context.selectedNetworkMeshInfo != nil)
                //we don't need internet interface to run this flow and having it
                //makes it hard for steps to determine what is happening
                context.targetDevice.activeInternetInterface = nil
                self.currentFlow = joinerFlow
            }
        } else if (currentFlow == ethernetFlow || self.currentFlow == wifiFlow || self.currentFlow == cellularFlow) {
            if (context.userSelectedToSetupMesh!) {
                self.currentFlow = networkCreatorPostflow
                log("setting creatorSubflow flow")
            } else {
               self.currentFlow = standalonePostflow
                log("setting standaloneSubflow flow")
            }
        } else {
            fatalError("no flow to switch to")
        }

        self.currentStepIdx = 0
    }

    func stepCompleted(_ sender: MeshSetupStep) {
        if (context.canceled) {
            return
        }

        if type(of: sender) != type(of: currentStep) {
            self.log("Flow order is broken :(. Current command: \(self.currentStep), Parameter command: \(sender)")
            self.log("Stack:\n\(Thread.callStackSymbols.joined(separator: "\n"))")
            self.fail(withReason: .CriticalFlowError, severity: .Fatal)
        }

        self.currentStepIdx += 1

        if (context.paused) {
            return
        }

        self.runCurrentStep()
    }




    //MARK: BluetoothConnectionManagerDelegate
    func bluetoothConnectionManagerStateChanged(sender: MeshSetupBluetoothConnectionManager, state: MeshSetupBluetoothConnectionManagerState) {
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

    func bluetoothConnectionManagerError(sender: MeshSetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerError = \(error), severity = \(severity)")
        if (!currentStep.handleBluetoothConnectionManagerError(error)) {
            self.fail(withReason: .BluetoothError, severity: .Fatal)
        }
    }

    func bluetoothConnectionManagerConnectionCreated(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerConnectionCreated = \(connection)")

        if (!currentStep.handleBluetoothConnectionManagerConnectionCreated(connection)) {
            self.fail(withReason: .BluetoothError, severity: .Fatal)
        }
    }

    func bluetoothConnectionManagerConnectionBecameReady(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerConnectionBecameReady = \(connection)")

        if (!currentStep.handleBluetoothConnectionManagerConnectionBecameReady(connection)) {
            self.fail(withReason: .BluetoothError, severity: .Fatal)
        }
    }

    func bluetoothConnectionManagerConnectionDropped(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (context.canceled) {
            return
        }

        log("bluetoothConnectionManagerConnectionDropped = \(connection)")

        if (connection == context.targetDevice.transceiver?.connection || connection == context.commissionerDevice?.transceiver?.connection) {
            if (!currentStep.handleBluetoothConnectionManagerConnectionDropped(connection)) {
                self.fail(withReason: .BluetoothConnectionDropped, severity: .Fatal)
            }
        }
        //if some other connection was dropped - we dont care
    }



    func setTargetDeviceInfo(dataMatrix: MeshSetupDataMatrix, useEthernet: Bool) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepGetTargetDeviceInfo.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepGetTargetDeviceInfo).setTargetDeviceInfo(dataMatrix: dataMatrix, useEthernet: useEthernet)
    }

    func setTargetPerformFirmwareUpdate(update: Bool) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepEnsureLatestFirmware.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepEnsureLatestFirmware).setTargetPerformFirmwareUpdate(update: update)
    }

    func setTargetDeviceLeaveNetwork(leave: Bool) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepEnsureTargetDeviceIsNotOnMeshNetwork.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepEnsureTargetDeviceIsNotOnMeshNetwork).setTargetDeviceLeaveNetwork(leave: leave)
    }


    func setSelectStandAloneOrMeshSetup(meshSetup: Bool) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepOfferSetupStandAloneOrWithNetwork.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepOfferSetupStandAloneOrWithNetwork).setSelectStandAloneOrMeshSetup(meshSetup: meshSetup)
    }

    func setOptionalSelectedNetwork(selectedNetworkExtPanID: String?) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepOfferSelectOrCreateNetwork.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepOfferSelectOrCreateNetwork).setOptionalSelectedNetwork(selectedNetworkExtPanID: selectedNetworkExtPanID)
    }

    func rescanNetworks() -> MeshSetupFlowError? {
        //only allow to rescan if current step asks for it and transceiver is free to be used
        guard let isBusy = context.targetDevice.transceiver?.isBusy, isBusy == false else {
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

    func setPricingImpactDone() -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepShowPricingImpact.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepShowPricingImpact).setPricingImpactDone()
    }

    func setInfoDone() -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepShowInfo.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepShowInfo).setInfoDone()
    }

    func setDeviceName(name: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard type(of: currentStep) == StepGetNewDeviceName.self else {
            onComplete(.IllegalOperation)
            return
        }

        (currentStep as! StepGetNewDeviceName).setDeviceName(name: name, onComplete: onComplete)
    }

    func setAddOneMoreDevice(addOneMoreDevice: Bool) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepOfferToAddOneMoreDevice.self else {
            return .IllegalOperation
        }

        if (addOneMoreDevice) {
            self.currentStepIdx = 0
            self.currentFlow = preflow
            self.runCurrentStep()
        } else {
            self.finishSetup()
        }

        return nil
    }


    func setNewNetworkName(name: String) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepGetNewNetworkName.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepGetNewNetworkName).setNewNetworkName(name: name)
    }


    func setNewNetworkPassword(password: String) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepGetNewNetworkPassword.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepGetNewNetworkPassword).setNewNetworkPassword(password: password)
    }

    func setSelectedWifiNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard type(of: currentStep) == StepEnsureCorrectSelectedWifiNetworkPassword.self else {
            onComplete(.IllegalOperation)
            return
        }

        (currentStep as! StepEnsureCorrectSelectedWifiNetworkPassword).setSelectedWifiNetworkPassword(password, onComplete: onComplete)
    }

    func setSelectedWifiNetwork(selectedNetwork: MeshSetupNewWifiNetworkInfo) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepGetUserWifiNetworkSelection.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepGetUserWifiNetworkSelection).setSelectedWifiNetwork(selectedNetwork: selectedNetwork)
    }

    func setSelectedNetwork(selectedNetworkExtPanID: String) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepGetUserNetworkSelection.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepGetUserNetworkSelection).setSelectedNetwork(selectedNetworkExtPanID: selectedNetworkExtPanID)
    }

    func setCommissionerDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError? {
        guard type(of: currentStep) == StepGetCommissionerDeviceInfo.self else {
            return .IllegalOperation
        }

        return (currentStep as! StepGetCommissionerDeviceInfo).setCommissionerDeviceInfo(dataMatrix: dataMatrix)

    }

    func setSelectedNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard type(of: currentStep) == StepEnsureCorrectSelectedNetworkPassword.self else {
            onComplete(.IllegalOperation)
            return
        }

        (currentStep as! StepEnsureCorrectSelectedNetworkPassword).setSelectedNetworkPassword(password, onComplete: onComplete)
    }
}
