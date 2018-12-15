//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import Foundation
import Crashlytics

class MeshSetupFlowManager: NSObject, MeshSetupBluetoothConnectionManagerDelegate {

    private let preflow: [MeshSetupFlowCommand] = [
        .GetTargetDeviceInfo,
        .ConnectToTargetDevice,
        .EnsureCorrectEthernetFeatureStatus,
        .EnsureLatestFirmware,
        .GetAPINetworks,
        .EnsureTargetDeviceCanBeClaimed,
        .EnsureTargetDeviceIsNotOnMeshNetwork,
        .SetClaimCode,
        .CheckTargetDeviceHasNetworkInterfaces,
        .ChooseFlow
    ]


    private let joinerFlow: [MeshSetupFlowCommand] = [
        .ShowInfo,
        .GetUserNetworkSelection,
        //.ShowPricingImpact
        .GetCommissionerDeviceInfo,
        .ConnectToCommissionerDevice,
        .EnsureCommissionerNetworkMatches,
        .EnsureCorrectSelectedNetworkPassword,
        .JoinSelectedNetwork,
        .FinishJoinSelectedNetwork,
        .CheckDeviceGotClaimed,
        .PublishDeviceSetupDoneEvent,
        .GetNewDeviceName,
        .OfferToAddOneMoreDevice
    ]




    private let ethernetFlow: [MeshSetupFlowCommand] = [
        .OfferSetupStandAloneOrWithNetwork,
        //.OfferSelectOrCreateNetwork,
        .ShowPricingImpact,
        .ShowInfo,
        .EnsureHasInternetAccess,
        .CheckDeviceGotClaimed,
        .PublishDeviceSetupDoneEvent,
        .ChooseSubflow
    ]

    private let wifiFlow: [MeshSetupFlowCommand] = [
        .OfferSetupStandAloneOrWithNetwork,
        //.OfferSelectOrCreateNetwork,
        .ShowPricingImpact,
        .ShowInfo,
        .GetUserWifiNetworkSelection,
        .EnsureCorrectSelectedWifiNetworkPassword,
        .EnsureHasInternetAccess,
        .CheckDeviceGotClaimed,
        .PublishDeviceSetupDoneEvent,
        .ChooseSubflow
    ]

    private let cellularFlow: [MeshSetupFlowCommand] = [
        .OfferSetupStandAloneOrWithNetwork,
        //.OfferSelectOrCreateNetwork,
        .ShowPricingImpact,
        .ShowCellularInfo,
        .EnsureHasInternetAccess,
        .CheckDeviceGotClaimed,
        .PublishDeviceSetupDoneEvent,
        .ChooseSubflow
    ]


    private let creatorSubflow: [MeshSetupFlowCommand] = [
        .GetNewDeviceName,
        .GetNewNetworkNameAndPassword,
        .CreateNetwork,
        .OfferToAddOneMoreDevice
    ]

    private let standaloneSubflow: [MeshSetupFlowCommand] = [
        .GetNewDeviceName,
        .OfferToAddOneMoreDevice
    ]


    //not used in this version of the app.
//    private let joinerSubflow: [MeshSetupFlowCommand] = [
//        .GetCommissionerDeviceInfo,
//        .ConnectToCommissionerDevice,
//        .EnsureCommissionerNetworkMatches,
//        .EnsureCorrectSelectedNetworkPassword,
//        .JoinSelectedNetwork,
//        .FinishJoinSelectedNetwork,
//        .OfferToAddOneMoreDevice
//    ]





    var delegate: MeshSetupFlowManagerDelegate

    private var bluetoothManager: MeshSetupBluetoothConnectionManager!
    private var bluetoothReady: Bool = false

    private(set) public var targetDevice: MeshDevice! = MeshDevice()
    private(set) public var commissionerDevice: MeshDevice?

    //for joining flow
    private(set) public var selectedWifiNetworkInfo: MeshSetupNewWifiNetworkInfo?

    private(set) public var selectedNetworkMeshInfo: MeshSetupNetworkInfo?
    private(set) public var selectedNetworkPassword: String?

    //for creating flow
    private(set) public var newNetworkName: String?
    private(set) public var newNetworkPassword: String?
    private(set) public var newNetworkId: String?

    private(set) public var userSelectedToLeaveNetwork: Bool?
    private(set) public var userSelectedToUpdateFirmware: Bool?
    private(set) public var userSelectedToSetupMesh: Bool?
    private(set) public var userSelectedToCreateNetwork = true //for this version only

    private var pricingRequirementsAreMet: Bool?
    private var apiNetworks: [ParticleNetwork]?

    //to prevent long running actions from executing
    private var canceled = false

    //allows to pause flow at the end of the step if there's something that UI wants to show.
    private var pause = false

    private var currentFlow: [MeshSetupFlowCommand]!
    private var currentStep: Int = 0
    private var currentStepFlags: [String: Any]! //if there's shared data needed to properly run the step
    private var currentCommand: MeshSetupFlowCommand {
        return currentFlow[currentStep]
    }

    init(delegate: MeshSetupFlowManagerDelegate) {
        self.delegate = delegate
        super.init()
        self.bluetoothManager = MeshSetupBluetoothConnectionManager(delegate: self)
    }


    //MARK: public interface
    //entry to the flow
    func startSetup() {
        currentFlow = preflow
        currentStep = 0

        self.runCurrentStep()
    }

    func pauseSetup() {
        self.pause = true
    }

    func continueSetup() {
        if (self.pause) {
            self.pause = false
            self.runCurrentStep()
        }
    }

    func rewindFlow() {
        self.currentStep -= 1

        self.log("****** Rewinding to step: \(self.currentStep) ****** \(self.currentCommand)")
        switch self.currentCommand {
            case .GetCommissionerDeviceInfo:
                self.commissionerDevice = nil
            case .GetUserNetworkSelection:
                self.selectedNetworkMeshInfo = nil
            default:
                //do nothing
                break
        }

        self.runCurrentStep()
    }

    func cancelSetup() {
        self.canceled = true

        self.bluetoothManager.stopScan()
        self.bluetoothManager.dropAllConnections()
    }

    private func finishSetup() {
        self.canceled = true

        self.bluetoothManager.stopScan()
        self.bluetoothManager.dropAllConnections()
    }

    func retryLastAction() {
        self.log("Retrying action: \(self.currentCommand)")
        switch self.currentCommand {
            //this should never happen
            case .ChooseFlow,
                    .OfferToAddOneMoreDevice,
                    .ShowInfo,
                    .ChooseSubflow,
                    .GetNewNetworkNameAndPassword,
                    .OfferSetupStandAloneOrWithNetwork,
                    .GetNewDeviceName: //this will be handeled by onCompleteHandler of setDeviceName method
                break


            case .GetTargetDeviceInfo,
                    .GetCommissionerDeviceInfo,
                    .ConnectToTargetDevice,
                    .ConnectToCommissionerDevice,
                    .EnsureLatestFirmware,
                    .EnsureTargetDeviceCanBeClaimed,
                    .GetUserNetworkSelection,
                    .GetAPINetworks,
                    .EnsureCorrectEthernetFeatureStatus,
                    .GetUserWifiNetworkSelection,
                    .CheckTargetDeviceHasNetworkInterfaces,
                    .SetClaimCode,
                    .EnsureCommissionerNetworkMatches, //if there's a connection error in this step, we try to recover, but if networks do not match, flow has to be restarted
                    .EnsureCorrectSelectedNetworkPassword,
                    .EnsureCorrectSelectedWifiNetworkPassword,
                    .CreateNetwork,
                    .ShowCellularInfo,
                    .ShowPricingImpact,
                    .EnsureHasInternetAccess,
                    .PublishDeviceSetupDoneEvent,
                    .CheckDeviceGotClaimed,
                    .StopTargetDeviceListening,
                    .FinishJoinSelectedNetwork,
                    //.OfferSelectOrCreateNetwork,
                    .JoinSelectedNetwork:

                runCurrentStep()

            case .EnsureTargetDeviceIsNotOnMeshNetwork:
                if (userSelectedToLeaveNetwork == nil) {
                    self.runCurrentStep()
                } else {
                    setTargetDeviceLeaveNetwork(leave: self.userSelectedToLeaveNetwork!)
                }
        }
    }

