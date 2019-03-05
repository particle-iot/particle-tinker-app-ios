//
// Created by Raimundas Sakalauskas on 2019-03-01.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation


class MSFlowManager: NSObject, MeshSetupBluetoothConnectionManagerDelegate, MeshSetupStepDelegate {


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
//        .ChooseFlow
    ]

//    private let internetConnectedPreflow: [MeshSetupFlowCommand] = [
//        .OfferSetupStandAloneOrWithNetwork,
//        .OfferSelectOrCreateNetwork
//    ]
//
//    private let xenonJoinerFlow: [MeshSetupFlowCommand] = [
//        .ShowInfo,
//        .GetUserNetworkSelection,
//        //.ShowPricingImpact
//        .GetCommissionerDeviceInfo,
//        .ConnectToCommissionerDevice,
//        .EnsureCommissionerNetworkMatches,
//        .EnsureCorrectSelectedNetworkPassword,
//        .JoinSelectedNetwork,
//        .FinishJoinSelectedNetwork,
//        .CheckDeviceGotClaimed,
//        .PublishDeviceSetupDoneEvent,
//        .GetNewDeviceName,
//        .OfferToAddOneMoreDevice
//    ]
//
//
//    private let joinerFlow: [MeshSetupFlowCommand] = [
//        //.ShowPricingImpact
//        .ShowInfo,
//        .GetCommissionerDeviceInfo,
//        .ConnectToCommissionerDevice,
//        .EnsureCommissionerNetworkMatches,
//        .EnsureCorrectSelectedNetworkPassword,
//        .JoinSelectedNetwork,
//        .FinishJoinSelectedNetwork,
//        .CheckDeviceGotClaimed,
//        .PublishDeviceSetupDoneEvent,
//        .GetNewDeviceName,
//        .OfferToAddOneMoreDevice
//    ]
//
//    private let ethernetFlow: [MeshSetupFlowCommand] = [
//        .ShowPricingImpact,
//        .ShowInfo,
//        .EnsureHasInternetAccess,
//        .CheckDeviceGotClaimed,
//        .PublishDeviceSetupDoneEvent,
//        .ChooseSubflow
//    ]
//
//    private let wifiFlow: [MeshSetupFlowCommand] = [
//        .ShowPricingImpact,
//        .ShowInfo,
//        .GetUserWifiNetworkSelection,
//        .EnsureCorrectSelectedWifiNetworkPassword,
//        .EnsureHasInternetAccess,
//        .CheckDeviceGotClaimed,
//        .PublishDeviceSetupDoneEvent,
//        .ChooseSubflow
//    ]
//
//    private let cellularFlow: [MeshSetupFlowCommand] = [
//        .ShowPricingImpact,
//        .ShowCellularInfo,
//        .EnsureHasInternetAccess,
//        .CheckDeviceGotClaimed,
//        .PublishDeviceSetupDoneEvent,
//        .ChooseSubflow
//    ]
//
//
//
//    private let creatorSubflow: [MeshSetupFlowCommand] = [
//        .GetNewDeviceName,
//        .GetNewNetworkNameAndPassword,
//        .CreateNetwork,
//        .OfferToAddOneMoreDevice
//    ]
//
//    private let standaloneSubflow: [MeshSetupFlowCommand] = [
//        .GetNewDeviceName,
//        .OfferToAddOneMoreDevice
//    ]


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
        context.bluetoothManager = MeshSetupBluetoothConnectionManager(delegate: self)
    }

    func log(_ message: String) {
        ParticleLogger.logInfo("MeshSetupFlow", format: message, withParameters: getVaList([]))
    }

    func fail(withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity = .Error, nsError: Error? = nil) {
        if context.canceled == false {
            if (severity == .Fatal) {
                self.cancelSetup()
            }

            self.log("error: \(reason.description), nsError: \(nsError?.localizedDescription as Optional)")
            context.delegate.meshSetupError(error: reason, severity: severity, nsError: nsError)
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

    func rewindFlow() {
//
//
//        //from
//        switch self.currentCommand {
//            case .ShowPricingImpact: //if we rewind FROM pricing page, we reset these flags
//                self.pricingInfo = nil
//                self.pricingRequirementsAreMet = nil
//            default:
//                //do nothing
//                break
//        }
//
//
//        if (currentStep == 0) {
//            //if we are backing from one of these flows, we need to switch the flow type.
//            if (currentFlow == joinerFlow || currentFlow == ethernetFlow || currentFlow == wifiFlow || currentFlow == cellularFlow) {
//                currentFlow = internetConnectedPreflow
//                currentStep = internetConnectedPreflow.count
//            }
//            self.log("****** Rewinding to \(self.currentStep-1)(\(currentFlow[currentStep-1]))")
//        } else {
//            self.log("****** Rewinding from \(self.currentStep)(\(currentFlow[currentStep])) to \(self.currentStep-1)(\(currentFlow[currentStep-1]))")
//        }
//
//        self.currentStep -= 1
//
//
//
//        //to
//        switch self.currentCommand {
//            case .OfferSelectOrCreateNetwork:
//                //if this screen was skipped originally, rewind once more
//                if (!self.userSelectedToSetupMesh!) {
//                    self.rewindFlow()
//                    return
//                } else {
//                    self.selectedNetworkMeshInfo = nil
//                }
//            case .OfferSetupStandAloneOrWithNetwork:
//                self.userSelectedToSetupMesh = nil
//            case .GetCommissionerDeviceInfo:
//                self.commissionerDevice = nil
//            case .GetUserNetworkSelection:
//                self.selectedNetworkMeshInfo = nil
//            case .OfferSelectOrCreateNetwork:
//                self.selectedNetworkMeshInfo = nil
//            case .GetUserWifiNetworkSelection:
//                self.selectedWifiNetworkInfo = nil
//            case .OfferSetupStandAloneOrWithNetwork:
//                self.userSelectedToSetupMesh = nil
//            default:
//                //do nothing
//                break
//        }
//
//        self.runCurrentStep()
    }

    func retryLastAction() {
        self.log("Retrying action: \(self.currentStep)")
        self.currentStep.retry()

//        switch self.currentCommand {
//            //this should never happen
//            case .ChooseFlow,
//                    .OfferToAddOneMoreDevice,
//                    .ShowInfo,
//                    .ChooseSubflow,
//                    .GetNewNetworkNameAndPassword,
//                    .OfferSetupStandAloneOrWithNetwork,
//                    .GetNewDeviceName: //this will be handeled by onCompleteHandler of setDeviceName method
//                break
//
//
//            case .GetTargetDeviceInfo,
//                    .GetCommissionerDeviceInfo,
//                    .ConnectToTargetDevice,
//                    .ConnectToCommissionerDevice,
//                    .EnsureLatestFirmware,
//                    .EnsureTargetDeviceCanBeClaimed,
//                    .GetUserNetworkSelection,
//                    .GetAPINetworks,
//                    .EnsureCorrectEthernetFeatureStatus,
//                    .GetUserWifiNetworkSelection,
//                    .CheckTargetDeviceHasNetworkInterfaces,
//                    .SetClaimCode,
//                    .EnsureCommissionerNetworkMatches, //if there's a connection error in this step, we try to recover, but if networks do not match, flow has to be restarted
//                    .EnsureCorrectSelectedNetworkPassword,
//                    .EnsureCorrectSelectedWifiNetworkPassword,
//                    .CreateNetwork,
//                    .ShowCellularInfo,
//                    .ShowPricingImpact,
//                    .EnsureHasInternetAccess,
//                    .PublishDeviceSetupDoneEvent,
//                    .CheckDeviceGotClaimed,
//                    .StopTargetDeviceListening,
//                    .FinishJoinSelectedNetwork,
//                    .OfferSelectOrCreateNetwork,
//                    .JoinSelectedNetwork:
//
//                runCurrentStep()
//
//            case .EnsureTargetDeviceIsNotOnMeshNetwork:
//                if (userSelectedToLeaveNetwork == nil) {
//                    self.runCurrentStep()
//                } else {
//                    setTargetDeviceLeaveNetwork(leave: self.userSelectedToLeaveNetwork!)
//                }
//        }
    }

    //MARK: Flow control
    private func runCurrentStep() {
        if (context.canceled) {
            return
        }

        log("stepComplete\n\n" +
                "--------------------------------------------------------------------------------------------\n" +
                "currentStepIdx = \(currentStepIdx), currentStep = \(currentStep)")

        self.currentStep.stepDelegate = self
        self.currentStep.reset()
        self.currentStep.run(context: self.context, delegate: self)
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

    func rewindTo(_ sender: MeshSetupStep, step: MeshSetupStep.Type) -> MeshSetupStep {
        for i in 0 ..< self.currentFlow.count {
            if (self.currentFlow[i].isKind(of: step)) {
                self.currentStepIdx = i
                self.log("returning to step: \(self.currentStepIdx)")
                self.runCurrentStep()

                return self.currentStep
            }
        }
        fatalError("You are trying to rewind to a step that is not part of current flow")
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

}