    //MARK: Flow control
    private func runCurrentStep() {
        if (self.canceled) {
            return
        }

        log("stepComplete\n\n" +
                "--------------------------------------------------------------------------------------------\n" +
                "currentStep = \(currentStep), currentCommand = \(currentCommand)")
        self.currentStepFlags = [:]
        switch self.currentCommand {
            //preflow
            case .GetTargetDeviceInfo:
                self.stepGetTargetDeviceInfo()
            case .ConnectToTargetDevice:
                self.stepConnectToTargetDevice()
            case .EnsureLatestFirmware:
                self.stepEnsureLatestFirmware()
            case .EnsureTargetDeviceCanBeClaimed:
                self.stepEnsureTargetDeviceCanBeClaimed()
            case .CheckTargetDeviceHasNetworkInterfaces:
                self.stepCheckTargetDeviceHasNetworkInterfaces()
            case .EnsureTargetDeviceIsNotOnMeshNetwork:
                self.stepEnsureTargetDeviceIsNotOnMeshNetwork()
            case .SetClaimCode:
                self.stepSetClaimCode()
            case .EnsureCorrectEthernetFeatureStatus:
                self.stepEnsureCorrectEthernetFeatureStatus()
            case .ShowPricingImpact:
                self.stepShowPricingImpact()

            case .PublishDeviceSetupDoneEvent:
                self.stepPublishDeviceSetupDoneEvent();
            case .GetAPINetworks:
                self.stepGetAPINetworks()

            case .OfferSetupStandAloneOrWithNetwork:
                stepOfferSetupStandAloneOrWithNetwork()
//            case .OfferSelectOrCreateNetwork:
//                self.stepOfferSelectOrCreateNetwork()
            case .ChooseFlow:
                 self.stepChooseFlow()

            //main flow
            case .GetUserNetworkSelection:
                self.stepGetUserNetworkSelection()
            case .GetCommissionerDeviceInfo:
                self.stepGetCommissionerDeviceInfo()
            case .ConnectToCommissionerDevice:
                self.stepConnectToCommissionerDevice()
            case .EnsureCommissionerNetworkMatches:
                self.stepEnsureCommissionerNetworkMatches()
            case .EnsureCorrectSelectedNetworkPassword:
                self.stepEnsureCorrectSelectedNetworkPassword()
            case .JoinSelectedNetwork:
                self.stepJoinSelectedNetwork()
            case .FinishJoinSelectedNetwork:
                self.stepFinishJoinSelectedNetwork()
            case .GetNewDeviceName:
                self.stepGetNewDeviceName()
            case .OfferToAddOneMoreDevice:
                self.stepOfferToAddOneMoreDevice()

            //gateway
            case .GetUserWifiNetworkSelection:
                self.stepGetUserWifiNetworkSelection()
            case .ShowInfo:
                self.stepShowInfo()
            case .ShowCellularInfo:
                self.stepShowCellularInfo()
            case .EnsureCorrectSelectedWifiNetworkPassword:
                self.stepEnsureCorrectSelectedWifiNetworkPassword()
            case .EnsureHasInternetAccess:
                self.stepEnsureHasInternetAccess()
            case .StopTargetDeviceListening:
                self.stepStopTargetDeviceListening()
            case .CheckDeviceGotClaimed:
                 self.stepCheckDeviceGotClaimed()
            case .ChooseSubflow:
                self.stepChooseSubflow()

            case .GetNewNetworkNameAndPassword:
                self.stepGetNewNetworkNameAndPassword()
            case .CreateNetwork:
                self.stepCreateNetwork()

            default:
                log("Unknown command: \(currentFlow[currentStep])")
            }
    }


    private func stepComplete(_ command:MeshSetupFlowCommand) {
        if (self.canceled) {
            return
        }

        if (self.currentCommand != command) {
            self.log("Flow order is broken :(. Current command: \(self.currentCommand), Parameter command: \(command)")
            self.log("Stack:\n\(Thread.callStackSymbols.joined(separator: "\n"))")
            self.fail(withReason: .CriticalFlowError, severity: .Fatal)
        }

        self.currentStep += 1

        if (self.pause) {
            return
        }

        self.runCurrentStep()
    }


    //end of preflow
    private func stepChooseFlow() {
        //jump to new flow
        self.currentStep = 0

        if (self.targetDevice.hasActiveInternetInterface() && self.selectedNetworkMeshInfo != nil) {
            self.log("_!_!_!_!_!_!_ we should never get to this state!!!!")
        } else if (self.targetDevice.hasActiveInternetInterface() && self.selectedNetworkMeshInfo == nil) {
            //if there's internet and we are not adding more devices to same network
            if (targetDevice.activeInternetInterface! == .ethernet) {
                self.currentFlow = ethernetFlow
            } else if (targetDevice.activeInternetInterface! == .wifi) {
                self.currentFlow = wifiFlow
            } else if (targetDevice.activeInternetInterface! == .ppp) {
                self.currentFlow = cellularFlow
            } else {
                fatalError("wrong state?")
            }

            log("setting gateway flow")
        } else {
            self.currentFlow = joinerFlow
            log("setting joiner flow")
        }
        self.runCurrentStep()
    }

    private func stepChooseSubflow() {
       if (self.userSelectedToSetupMesh!) {
            self.currentStep = 0
            self.currentFlow = creatorSubflow
//        if (userSelectedToCreateNetwork) {
//            log("subflow: creator")
//            self.currentFlow = creatorSubflow
//        } else {
//            log("subflow: joiner")
//            self.currentFlow = joinerSubflow
//        }
            self.runCurrentStep()
        } else {
           self.currentStep = 0
           self.currentFlow = standaloneSubflow
           self.runCurrentStep()
        }
    }

    //MARK: Helpers
    private func log(_ message: String) {
        ParticleLogger.logInfo("MeshSetupFlow", format: message, withParameters: getVaList([]))
    }

    private func fail(withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity = .Error, nsError: Error? = nil) {
        if self.canceled == false {
            if (severity == .Fatal) {
                self.cancelSetup()
            }

            log("error: \(reason.description), nsError: \(nsError?.localizedDescription as Optional)")
            self.delegate.meshSetupError(error: reason, severity: severity, nsError: nsError)
        }
    }

    private func removeRepeatedMeshNetworks(_ networks: [MeshSetupNetworkInfo]) -> [MeshSetupNetworkInfo] {
        var meshNetworkIds:Set<String> = []
        var filtered:[MeshSetupNetworkInfo] = []

        for network in networks {
            if (!meshNetworkIds.contains(network.extPanID)) {
                meshNetworkIds.insert(network.extPanID)
                filtered.append(network)
            }
        }

        return filtered
    }


    private func removeRepeatedWifiNetworks(_ networks: [MeshSetupNewWifiNetworkInfo]) -> [MeshSetupNewWifiNetworkInfo] {
        var wifiNetworkIds:Set<String> = []
        var filtered:[MeshSetupNewWifiNetworkInfo] = []

        for network in networks {
            if (!wifiNetworkIds.contains(network.ssid)) {
                wifiNetworkIds.insert(network.ssid)
                filtered.append(network)
            }
        }

        return filtered
    }

    //MARK: Input validators
    private func validateNetworkPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    private func validateWifiNetworkPassword(_ password: String) -> Bool {
        return password.count >= 8
    }

    private func validateNetworkName(_ networkName: String) -> Bool {
        //ensure proper length
        if (networkName.count == 0) || (networkName.count > 16) {
            return false
        }

        //ensure no illegal characters
        let regex = try! NSRegularExpression(pattern: "[^a-zA-Z0-9_\\-]+")
        let matches = regex.matches(in: networkName, options: [], range: NSRange(location: 0, length: networkName.count))
        return matches.count == 0
    }

    private func validateDeviceName(_ name: String) -> Bool {
        return name.count > 0
    }


    //MARK: Error Handling
    private func handleBluetoothErrorResult(_ result: ControlReplyErrorType) {
        if (self.canceled) {
            return
        }

        if (result == .TIMEOUT && !self.bluetoothReady) {
            self.fail(withReason: .BluetoothDisabled)
            return
        } else if (result == .TIMEOUT) {
            self.fail(withReason: .BluetoothTimeout)
            return
        } else if (result == .INVALID_STATE) {
            self.fail(withReason: .InvalidDeviceState, severity: .Fatal)
        } else {
            self.fail(withReason: .BluetoothError)
            return
        }
    }

    //MARK: BluetoothConnectionManagerDelegate
    func bluetoothConnectionManagerStateChanged(sender: MeshSetupBluetoothConnectionManager, state: MeshSetupBluetoothConnectionManagerState) {
        if (self.canceled) {
            return
        }

        log("bluetoothConnectionManagerStateChanged = \(state)")
        if (self.bluetoothManager.state == .Ready) {
            self.bluetoothReady = true
        } else if (self.bluetoothManager.state == .Disabled) {
            self.bluetoothReady = false

            //if we are waiting for the reply = trigger timeout
            if let targetDeviceTransceiver = self.targetDevice.transceiver {
                targetDeviceTransceiver.triggerTimeout()
            }

            //if we are waiting for the reply = trigger timeout
            if let commissionerDeviceTransceiver = self.commissionerDevice?.transceiver {
                commissionerDeviceTransceiver.triggerTimeout()
            }
        }
        //other states are really temporary.
    }

    func bluetoothConnectionManagerError(sender: MeshSetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity) {
        if (self.canceled) {
            return
        }

        log("bluetoothConnectionManagerError = \(error), severity = \(severity)")
        if (self.currentCommand == .ConnectToTargetDevice || self.currentCommand == .ConnectToCommissionerDevice) {
            if (error == .DeviceWasConnected) {
                self.currentStepFlags["reconnect"] = true
                //this will be used in connection dropped to restart the step
            } else if (error == .DeviceTooFar) {
                self.fail(withReason: .DeviceTooFar)
                //after showing promt, step should be repeated
            } else if (error == .FailedToScanBecauseOfTimeout && self.currentStepFlags["reconnectAfterForcedReboot"] != nil) {
                if ((self.currentStepFlags["reconnectAfterForcedRebootRetry"] as! Int) < 4) {
                    self.currentStepFlags["reconnectAfterForcedRebootRetry"] = (self.currentStepFlags["reconnectAfterForcedRebootRetry"]! as! Int) + 1
                    //coming online after a flash might take a while, if for some reason we timeout, we should retry the step
                    self.stepConnectToTargetDevice()
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
        } else {
            //bluetoothConnectionManagerError shouldn't happen in any other step but if it happens lets handle it
            self.fail(withReason: .BluetoothError, severity: .Fatal)
        }
    }

    func bluetoothConnectionManagerConnectionCreated(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.canceled) {
            return
        }

        if (self.currentCommand == .ConnectToTargetDevice) {
            self.delegate.meshSetupDidEnterState(state: .TargetDeviceConnected)
        } else if (self.currentCommand == .ConnectToCommissionerDevice) {
            self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceConnected)
        } else {
            //bluetoothConnectionManagerConnectionCreated shouldn't happen in any other step but if it happens lets handle it
            self.fail(withReason: .BluetoothError, severity: .Fatal)
        }
    }

    func bluetoothConnectionManagerConnectionBecameReady(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.canceled) {
            return
        }

        if (self.currentCommand == .ConnectToTargetDevice) {
            self.delegate.meshSetupDidEnterState(state: .TargetDeviceReady)
            self.targetDeviceConnected(connection: connection)
        } else if (self.currentCommand == .ConnectToCommissionerDevice) {
            self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceReady)
            self.commissionerDeviceConnected(connection: connection)
        } else {
            //bluetoothConnectionManagerConnectionBecameReady shouldn't happen in any other step but if it happens lets handle it
            self.fail(withReason: .BluetoothError, severity: .Fatal)
        }
    }

    func bluetoothConnectionManagerConnectionDropped(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.canceled) {
            return
        }

        log("bluetoothConnectionManagerConnectionDropped = \(connection)")
        if (connection == self.targetDevice.transceiver?.connection || connection == self.commissionerDevice?.transceiver?.connection) {
            if self.currentStepFlags["reconnect"] != nil && (self.currentCommand == .ConnectToTargetDevice || self.currentCommand == .ConnectToCommissionerDevice) {
                self.currentStepFlags["reconnect"] = nil
                self.runCurrentStep()
            } else if self.currentCommand == .EnsureLatestFirmware,
                      let chunk = self.currentStepFlags["chunkSize"] as? Int,
                      let idx = self.currentStepFlags["idx"] as? Int,
                      let firmwareData = self.currentStepFlags["firmwareData"] as? Data,
                      ((idx+1) * chunk >= firmwareData.count) {
                self.reconnectHandler()
            } else if self.currentCommand == .EnsureCorrectEthernetFeatureStatus {
                self.reconnectHandler()
            } else {
                self.fail(withReason: .BluetoothConnectionDropped, severity: .Fatal)
            }
        }
        //if some other connection was dropped - we dont care
    }

    func reconnectHandler() {
        self.log("Connection was dropped, but it's fine.")
        //lets try reconnecting to the device by moving few steps back
        self.currentStep = self.preflow.index(of: .ConnectToTargetDevice)!
        self.log("returning to step: \(self.currentStep)")
        self.runCurrentStep()
        self.currentStepFlags["reconnectAfterForcedReboot"] = true
        self.currentStepFlags["reconnectAfterForcedRebootRetry"] = 0
    }
//}

//extension MeshSetupFlowManager {



    //MARK: GetTargetDeviceInfo
    private func stepGetTargetDeviceInfo() {
        self.delegate.meshSetupDidRequestTargetDeviceInfo()
    }

    func setTargetDeviceInfo(dataMatrix: MeshSetupDataMatrix, useEthernet: Bool) -> MeshSetupFlowError? {
        guard currentCommand == .GetTargetDeviceInfo else {
            return .IllegalOperation
        }

        self.targetDevice = MeshDevice()
        self.resetFlowFlags()

        self.log("dataMatrix: \(dataMatrix)")
        self.targetDevice.enableEthernetFeature = useEthernet
        self.targetDevice.type = ParticleDeviceType(serialNumber: dataMatrix.serialNumber)
        self.log("self.targetDevice.type?.description = \(self.targetDevice.type?.description as Optional)")
        self.targetDevice.credentials = MeshSetupPeripheralCredentials(name: self.targetDevice.type!.description + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        self.stepComplete(.GetTargetDeviceInfo)

        return nil
    }

    private func resetFlowFlags() {
        //these flags are used to determine gateway subflow .. if they are set, new network is being created
        //otherwise gateway is joining the existing network so it is important to clear them
        //we cant use selected network, because that part might be reused if multiple devices are connected to same
        //network without disconnecting commissioner
        self.newNetworkPassword = nil
        self.newNetworkName = nil
        self.newNetworkId = nil

        self.apiNetworks = nil

        self.userSelectedToLeaveNetwork = nil
        self.userSelectedToUpdateFirmware = nil
        self.userSelectedToSetupMesh = nil
    }



    //MARK: ConnectToTargetDevice
    private func stepConnectToTargetDevice() {
        if (self.bluetoothManager.state != .Ready) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.fail(withReason: .BluetoothDisabled)
            }
            return
        }

        self.bluetoothManager.createConnection(with: self.targetDevice.credentials!)
        self.delegate.meshSetupDidEnterState(state: .TargetDeviceConnecting)
    }

    private func targetDeviceConnected(connection: MeshSetupBluetoothConnection) {
        self.targetDevice.transceiver = MeshSetupProtocolTransceiver(connection: connection)
        self.stepComplete(.ConnectToTargetDevice)
    }



    //MARK: CheckTargetDeviceHasNetworkInterfaces
    private func stepCheckTargetDeviceHasNetworkInterfaces() {
        self.targetDevice.transceiver!.sendGetInterfaceList { result, interfaces in
            self.log("targetDevice.sendGetInterfaceList: \(result.description()), networkCount: \(interfaces?.count as Optional)")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.targetDevice.activeInternetInterface = nil

                self.targetDevice.networkInterfaces = interfaces!
                for interface in interfaces! {
                    if (interface.type == .ethernet) {
                        //top priority
                        self.targetDevice.activeInternetInterface = .ethernet
                        break
                    } else if (interface.type == .wifi) {
                        //has priority over .ppp, but not over .ethernet
                        if (self.targetDevice.activeInternetInterface == nil || self.targetDevice.activeInternetInterface! == .ppp) {
                            self.targetDevice.activeInternetInterface = .wifi
                        }
                    } else if (interface.type == .ppp) {
                        //lowest priority, only set if there's no other interface
                        if (self.targetDevice.activeInternetInterface == nil) {
                            self.targetDevice.activeInternetInterface = .ppp
                        }
                    }
                }

                //for this release we are not supporting multiple gateways in the same network, so if user has scanned
                //gateway device for "add one more device" option, we stop right here.
                if (self.targetDevice.hasActiveInternetInterface() && self.selectedNetworkMeshInfo != nil) {
                    self.fail(withReason: .CannotAddGatewayDeviceAsJoiner, severity: .Fatal)
                    return
                } else {
                    self.stepComplete(.CheckTargetDeviceHasNetworkInterfaces)
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    //MARK: EnsureDeviceCanBeClaimed
    private func stepEnsureTargetDeviceCanBeClaimed() {
        self.targetDevice.transceiver!.sendGetDeviceId { result, deviceId in
            self.log("targetDevice.didReceiveDeviceIdReply: \(result.description()), deviceId: \(deviceId as Optional)")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.targetDevice.deviceId = deviceId!
                self.checkTargetDeviceIsClaimed()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    private func checkTargetDeviceIsClaimed() {
        self.log("sending get devices")
        ParticleCloud.sharedInstance().getDevices { devices, error in
            if (self.canceled) {
                return
            }

            self.log("get devices completed")

            guard error == nil else {
                self.fail(withReason: .UnableToGenerateClaimCode, nsError: error)
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == self.targetDevice.deviceId!) {
                        self.log("device belongs to user already")
                        self.targetDevice.name = device.name
                        self.targetDevice.isClaimed = true
                        self.targetDevice.claimCode = nil
                        self.stepComplete(.EnsureTargetDeviceCanBeClaimed)
                        return
                    }
                }
            }

            self.targetDevice.isClaimed = nil
            self.targetDevice.claimCode = nil

            self.getClaimCode()
        }
    }

    private func getClaimCode() {
        log("generating claim code")
        ParticleCloud.sharedInstance().generateClaimCode { claimCode, userDevices, error in
            if (self.canceled) {
                return
            }

            guard error == nil else {
                self.fail(withReason: .UnableToGenerateClaimCode, nsError: error)
                return
            }

            self.log("claim code generated")
            self.targetDevice.claimCode = claimCode
            self.targetDevice.isClaimed = false
            self.stepComplete(.EnsureTargetDeviceCanBeClaimed)
        }
    }




    //MARK: EnsureTargetDeviceIsNotOnMeshNetwork
    private func stepEnsureTargetDeviceIsNotOnMeshNetwork() {
        self.getTargetDeviceMeshNetworkInfo()
    }

    private func getTargetDeviceMeshNetworkInfo() {
        self.targetDevice.transceiver!.sendGetNetworkInfo { result, networkInfo in
            self.log("targetDevice.sendGetNetworkInfo: \(result.description())")
            self.log("\(networkInfo as Optional)");
            if (self.canceled) {
                return
            }

            if (result == .NOT_FOUND) {
                self.targetDevice.meshNetworkInfo = nil
                let _ = self.setTargetDeviceLeaveNetwork(leave: true)
            } else if (result == .NONE) {
                self.targetDevice.meshNetworkInfo = networkInfo
                if (self.targetDevice.meshNetworkInfo!.networkID.count == 0) {
                    let _ = self.setTargetDeviceLeaveNetwork(leave: true)
                } else {
                    self.delegate.meshSetupDidRequestToLeaveNetwork(network: networkInfo!)
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    func setTargetDeviceLeaveNetwork(leave: Bool) -> MeshSetupFlowError? {
        guard currentCommand == .EnsureTargetDeviceIsNotOnMeshNetwork else {
            return .IllegalOperation
        }

        self.userSelectedToLeaveNetwork = leave

        self.log("setTargetDeviceLeaveNetwork: \(leave)")
        //forcing this command on devices with no network info helps with the joining process
        if (leave || self.targetDevice.meshNetworkInfo == nil) {
            self.targetDeviceLeaveAPINetwork()
        } else {
            //user decided to cancel setup, and we want to get his device in normal mode.
            self.log("stopping listening mode?")
            self.stopTargetDeviceListening(onComplete: {
                self.delegate.meshSetupDidEnterState(state: .SetupCanceled)
            })
        }

        return nil
    }

    private func targetDeviceLeaveAPINetwork() {
        self.log("sening remove device network info to API")
        ParticleCloud.sharedInstance().removeDeviceNetworkInfo(self.targetDevice.deviceId!) {
            error in

            if (self.canceled) {
                return
            }

            self.log("removeDevice error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToLeaveNetwork, nsError: error)
                return
            }

            self.targetDeviceLeaveMeshNetwork(reloadAPINetworks: true)
        }
    }

    private func targetDeviceLeaveMeshNetwork(reloadAPINetworks: Bool) {
        self.targetDevice.transceiver!.sendLeaveNetwork { result in
            self.log("targetDevice.didReceiveLeaveNetworkReply: \(result.description())")
            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                self.targetDevice.meshNetworkInfo = nil
                if (reloadAPINetworks) {
                    self.getAPINetworks {
                        self.stepComplete(.EnsureTargetDeviceIsNotOnMeshNetwork)
                    }
                } else {
                    self.stepComplete(.EnsureTargetDeviceIsNotOnMeshNetwork)
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }




    //MARK: SetClaimCode
    private func stepSetClaimCode() {
        if let claimCode = self.targetDevice.claimCode {
            self.targetDevice.transceiver!.sendSetClaimCode(claimCode: claimCode) { result in
                self.log("targetDevice.sendSetClaimCode: \(result.description())")
                if (self.canceled) {
                    return
                }
                if (result == .NONE) {
                    self.stepComplete(.SetClaimCode)
                } else {
                    self.handleBluetoothErrorResult(result)
                }
            }
        } else {
            self.log("skipping step as device belongs to user")
            self.stepComplete(.SetClaimCode)
        }
    }



    //MARK: GetUserWifiNetworkSelection
    private func stepGetUserWifiNetworkSelection() {
        self.delegate.meshSetupDidEnterState(state: .TargetDeviceScanningForWifiNetworks)
        self.scanWifiNetworks()
    }

    private func scanWifiNetworks() {
        self.targetDevice.transceiver!.sendScanWifiNetworks { result, networks in
            self.log("sendScanWifiNetworks: \(result.description()), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")

            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                self.targetDevice.wifiNetworks = self.removeRepeatedWifiNetworks(networks!)
                self.getUserWifiNetworkSelection()
            } else {
                //this command will be repeated multiple times, no need to trigger errors.. just pretend all is fine
                self.targetDevice.wifiNetworks = []
                self.getUserWifiNetworkSelection()
            }
        }
    }

    func rescanWifiNetworks() -> MeshSetupFlowError? {
        //only allow to rescan if current step asks for it and transceiver is free to be used
        guard let isBusy = targetDevice.transceiver?.isBusy, isBusy == false else {
            return .IllegalOperation
        }

        if (self.currentCommand == .GetUserWifiNetworkSelection) {
            self.scanWifiNetworks()
        } else {
            return .IllegalOperation
        }

        return nil
    }


    private func getUserWifiNetworkSelection() {
        self.delegate.meshSetupDidRequestToSelectWifiNetwork(availableNetworks: self.targetDevice.wifiNetworks!)
    }

    func setSelectedWifiNetwork(selectedNetwork: MeshSetupNewWifiNetworkInfo) -> MeshSetupFlowError? {
        guard currentCommand == .GetUserWifiNetworkSelection else {
            return .IllegalOperation
        }

        self.selectedWifiNetworkInfo = selectedNetwork
        self.stepComplete(.GetUserWifiNetworkSelection)

        return nil
    }


    //MARK: PublishDeviceSetupDoneEvent
    private func stepPublishDeviceSetupDoneEvent() {
        self.log("publishing device setup done")
        ParticleCloud.sharedInstance().publishEvent(withName: "mesh-device-setup-complete", data: self.targetDevice.deviceId!, isPrivate: true, ttl: 60) {
            error in
            if (self.canceled) {
                return
            }

            self.log("stepPublishDeviceSetupDoneEvent error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToPublishDeviceSetupEvent, nsError: error)
                return
            }

            self.stepComplete(.PublishDeviceSetupDoneEvent)
        }
    }

    //MARK: GetAPINetworks
    private func stepGetAPINetworks() {
        self.log("sening get networks")
        getAPINetworks {
            self.stepComplete(.GetAPINetworks)
        }
    }

    func getAPINetworks(onComplete: @escaping () -> ()) {
        ParticleCloud.sharedInstance().getNetworks { networks, error in
            if (self.canceled) {
                return
            }

            self.log("getNetworks: \(networks as Optional), error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToRetrieveNetworks, nsError: error)
                return
            }

            if let networks = networks {
                self.apiNetworks = networks
            } else {
                self.apiNetworks = []
            }

            onComplete()
        }
    }


    //MARK: GetUserNetworkSelection
    private func stepGetUserNetworkSelection() {
        //adding more devices to same network
        if (self.selectedNetworkMeshInfo != nil) {
            self.stepComplete(.GetUserNetworkSelection)
            return
        }

        self.delegate.meshSetupDidEnterState(state: .TargetDeviceScanningForNetworks)

        self.scanNetworks {
            self.getUserNetworkSelection()
        }
    }


    private func scanNetworks(onComplete: @escaping () -> ()) {
        self.targetDevice.transceiver!.sendScanNetworks { result, networks in
            self.log("sendScanNetworks: \(result.description()), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.targetDevice.meshNetworks = self.removeRepeatedMeshNetworks(networks!)
                onComplete()
            } else {
                //this command will be repeated multiple times, no need to trigger errors.. just pretend all is fine
                self.targetDevice.meshNetworks = []
                onComplete()
                //self.handleBluetoothErrorResult(result)
            }
        }
    }

    //TODO: GET /v1/networks to get device count
    func rescanNetworks() -> MeshSetupFlowError? {
        //only allow to rescan if current step asks for it and transceiver is free to be used
        guard let isBusy = targetDevice.transceiver?.isBusy, isBusy == false else {
            return .IllegalOperation
        }

        if (self.currentCommand == .GetUserNetworkSelection) {
            self.scanNetworks {
                self.getUserNetworkSelection()
            }
//        } else if (self.currentCommand == .OfferSelectOrCreateNetwork) {
//            self.scanNetworks(onComplete: self.getUserMeshSetupChoice)
        } else {
            return .IllegalOperation
        }

        return nil
    }


    private func getUserNetworkSelection() {
        var networks = [String: MeshSetupNetworkCellInfo]()

        for network in self.targetDevice.meshNetworks! {
            networks[network.extPanID] = MeshSetupNetworkCellInfo(name: network.name, extPanID: network.extPanID, userOwned: false, deviceCount: nil)
        }

        for apiNetwork in self.apiNetworks! {
            if let xpanId = apiNetwork.xpanId, var meshNetwork = networks[xpanId] {
                meshNetwork.userOwned = true
                meshNetwork.deviceCount = apiNetwork.deviceCount
                networks[xpanId] = meshNetwork
            }
        }

        self.delegate.meshSetupDidRequestToSelectNetwork(availableNetworks: Array(networks.values))
    }

    func setSelectedNetwork(selectedNetworkExtPanID: String) -> MeshSetupFlowError? {
        guard currentCommand == .GetUserNetworkSelection else {
            return .IllegalOperation
        }

        self.selectedNetworkMeshInfo = nil
        for network in self.targetDevice.meshNetworks! {
            if network.extPanID == selectedNetworkExtPanID {
                self.selectedNetworkMeshInfo = network
                break
            }
        }

        self.stepComplete(.GetUserNetworkSelection)

        return nil
    }



    //MARK: GetCommissionerDeviceInfo
    private func stepGetCommissionerDeviceInfo() {
        //adding more devices to same network
        if (self.commissionerDevice?.credentials != nil) {
            //we need to put the commissioner into listening mode by sending the command
            self.commissionerDevice!.transceiver!.sendStarListening { result in
                self.log("commissionerDevice.sendStarListening: \(result.description())")
                if (self.canceled) {
                    return
                }
                if (result == .NONE) {
                    self.stepComplete(.GetCommissionerDeviceInfo)
                } else {
                    self.handleBluetoothErrorResult(result)
                }
            }
            return
        }

        self.delegate.meshSetupDidRequestCommissionerDeviceInfo()
    }

    func setCommissionerDeviceInfo(dataMatrix: MeshSetupDataMatrix) -> MeshSetupFlowError? {
        guard currentCommand == .GetCommissionerDeviceInfo else {
            return .IllegalOperation
        }

        self.commissionerDevice = MeshDevice()

        self.log("dataMatrix: \(dataMatrix)")
        self.commissionerDevice!.type = ParticleDeviceType(serialNumber: dataMatrix.serialNumber)
        self.log("self.commissionerDevice.type?.description = \(self.commissionerDevice!.type?.description as Optional)")
        self.commissionerDevice!.credentials = MeshSetupPeripheralCredentials(name: self.commissionerDevice!.type!.description + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        if (self.commissionerDevice?.credentials?.name == self.targetDevice.credentials?.name) {
            self.commissionerDevice = nil
            return .SameDeviceScannedTwice
        }

        self.stepComplete(.GetCommissionerDeviceInfo)

        return nil
    }


    //MARK: ConnectToCommissionerDevice
    private func stepConnectToCommissionerDevice() {
        //adding more devices to same network, no need reconnect to commissioner
        if (self.commissionerDevice?.transceiver != nil) {
            self.stepComplete(.ConnectToCommissionerDevice)
            return
        }

        if (self.bluetoothManager.state != .Ready) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.fail(withReason: .BluetoothDisabled)
            }
            return
        }

        self.bluetoothManager.createConnection(with: self.commissionerDevice!.credentials!)
        self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceConnected)
    }

    private func commissionerDeviceConnected(connection: MeshSetupBluetoothConnection) {
        self.commissionerDevice!.transceiver = MeshSetupProtocolTransceiver(connection: connection)
        self.stepComplete(.ConnectToCommissionerDevice)
    }


    //MARK: EnsureCommissionerNetworkMatches
    private func stepEnsureCommissionerNetworkMatches() {
        self.commissionerDevice!.transceiver!.sendGetNetworkInfo { result, networkInfo in
            self.log("commissionerDevice.sendGetNetworkInfo: \(result.description()), networkInfo: \(networkInfo as Optional)")
            if (self.canceled) {
                return
            }

            if (result == .NOT_FOUND) {
                self.commissionerDevice!.meshNetworkInfo = nil
            } else if (result == .NONE) {
                self.commissionerDevice!.meshNetworkInfo = networkInfo
            } else {
                self.handleBluetoothErrorResult(result)
                return
            }

            if (self.selectedNetworkMeshInfo?.extPanID == self.commissionerDevice!.meshNetworkInfo?.extPanID) {
                self.selectedNetworkMeshInfo = self.commissionerDevice!.meshNetworkInfo
                self.targetDevice.meshNetworkInfo = self.commissionerDevice!.meshNetworkInfo

                if let networkId = self.targetDevice.meshNetworkInfo?.networkID, networkId.count > 0 {
                    self.stepComplete(.EnsureCommissionerNetworkMatches)
                } else {
                    self.fail(withReason: .UnableToJoinOldNetwork, severity: .Fatal)
                    return
                }
            } else {
                //drop connection with current peripheral
                let connection = self.commissionerDevice!.transceiver!.connection
                self.commissionerDevice!.transceiver = nil
                self.commissionerDevice = nil
                self.bluetoothManager.dropConnection(with: connection)


                self.currentStep = self.currentFlow.index(of: .GetCommissionerDeviceInfo)!
                self.pause = false

                self.fail(withReason: .CommissionerNetworkDoesNotMatch)
            }
        }
    }



    //MARK: EnsureCorrectSelectedNetworkPassword
    private func stepEnsureCorrectSelectedNetworkPassword() {
        if (self.selectedNetworkPassword != nil) {
            self.stepComplete(.EnsureCorrectSelectedNetworkPassword)
            return
        }

        self.delegate.meshSetupDidRequestToEnterSelectedNetworkPassword()
    }

    func setSelectedNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard currentCommand == .EnsureCorrectSelectedNetworkPassword else {
            onComplete(.IllegalOperation)
            return
        }

        guard self.validateNetworkPassword(password) else {
            onComplete(.PasswordTooShort)
            return
        }

        /// NOT_FOUND: The device is not a member of a network
        /// NOT_ALLOWED: Invalid commissioning credential
        self.commissionerDevice!.transceiver!.sendAuth(password: password) { result in
            if (self.canceled) {
                return
            }
            self.log("trying password: \(password)")

            self.log("commissionerDevice.sendAuth: \(result.description())")
            if (result == .NONE) {
                self.log("password set: \(password)")
                self.selectedNetworkPassword = password

                onComplete(nil)
                self.stepComplete(.EnsureCorrectSelectedNetworkPassword)
            } else if (result == .NOT_ALLOWED) {
                onComplete(.WrongNetworkPassword)
            } else {
                onComplete(.BluetoothTimeout)
            }
        }
    }




    //MARK: EnsureCorrectSelectedWifiNetworkPassword
    private func stepEnsureCorrectSelectedWifiNetworkPassword() {
        self.delegate.meshSetupDidRequestToEnterSelectedWifiNetworkPassword()
    }

    func setSelectedWifiNetworkPassword(_ password: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard currentCommand == .EnsureCorrectSelectedWifiNetworkPassword else {
            onComplete(.IllegalOperation)
            return
        }

        guard self.validateWifiNetworkPassword(password) else {
            onComplete(.WifiPasswordTooShort)
            return
        }

        self.log("trying password: \(password)")
        self.targetDevice!.transceiver?.sendJoinNewWifiNetwork(network: self.selectedWifiNetworkInfo!, password: password) {
            result in

            if (self.canceled) {
                return
            }

            self.log("targetDevice.sendJoinNewWifiNetwork: \(result.description())")
            if (result == .NONE) {
                onComplete(nil)
                self.stepComplete(.EnsureCorrectSelectedWifiNetworkPassword)
            } else if (result == .NOT_FOUND) {
                onComplete(.WrongNetworkPassword)
            } else {
                onComplete(.BluetoothTimeout)
            }
        }
    }




    //MARK: JoinSelectedNetwork
    private func stepJoinSelectedNetwork() {
        self.delegate.meshSetupDidEnterState(state: .JoiningNetworkStarted)
        /// NOT_ALLOWED: The client is not authenticated
        self.commissionerDevice!.transceiver!.sendStartCommissioner { result in
            self.log("commissionerDevice.sendStartCommissioner: \(result.description())")
            if (self.canceled) {
                return
            }
            if result == .NONE {
                self.prepareJoiner()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func prepareJoiner() {
        /// ALREADY_EXIST: The device is already a member of a network
        /// NOT_ALLOWED: The client is not authenticated
        self.targetDevice.transceiver!.sendPrepareJoiner(networkInfo: self.selectedNetworkMeshInfo!) { result, eui64, password in
            self.log("targetDevice.sendPrepareJoiner sent networkInfo: \(self.selectedNetworkMeshInfo!)")
            if (self.canceled) {
                return
            }
            self.log("targetDevice.sendPrepareJoiner: \(result.description())")
            if (result == .NONE) {
                self.targetDevice.joinerCredentials = (eui64: eui64!, password: password!)
                self.addJoiner()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func addJoiner() {
        self.delegate.meshSetupDidEnterState(state: .JoiningNetworkStep1Done)
        /// NO_MEMORY: No memory available to add the joiner
        /// INVALID_STATE: The commissioner role is not started
        /// NOT_ALLOWED: The client is not authenticated
        self.commissionerDevice!.transceiver!.sendAddJoiner(eui64: self.targetDevice.joinerCredentials!.eui64, password: self.targetDevice.joinerCredentials!.password) { result in
            self.log("commissionerDevice.sendAddJoiner: \(result.description())")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.log("Delaying call to joinNetwork")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    if (self.canceled) {
                        return
                    }

                    self.joinNetwork()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func joinNetwork() {
        self.log("Sending join network")
        /// NOT_FOUND: No joinable network was found
        /// TIMEOUT: The join process timed out
        /// NOT_ALLOWED: Invalid security credentials
        self.targetDevice.transceiver!.sendJoinNetwork { result in
            self.log("targetDevice.sendJoinNetwork: \(result.description())")
            if (self.canceled) {
                return
            }

            var failureReason: MeshSetupFlowError? = nil

            if (result == .NONE) {
                self.stepComplete(.JoinSelectedNetwork)
            } else if (result == .NOT_ALLOWED) {
                failureReason = .DeviceIsNotAllowedToJoinNetwork
            } else if (result == .NOT_FOUND) {
                failureReason = .DeviceIsUnableToFindNetworkToJoin
            } else if (result == .TIMEOUT) {
                failureReason = .DeviceTimeoutWhileJoiningNetwork
            } else {
                self.handleBluetoothErrorResult(result)
            }


            if let reason = failureReason {
                let recoveryLeaveNetwork = {
                    self.targetDevice.transceiver!.sendLeaveNetwork() { result in
                        self.log("targetDevice.sendLeaveNetwork: \(result.description())")
                        if (self.canceled) {
                            return
                        }

                        self.fail(withReason: reason)
                        return
                    }
                }

                self.commissionerDevice!.transceiver!.sendStopCommissioner { result in
                    self.log("commissionerDevice.sendStopCommissioner: \(result.description())")
                    if (self.canceled) {
                        return
                    }

                    if (result == .NONE) {
                        recoveryLeaveNetwork()
                    } else {
                        //if there's one more error here, do not display message cause that
                        //most likely won't be handeled properly anyway
                        self.fail(withReason: reason)
                        return
                    }
                }
            }
         }
    }


    //MARK: FinishJoinNetwork
    private func stepFinishJoinSelectedNetwork() {
        self.joinNetworkInAPI()
    }

    private func joinNetworkInAPI() {
        ParticleCloud.sharedInstance().addDevice(self.targetDevice.deviceId!, toNetwork: self.targetDevice.meshNetworkInfo!.networkID) {
            error in

            if (self.canceled) {
                return
            }

            self.log("addDevice error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToJoinNetwork, nsError: error)
                return
            }

            self.stopCommissioner()
        }
    }

    private func stopCommissioner() {
        self.delegate.meshSetupDidEnterState(state: .JoiningNetworkStep2Done)
        /// NOT_ALLOWED: The client is not authenticated
        self.commissionerDevice!.transceiver!.sendStopCommissioner { result in
            self.log("commissionerDevice.sendStopCommissioner: \(result.description())")
            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                self.setTargetDeviceSetupDone {
                    self.stopCommissionerListening()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
         }
    }

    private func setTargetDeviceSetupDone(onComplete: @escaping () -> ()) {
        self.targetDevice.transceiver!.sendDeviceSetupDone (done: true) { result in
            self.log("targetDevice.sendDeviceSetupDone: \(result.description())")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                onComplete()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func stopCommissionerListening() {
        self.commissionerDevice!.transceiver!.sendStopListening { result in
            self.log("commissionerDevice.sendStopListening: \(result.description())")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.stopTargetDeviceListening {
                    self.stepComplete(.FinishJoinSelectedNetwork)
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func stopTargetDeviceListening(onComplete: @escaping () -> ()) {
        self.targetDevice.transceiver!.sendStopListening { result in
            self.log("targetDevice.sendStopListening: \(result.description())")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                onComplete()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    //MARK: CheckDeviceGotClaimed
    private func checkTargetDeviceGotConnected() {
        if (self.currentStepFlags["checkTargetDeviceGotConnectedStartTime"] == nil) {
            self.currentStepFlags["checkTargetDeviceGotConnectedStartTime"] = Date()
        }

        let diff = Date().timeIntervalSince(self.currentStepFlags["checkTargetDeviceGotConnectedStartTime"] as! Date)
        if (diff > MeshSetup.deviceConnectToCloudTimeout) {
            self.fail(withReason: .DeviceConnectToCloudTimeout)
            return
        }

        self.targetDevice.transceiver!.sendGetConnectionStatus { result, status in
            self.log("targetDevice.sendGetConnectionStatus: \(result.description())")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.log("status: \(status as Optional)")
                if (status! == .connected) {
                    self.log("device connected to the cloud")
                    if (self.currentFlow == self.ethernetFlow || self.currentFlow == self.wifiFlow) {
                        self.delegate.meshSetupDidEnterState(state: .TargetDeviceConnectingToInternetStep1Done)
                    } else if (self.currentFlow == self.cellularFlow) {
                        self.delegate.meshSetupDidEnterState(state: .TargetDeviceConnectingToInternetStep2Done)
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        if (self.canceled) {
                            return
                        }
                        self.checkTargetDeviceGotClaimed()
                    }
                } else {
                    self.log("device did NOT connect yet")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
                        if (self.canceled) {
                            return
                        }
                        self.checkTargetDeviceGotConnected()
                    }
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkTargetDeviceGotClaimed() {
        if let isClaimed = self.targetDevice.isClaimed, isClaimed == true {
            self.deviceGotClaimed()
            return
        }

        if (self.currentStepFlags["checkTargetDeviceGotClaimedStartTime"] == nil) {
            self.currentStepFlags["checkTargetDeviceGotClaimedStartTime"] = Date()
        }

        let diff = Date().timeIntervalSince(self.currentStepFlags["checkTargetDeviceGotClaimedStartTime"] as! Date)
        if (diff > MeshSetup.deviceGettingClaimedTimeout) {
            fail(withReason: .DeviceGettingClaimedTimeout)
            return
        }

        ParticleCloud.sharedInstance().getDevices { devices, error in
            if (self.canceled) {
                return
            }

            guard error == nil else {
                self.fail(withReason: .DeviceGettingClaimedTimeout, nsError: error!)
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == self.targetDevice.deviceId!) {
                        self.targetDevice.name = device.name
                        self.deviceGotClaimed()
                        return
                    }
                }
            }

            self.log("device was NOT successfully claimed")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.checkTargetDeviceGotClaimed()
            }
        }
    }

    private func deviceGotClaimed() {
        self.log("device was successfully claimed")
        if (self.currentFlow == self.ethernetFlow || self.currentFlow == self.wifiFlow || self.currentFlow == self.cellularFlow) {
            self.delegate.meshSetupDidEnterState(state: .TargetDeviceConnectingToInternetCompleted)
        } else if (self.currentFlow == self.joinerFlow) {
            self.delegate.meshSetupDidEnterState(state: .JoiningNetworkCompleted)
        }
        self.stepComplete(.CheckDeviceGotClaimed)
    }


    //MARK: ShowGatewayInfo
    private func stepShowInfo() {
        //adding additional devices to same network
        if (self.selectedNetworkMeshInfo != nil) {
            self.stepComplete(.ShowInfo)
            return;
        }
        self.delegate.meshSetupDidRequestToShowInfo(gatewayFlow: self.targetDevice.hasActiveInternetInterface())
    }

    func setInfoDone() {
        self.stepComplete(.ShowInfo)
    }

    //MARK: ShowCellularInfo
    private func stepShowCellularInfo() {
        if (self.targetDevice.simActive != nil) {
            self.delegate.meshSetupDidRequestToShowCellularInfo(simActivated: self.targetDevice.simActive!)
            return
        }

        self.getSimInfo()
    }

    private func getSimInfo() {
        ParticleCloud.sharedInstance().checkSim(self.targetDevice.deviceICCID!) { simStatus, error in
            if (self.canceled) {
                return
            }

            self.log("simStatus: \(simStatus.rawValue), error: \(error)")

            if (error != nil) {
                if simStatus == ParticleSimStatus.notFound {
                    self.fail(withReason: .ExternalSimNotSupported, severity: .Fatal, nsError: error)
                } else if simStatus == ParticleSimStatus.notOwnedByUser {
                    self.fail(withReason: .SimBelongsToOtherAccount, severity: .Fatal, nsError: error)
                } else {
                    self.fail(withReason: .UnableToGetSimStatus, nsError: error)
                }
            } else {
                if simStatus == ParticleSimStatus.OK {
                    self.targetDevice.simActive = false
                    self.delegate.meshSetupDidRequestToShowCellularInfo(simActivated: self.targetDevice.simActive!)
                } else if simStatus == ParticleSimStatus.activated || simStatus == ParticleSimStatus.activatedFree {
                    self.targetDevice.simActive = true
                    self.delegate.meshSetupDidRequestToShowCellularInfo(simActivated: self.targetDevice.simActive!)
                } else {
                    self.fail(withReason: .UnableToGetSimStatus)
                }
            }
        }
    }

    func setCellularInfoDone() {
        self.stepComplete(.ShowCellularInfo)
    }



    //MARK: EnsureHasInternetAccess
    private func stepEnsureHasInternetAccess() {
        self.delegate.meshSetupDidEnterState(state: .TargetDeviceConnectingToInternetStarted)

        self.targetDevice.transceiver!.sendDeviceSetupDone (done: true) { result in
            self.log("targetDevice.transceiver!.sendDeviceSetupDone: \(result.description())")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                if self.currentFlow == self.cellularFlow {
                    self.activateSim()
                } else {
                    self.activateSimDone()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func activateSim() {
        if (self.targetDevice.simActive ?? false) {
            self.activateSimDone()
            return
        }

        if (self.currentStepFlags["checkSimActiveRetryCount"] == nil) {
            self.currentStepFlags["checkSimActiveRetryCount"] = 0
        } else {
            self.currentStepFlags["checkSimActiveRetryCount"] = (self.currentStepFlags["checkSimActiveRetryCount"] as! Int) + 1
        }

        let retries = self.currentStepFlags["checkSimActiveRetryCount"] as! Int

        if (retries > MeshSetup.activateSimRetryCount) {
            self.currentStepFlags["checkSimActiveRetryCount"] = nil
            self.fail(withReason: .FailedToActivateSim)
            return
        }

        ParticleCloud.sharedInstance().updateSim(self.targetDevice.deviceICCID!, action: .activate, dataLimit: nil, countryCode: nil, cardToken: nil) {
            error in

            if (self.canceled) {
                return
            }

            self.log("updateSim error: \(error)")

            if let nsError = error as? NSError, nsError.code == 504 {
                 self.log("activate sim returned 504, but that is fine :(")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    self.activateSim()
                }
            } else if (error != nil) {
                self.fail(withReason: .FailedToActivateSim, nsError: error!)
                return
            } else {
                self.targetDevice.simActive = true
                self.activateSimDone()
            }
        }
    }

    private func activateSimDone() {
        self.delegate.meshSetupDidEnterState(state: .TargetDeviceConnectingToInternetStep1Done)
        self.stopTargetDeviceListening {
            self.checkDeviceHasIP()
        }
    }

    private func checkDeviceHasIP() {
        if (self.currentStepFlags["checkDeviceHasIPStartTime"] == nil) {
            self.currentStepFlags["checkDeviceHasIPStartTime"] = Date()
        }

        let diff = Date().timeIntervalSince(self.currentStepFlags["checkDeviceHasIPStartTime"] as! Date)
        let limit = (self.currentFlow == self.cellularFlow) ? MeshSetup.deviceObtainedIPCellularTimeout : MeshSetup.deviceObtainedIPTimeout
        if (diff > limit) {
            self.currentStepFlags["checkDeviceHasIPStartTime"] = nil

            if let interface = self.targetDevice.activeInternetInterface, interface == .ppp {
                self.fail(withReason: .FailedToObtainIpBoron)
            } else {
                self.fail(withReason: .FailedToObtainIp)
            }
            return
        }

        self.targetDevice.transceiver!.sendGetInterface(interfaceIndex: self.targetDevice.getActiveNetworkInterfaceIdx()!) { result, interface in
            self.log("result: \(result.description()), networkInfo: \(interface as Optional)")
            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                if (interface?.ipv4Config.addresses.first != nil || interface?.ipv6Config.addresses.first != nil) {
                    self.targetDevice.hasInternetAddress = true
                    self.stepComplete(.EnsureHasInternetAccess)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        if (self.canceled) {
                            return
                        }
                        self.checkDeviceHasIP()
                    }
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    //MARK: StopTargetDeviceListening
    private func stepStopTargetDeviceListening() {
        self.stopTargetDeviceListening {
            self.stepComplete(.StopTargetDeviceListening)
        }
    }

    //MARK: CheckDeviceGotClaimed
    private func stepCheckDeviceGotClaimed() {
        self.checkTargetDeviceGotConnected()
    }

    //MARK: GetNewDeviceName
    private func stepGetNewDeviceName() {
        self.delegate.meshSetupDidRequestToEnterDeviceName()
    }

    func setDeviceName(name: String, onComplete:@escaping (MeshSetupFlowError?) -> ()) {
        guard currentCommand == .GetNewDeviceName else {
            onComplete(.IllegalOperation)
            return
        }

        guard self.validateDeviceName(name) else {
            onComplete(.NameTooShort)
            return
        }

        ParticleCloud.sharedInstance().getDevice(self.targetDevice.deviceId!) { device, error in
            if (self.canceled) {
                return
            }

            if (error == nil) {
                device!.rename(name) { error in
                    if error == nil {
                        self.targetDevice.name = name
                        onComplete(nil)
                        self.stepComplete(.GetNewDeviceName)
                    } else {
                        onComplete(.UnableToRenameDevice)
                        return
                    }
                }
            } else {
                onComplete(.UnableToRenameDevice)
                return
            }
        }
    }



    //MARK:OfferToAddOneMoreDevice
    private func stepOfferToAddOneMoreDevice() {
        //disconnect current device
        if (self.targetDevice.transceiver != nil) {
            self.log("Dropping connection to target device")
            let connection = self.targetDevice.transceiver!.connection
            self.targetDevice.transceiver = nil
            self.bluetoothManager.dropConnection(with: connection)
        }

        self.delegate.meshSetupDidRequestToAddOneMoreDevice()
    }


    func setAddOneMoreDevice(addOneMoreDevice: Bool) -> MeshSetupFlowError? {
        guard currentCommand == .OfferToAddOneMoreDevice else {
            return .IllegalOperation
        }

        if (addOneMoreDevice) {
            self.currentStep = 0
            self.currentFlow = preflow
            self.runCurrentStep()
        } else {
            self.finishSetup()
        }

        return nil
    }


    //MARK: OfferSetupStandAloneOrWithNetwork
    private func stepOfferSetupStandAloneOrWithNetwork() {
       self.delegate.didRequestToSelectStandAloneOrMeshSetup()
    }

    func setSelectStandAloneOrMeshSetup(meshSetup: Bool) -> MeshSetupFlowError? {
        guard currentCommand == .OfferSetupStandAloneOrWithNetwork else {
            return .IllegalOperation
        }

        self.userSelectedToSetupMesh = meshSetup
        self.stepComplete(.OfferSetupStandAloneOrWithNetwork)
        return nil
    }


    //MARK: OfferSelectOrCreateNetwork
//    private func stepOfferSelectOrCreateNetwork() {
//        //we might retry step because scan network failed.. so we only test for this condition and ignore password/name condition
//        //adding more devices to same network
//        if (self.selectedNetworkInfo != nil) {
//            self.stepComplete()
//            return
//        }
//
//        self.delegate.meshSetupDidEnterState(state: .TargetGatewayDeviceScanningForNetworks)
//        self.scanNetworks(onComplete: self.getUserMeshSetupChoice)
//    }
//
//    private func getUserMeshSetupChoice() {
//      //TODO: merge api networks with device mesh networks
//        self.delegate.meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: self.targetDevice.networks!)
//    }
//
//    func setSelectOrCreateNetwork(selectedNetworkExtPanID: String?) -> MeshSetupFlowError? {
////        guard currentCommand == .OfferSelectOrCreateNetwork else {
////            return .IllegalOperation
////        }
////
////        if let selectedNetwork = selectedNetwork {
////            self.selectedNetworkInfo = selectedNetwork
//}
//
//if (self.selectedNetworkAPIInfo == nil){
//    log("///////////////////////////////////// we are out of sync")
//}


////            self.stepComplete()
////        } else {
////            //TODO: split into three steps
////            self.delegate.meshSetupDidRequestToEnterNewNetworkNameAndPassword()
////        }
//
//        return nil
//    }


    //MARK: GetNewNetworkNameAndPassword
    private func stepGetNewNetworkNameAndPassword() {
        self.delegate.meshSetupDidRequestToEnterNewNetworkNameAndPassword()
    }


    func setNewNetworkName(name: String) -> MeshSetupFlowError? {
        guard currentCommand == .GetNewNetworkNameAndPassword else {
            return .IllegalOperation
        }

        guard self.validateNetworkName(name) else {
            return .NameTooShort
        }

        if let networks =  self.apiNetworks {
            for network in networks {
                if (network.name.lowercased() == name.lowercased()) {
                    return .NameInUse
                }
            }
        }


        self.log("set network name: \(name)")
        self.newNetworkName = name

        if (self.newNetworkName != nil && self.newNetworkPassword != nil) {
            self.stepComplete(.GetNewNetworkNameAndPassword)
        }

        return nil
    }


    func setNewNetworkPassword(password: String) -> MeshSetupFlowError? {
        guard currentCommand == .GetNewNetworkNameAndPassword else {
            return .IllegalOperation
        }

        guard self.validateNetworkPassword(password) else {
            return .PasswordTooShort
        }

        self.log("set network password: \(password)")
        self.newNetworkPassword = password

        if (self.newNetworkName != nil && self.newNetworkPassword != nil) {
            self.stepComplete(.GetNewNetworkNameAndPassword)
        }

        return nil
    }



    //MARK: CreateNetwork
    private func stepCreateNetwork() {
        self.delegate.meshSetupDidEnterState(state: .CreateNetworkStarted)

        if (self.newNetworkId == nil) {
            self.createNetworkInAPI()
        } else {
            self.createNetworkInMesh()
        }
    }

    private func createNetworkInAPI() {

        var networkType = ParticleNetworkType.microWifi
        if let interface = self.targetDevice.activeInternetInterface, interface == .ppp {
            networkType = ParticleNetworkType.microCellular
        }

        ParticleCloud.sharedInstance().createNetwork(self.newNetworkName!,
                gatewayDeviceID: self.targetDevice.deviceId!,
                gatewayDeviceICCID: networkType == .microCellular ? self.targetDevice.deviceICCID : nil,
                networkType: networkType) {
            network, error in
            if (self.canceled) {
                return
            }

            self.log("createNetwork: \(network as Optional), error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToCreateNetwork, nsError: error)
                return
            }

            if let network = network {
                self.newNetworkId = network.id

                self.delegate.meshSetupDidEnterState(state: .CreateNetworkStep1Done)
                self.createNetworkInMesh()
            }
        }
    }

    private func createNetworkInMesh() {
        self.targetDevice.transceiver!.sendCreateNetwork(name: self.newNetworkName!, password: self.newNetworkPassword!, networkId: self.newNetworkId!) {
            result, networkInfo in

            self.log("targetDevice.sendCreateNetwork: \(result.description()), networkInfo: \(networkInfo as Optional)")
            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                self.log("Setting current target device as commissioner device part 1")
                self.selectedNetworkMeshInfo = networkInfo!
                self.selectedNetworkPassword = self.newNetworkPassword

                self.delegate.meshSetupDidCreateNetwork(network: MeshSetupNetworkCellInfo(name: networkInfo!.name, extPanID: networkInfo!.extPanID, userOwned: true, deviceCount: 1))

                self.setTargetDeviceSetupDone {
                    self.setTargetDeviceAsCommissioner()
                    self.delegate.meshSetupDidEnterState(state: .CreateNetworkCompleted)
                    self.stepComplete(.CreateNetwork)
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func setTargetDeviceAsCommissioner() {
        self.log("Setting current target device as commissioner device part 2")
        self.commissionerDevice = self.targetDevice
        self.targetDevice = MeshDevice()
    }



    //MARK: EnsureCorrectEthernetFeatureStatus
    func stepEnsureCorrectEthernetFeatureStatus() {
        self.targetDevice.transceiver!.sendGetFeature(feature: .ethernetDetection) { result, enabled in
            self.log("targetDevice.sendGetFeature: \(result.description()) enabled: \(enabled as Optional)")
            self.log("self.targetDevice.enableEthernetFeature = \(self.targetDevice.enableEthernetFeature)")
            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                if (self.targetDevice.enableEthernetFeature == enabled) {
                    self.stepComplete(.EnsureCorrectEthernetFeatureStatus)
                } else {
                    self.setCorrectEthernetFeatureStatus()
                }
            } else if (result == .NOT_SUPPORTED) {
                self.stepComplete(.EnsureCorrectEthernetFeatureStatus)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    func setCorrectEthernetFeatureStatus() {
        self.targetDevice.transceiver!.sendSetFeature(feature: .ethernetDetection, enabled: self.targetDevice.enableEthernetFeature!) { result  in
            self.log("targetDevice.sendSetFeature: \(result.description())")
            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                self.prepareForTargetDeviceReboot {
                    self.sendDeviceReset()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    func prepareForTargetDeviceReboot(onComplete: @escaping () -> ()) {
        self.targetDevice.transceiver!.sendSetStartupMode(startInListeningMode: true) { result in
            self.log("targetDevice.sendSetStartupMode: \(result.description())")
            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                onComplete()
            } else if (result == .NOT_SUPPORTED) {
                onComplete()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    func sendDeviceReset() {
        self.targetDevice.transceiver!.sendSystemReset() { result  in
            self.log("targetDevice.sendSystemReset: \(result.description())")
            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                //if all is fine, connection will be dropped and the setup will return few steps in dropped connection handler
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    //MARK: ShowPricingImpact
    private func stepShowPricingImpact() {
        //if it's boron, get iccid first
        if (self.targetDevice.type! == .boron &&
                self.targetDevice.activeInternetInterface != nil &&
                self.targetDevice.activeInternetInterface! == .ppp &&
                self.targetDevice.deviceICCID == nil) {
            self.getTargetDeviceICCID()
            return
        }

        self.getPricingImpact()
    }

    private func getTargetDeviceICCID() {
        self.log("getting iccid")
        self.targetDevice.transceiver!.sendGetIccid () { result, iccid in
            self.log("targetDevice.transceiver!.sendGetIccid: \(result.description()), iccid: \(iccid as Optional)")
            if (self.canceled) {
                return
            }

            if (result == .NONE) {
                self.targetDevice.deviceICCID = iccid!
                self.getPricingImpact()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func getPricingImpact() {
        //if standalone or joiner

        //joiner flow
        var action = ParticlePricingImpactAction.addNetworkDevice
        if (self.userSelectedToSetupMesh != nil){
            //standalone or network
            action = self.userSelectedToSetupMesh! ? .createNetwork : .addUserDevice
        }

        var networkType = ParticlePricingImpactNetworkType.wifi
        if let interface = self.targetDevice.activeInternetInterface, interface == .ppp {
            networkType = ParticlePricingImpactNetworkType.cellular
        }

        ParticleCloud.sharedInstance().getPricingImpact(action,
                deviceID: self.targetDevice.deviceId!,
                networkID: self.selectedNetworkMeshInfo?.networkID,
                networkType: networkType,
                iccid: self.targetDevice.deviceICCID)
        {
            pricingInfo, error in

            if (self.canceled) {
                return
            }

            self.log("getPricingImpact: \(pricingInfo), error: \(error)")

            if (error != nil) {
                self.fail(withReason: .UnableToGetPricingInformation, nsError: error)
                return
            }

            if (pricingInfo!.chargeable == false) {
                self.pricingRequirementsAreMet = true
            } else {
                self.pricingRequirementsAreMet = pricingInfo!.ccOnFile == true
            }

            self.delegate.meshSetupDidRequestToShowPricingInfo(info: pricingInfo!)
        }
    }

    func setPricingImpactDone() -> MeshSetupFlowError? {
        guard currentCommand == .ShowPricingImpact else {
            return .IllegalOperation
        }

        if (!(self.pricingRequirementsAreMet ?? false)) {
            return .CCMissing
        }

        self.stepComplete(.ShowPricingImpact)
        return nil
    }
}


extension MeshSetupFlowManager {
    //MARK: BLE OTA Update


    //Slave Latency ≤ 30
    //2 seconds ≤ connSupervisionTimeout ≤ 6 seconds
    //Interval Min modulo 15 ms == 0
    //Interval Min ≥ 15 ms
    //
    //One of the following:
    //  Interval Min + 15 ms ≤ Interval Max
    //  Interval Min == Interval Max == 15 ms
    //
    //Interval Max * (Slave Latency + 1) ≤ 2 seconds
    //Interval Max * (Slave Latency + 1) * 3 <connSupervisionTimeout

    //MARK: EnsureLatestFirmware
    private func stepEnsureLatestFirmware() {


        if (self.targetDevice.firmwareVersion != nil) {
            self.checkTargetDeviceSupportsCompressedOTA()
            return
        }

        self.targetDevice.transceiver!.sendGetSystemVersion { result, version in
            self.log("targetDevice.sendGetSystemVersion: \(result.description()), version: \(version as Optional)")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.targetDevice.firmwareVersion = version!
                self.checkTargetDeviceSupportsCompressedOTA()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    private func checkTargetDeviceSupportsCompressedOTA() {
        if (self.targetDevice.supportsCompressedOTAUpdate != nil) {
            self.checkNcpFirmwareVersion()
            return
        }

        self.targetDevice.transceiver!.sendGetSystemCapabilities { result, capability in
            self.log("targetDevice.sendGetSystemCapabilities: \(result.description()), capability: \(capability?.rawValue as Optional)")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.targetDevice.supportsCompressedOTAUpdate = (capability! == MeshSetupSystemCapability.compressedOta)
                self.checkNcpFirmwareVersion()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkNcpFirmwareVersion() {
        if (self.targetDevice.ncpVersion != nil && self.targetDevice.ncpModuleVersion != nil) {
            self.checkTargetDeviceIsSetupDone()
            return
        }

        self.targetDevice.transceiver!.sendGetNcpFirmwareVersion { result, version, moduleVersion in
            self.log("targetDevice.sendGetNcpFirmwareVersion: \(result.description()), version: \(version as Optional), moduleVersion: \(moduleVersion)")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.targetDevice.ncpVersion = version!
                self.targetDevice.ncpModuleVersion = moduleVersion!

                self.checkTargetDeviceIsSetupDone()
            } else if (result == .NOT_SUPPORTED) {
                self.targetDevice.ncpVersion = nil
                self.targetDevice.ncpModuleVersion = nil

                self.checkTargetDeviceIsSetupDone()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkTargetDeviceIsSetupDone() {
        //if this has already been checked for this device
        if (self.targetDevice.isSetupDone != nil) {
            self.checkNeedsOTAUpdate()
            return
        }

        self.targetDevice.transceiver!.sendIsDeviceSetupDone { result, isSetupDone in
            self.log("targetDevice.sendIsDeviceSetupDone: \(result.description()), isSetupDone: \(isSetupDone as Optional)")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.targetDevice.isSetupDone = isSetupDone
                self.checkNeedsOTAUpdate()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkNeedsOTAUpdate() {
        if (self.targetDevice.nextFirmwareBinaryURL != nil) {
            self.binaryURLReady()
            return
        }


        ParticleCloud.sharedInstance().getNextBinaryURL(targetDevice.type!,
                currentSystemFirmwareVersion: targetDevice.firmwareVersion!,
                currentNcpFirmwareVersion: targetDevice.ncpVersion,
                currentNcpFirmwareModuleVersion: targetDevice.ncpModuleVersion != nil ? NSNumber(value: targetDevice.ncpModuleVersion!) : nil)
        { url, error in
            if (self.canceled) {
                return
            }

            self.log("getNextBinaryURL: \(url), error: \(error)")
            if let url = url {
                self.targetDevice.nextFirmwareBinaryURL = url
                self.binaryURLReady()
            } else if (error == nil) {
                if let filesFlashed = self.targetDevice.firmwareFilesFlashed, filesFlashed > 0 {
                    self.delegate.meshSetupDidEnterState(state: .FirmwareUpdateComplete)
                }
                self.stepComplete(.EnsureLatestFirmware)
                return
            } else {
                self.fail(withReason: .FailedToUpdateDeviceOS, nsError: error)
            }
        }
    }

    private func binaryURLReady() {
        if (self.userSelectedToUpdateFirmware == nil) {
            self.delegate.meshSetupDidRequestToUpdateFirmware()
        } else {
            self.setTargetPerformFirmwareUpdate(update: self.userSelectedToUpdateFirmware!)
        }
    }

    func setTargetPerformFirmwareUpdate(update: Bool) -> MeshSetupFlowError? {
        guard currentCommand == .EnsureLatestFirmware else {
            return .IllegalOperation
        }

        self.userSelectedToUpdateFirmware = update
        self.log("userSelectedToUpdateFirmware: \(update)")

        self.prepareForTargetDeviceReboot {
            self.prepareOTABinary()
        }

        return nil
    }

    private func prepareOTABinary() {
        if (self.targetDevice.nextFirmwareBinaryURL == nil){
            self.stepComplete(.EnsureLatestFirmware)
            return
        }


        if (self.targetDevice.nextFirmwareBinaryFilePath != nil) {
            self.startFirmwareUpdate()
            return
        }

        ParticleCloud.sharedInstance().getNextBinary(self.targetDevice.nextFirmwareBinaryURL!)
        { url, error in
            if (self.canceled) {
                return
            }

            self.log("prepareOTABinary: \(url), error: \(error)")

            guard error == nil else {
                self.fail(withReason: .UnableToDownloadFirmwareBinary, nsError: error)
                return
            }

            if let url = url {
                self.targetDevice.nextFirmwareBinaryFilePath = url
                self.startFirmwareUpdate()
            }
        }
    }

    private func startFirmwareUpdate() {
        self.log("Starting firmware update")

        let firmwareData = try! Data(contentsOf: URL(string: self.targetDevice.nextFirmwareBinaryFilePath!)!)

        self.targetDevice.firmwareUpdateProgress = 0
        self.delegate.meshSetupDidEnterState(state: .FirmwareUpdateProgress)

        self.currentStepFlags["firmwareData"] = firmwareData
        self.targetDevice.transceiver!.sendStartFirmwareUpdate(binarySize: firmwareData.count) { result, chunkSize in
            self.log("targetDevice.sendStartFirmwareUpdate: \(result.description()), chunkSize: \(chunkSize)")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.currentStepFlags["chunkSize"] = Int(chunkSize)
                self.currentStepFlags["idx"] = 0

                if (self.targetDevice.firmwareFilesFlashed == nil) {
                    self.targetDevice.firmwareFilesFlashed = 0
                }

                self.sendFirmwareUpdateChunk()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func sendFirmwareUpdateChunk() {
        let chunk = self.currentStepFlags["chunkSize"] as! Int
        let idx = self.currentStepFlags["idx"] as! Int
        let firmwareData = self.currentStepFlags["firmwareData"] as! Data

        let start = idx*chunk
        let bytesLeft = firmwareData.count - start


        self.targetDevice.firmwareUpdateProgress = 100.0 * (Double(start) / Double(firmwareData.count))
        self.delegate.meshSetupDidEnterState(state: .FirmwareUpdateProgress)

        self.log("bytesLeft: \(bytesLeft)")

        let subdata = firmwareData.subdata(in: start ..< min(start+chunk, start+bytesLeft))
        self.targetDevice.transceiver!.sendFirmwareUpdateData(data: subdata) { result in
            self.log("targetDevice.sendFirmwareUpdateData: \(result.description())")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                if ((idx+1) * chunk >= firmwareData.count) {
                    self.finishFirmwareUpdate()
                    self.targetDevice.firmwareFilesFlashed! += 1
                    self.delegate.meshSetupDidEnterState(state: .FirmwareUpdateFileComplete)
                } else {
                    self.currentStepFlags["idx"] = idx + 1
                    self.sendFirmwareUpdateChunk()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func finishFirmwareUpdate() {
        self.targetDevice.transceiver!.sendFinishFirmwareUpdate(validateOnly: false) { result in
            self.log("targetDevice.sendFinishFirmwareUpdate: \(result.description())")
            if (self.canceled) {
                return
            }
            if (result == .NONE) {
                self.resetFirmwareFlashFlags()
                //reconnect to device by jumping back few steps in connection dropped handler
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func resetFirmwareFlashFlags() {
        //reset all the important flags
        self.targetDevice.firmwareVersion = nil
        self.targetDevice.ncpVersion = nil
        self.targetDevice.ncpModuleVersion = nil
        self.targetDevice.supportsCompressedOTAUpdate = nil
        self.targetDevice.nextFirmwareBinaryURL = nil
        self.targetDevice.nextFirmwareBinaryFilePath = nil

    }
}
