//
//  MeshSetupFlowManager.swift
//  Particle
//
//  Created by Ido Kleinman on 7/3/18.
//  Maintained by Raimundas Sakalauskas
//  Copyright © 2018 Particle. All rights reserved.
//

import Foundation





//delegate required to request / deliver information from / to the UI
protocol MeshSetupFlowManagerDelegate {
    typealias MeshSetupSetDevice = (MeshSetupDataMatrix) -> ()
    typealias MeshSetupSetNetwork = (MeshSetupNetworkInfo) -> ()
    typealias MeshSetupSetNetworkOptional = (MeshSetupNetworkInfo?) -> ()
    typealias MeshSetupSetBool = (Bool) -> ()
    typealias MeshSetupSetString = (String) -> ()


    func meshSetupDidRequestInitialDeviceInfo(setInitialDeviceInfo: @escaping MeshSetupSetDevice)
    func meshSetupDidRequestToLeaveNetwork(network: MeshSetupNetworkInfo, setLeaveNetwork: @escaping MeshSetupSetBool)
    func meshSetupDidRequestToSelectNetwork(availableNetworks: [MeshSetupNetworkInfo], setSelectedNetwork: @escaping MeshSetupSetNetwork)

    func meshSetupDidRequestCommissionerDeviceInfo(setCommissionerDeviceInfo: @escaping MeshSetupSetDevice)
    func meshSetupDidRequestToEnterSelectedNetworkPassword(setSelectedNetworkPassword: @escaping MeshSetupSetString)


    func meshSetupDidRequestToEnterDeviceName(setDeviceName: @escaping MeshSetupSetString)
    func meshSetupDidRequestToAddOneMoreDevice(setAddOneMoreDevice: @escaping MeshSetupSetBool)

    func meshSetupDidRequestToFinishSetupEarly(setFinishSetupEarly: @escaping MeshSetupSetBool) //before setting mesh network
    func meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: [MeshSetupNetworkInfo], setSelectedNetwork: @escaping MeshSetupSetNetworkOptional)

    func meshSetupDidRequestToEnterNewNetworkName(setNewNetworkName: @escaping MeshSetupSetString)
    func meshSetupDidRequestToEnterNewNetworkPassword(setNewNetworkPassword: @escaping MeshSetupSetString)


    func meshSetupDidRequestToChooseBetweenRetryInternetOrSwitchToJoinerFlow(setSwitchToJoiner: @escaping MeshSetupSetBool)


    func meshSetupDidEnterState(state: MeshSetupFlowState)
    func meshSetupError(error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?)
}

enum MeshSetupFlowState {
    case InitialDeviceConnecting
    case InitialDeviceConnected
    case InitialDeviceReady

    case CommissionerDeviceConnecting
    case CommissionerDeviceConnected
    case CommissionerDeviceReady

    case SetupComplete
}

enum MeshSetupFlowError: Error {
    //EnsureInitialDeviceCanBeClaimed
    case UnableToGenerateClaimCode

    //ConnectToInitialDevice && ConnectToCommissionerDevice
    case DeviceTooFar
    case FailedToStartScan
    case FailedToScanBecauseOfTimeout
    case FailedToConnect

    //Scanned device is on the network. Offer setup options when those will be implemented
    case UserRefusedToLeaveMeshNetwork

    //Can happen in any step, inform user about it and repeat the step
    case BluetoothDisabled

    //Can happen in any step, when result != NONE and special case is not handled by onReply handler
    case BluetoothError

    //EnsureCommissionerNetworkMatches
    case CommissionerNetworkDoesNotMatch

    //GetNewDeviceName
    case UnableToRenameDevice

    //CheckDeviceGotClaimed
    case DeviceConnectToCloudTimeout
    case DeviceGettingClaimedTimeout
    case UnableToGetDeviceList
}

fileprivate struct MeshDevice {
    var type: ParticleDeviceType?
    var deviceId: String?
    var credentials: MeshSetupPeripheralCredentials?

    var transceiver: MeshSetupProtocolTransceiver?

    var claimCode: String?
    var isClaimed: Bool?
    var isSetupDone: Bool?
    var supportsCompressedOTAUpdate: Bool?

    var hasInternetCapableNetworkInterfaces: Bool?
    var hasInternetAddress: Bool?

    var networkInterfaces: [MeshSetupNetworkInterfaceEntry]?
    var joinerCredentials: (eui64: String, password: String)?

    var networkInfo: MeshSetupNetworkInfo?
    var networks: [MeshSetupNetworkInfo]?

    func getEthernetInterfaceIdx() -> UInt32? {
        if let interfaces = networkInterfaces {
            for interface in interfaces {
                if interface.type == .ethernet {
                    return interface.index
                }
            }
        }
        return nil
    }
}


class MeshSetupFlowManager: NSObject, MeshSetupBluetoothConnectionManagerDelegate {

    private enum MeshSetupFlowCommands {
        //preflow
        case GetInitialDeviceInfo
        case ConnectToInitialDevice
        case EnsureLatestFirmware
        case EnsureInitialDeviceCanBeClaimed
        case CheckInitialDeviceHasNetworkInterfaces
        case ChooseFlow

        //main flow
        case SetClaimCode
        case EnsureInitialDeviceIsNotOnMeshNetwork
        case GetUserNetworkSelection
        case GetCommissionerDeviceInfo
        case ConnectToCommissionerDevice
        case EnsureCommissionerNetworkMatches
        case EnsureCorrectSelectedNetworkPassword
        case JoinSelectedNetwork
        case GetNewDeviceName
        case OfferToAddOneMoreDevice

        //gateway
        case EnsureHasInternetAccess
        case CheckDeviceGotClaimed
        case StopInitialDeviceListening
        case OfferToFinishSetupEarly
        case OfferSelectOrCreateNetwork
        case ChooseSubflow

        case CreateNetwork
    }

    private let preflow: [MeshSetupFlowCommands] = [
        .GetInitialDeviceInfo,
        .ConnectToInitialDevice,
        .EnsureLatestFirmware,
        .EnsureInitialDeviceCanBeClaimed,
        .CheckInitialDeviceHasNetworkInterfaces,
        .ChooseFlow
    ]


    private let joinerFlow: [MeshSetupFlowCommands] = [
        .SetClaimCode,
        .EnsureInitialDeviceIsNotOnMeshNetwork,
        .GetUserNetworkSelection,
        .GetCommissionerDeviceInfo,
        .ConnectToCommissionerDevice,
        .EnsureCommissionerNetworkMatches,
        .EnsureCorrectSelectedNetworkPassword,
        .JoinSelectedNetwork,
        .CheckDeviceGotClaimed,
        .GetNewDeviceName,
        .OfferToAddOneMoreDevice
    ]



    private let gatewayFlow: [MeshSetupFlowCommands] = [
        .SetClaimCode,
        .EnsureInitialDeviceIsNotOnMeshNetwork,
        .EnsureHasInternetAccess,
        .StopInitialDeviceListening,
        .CheckDeviceGotClaimed,
        .GetNewDeviceName,
        .OfferToFinishSetupEarly,
        .OfferSelectOrCreateNetwork,
        .ChooseSubflow
    ]


    private let joinerSubflow: [MeshSetupFlowCommands] = [
        .GetCommissionerDeviceInfo,
        .ConnectToCommissionerDevice,
        .EnsureCommissionerNetworkMatches,
        .EnsureCorrectSelectedNetworkPassword,
        .JoinSelectedNetwork,
        .OfferToAddOneMoreDevice
    ]

    private let creatorSubflow: [MeshSetupFlowCommands] = [
        .CreateNetwork,
        .OfferToAddOneMoreDevice
    ]



    var delegate: MeshSetupFlowManagerDelegate

    private var bluetoothManager: MeshSetupBluetoothConnectionManager!
    private var bluetoothReady: Bool = false


    private var initialDevice: MeshDevice!
    private var commissionerDevice: MeshDevice?

    //for joining flow
    private var selectedNetworkInfo: MeshSetupNetworkInfo?
    private var selectedNetworkPassword: String?

    //for creating flow
    private var newNetworkName: String?
    private var newNetworkPassword: String?

    //to prevent long running actions from executing
    private var canceled = false


    private var currentFlow: [MeshSetupFlowCommands]!
    private var currentStep: Int = 0
    private var currentStepFlags: [String: Any]! //if there's shared data needed to properly run the step
    private var currentCommand: MeshSetupFlowCommands {
        return currentFlow[currentStep]
    }

    init(delegate: MeshSetupFlowManagerDelegate) {
        self.delegate = delegate
        super.init()
        self.bluetoothManager = MeshSetupBluetoothConnectionManager(delegate: self)
    }


    private func log(_ message: String) {
        if (MeshSetup.LogFlowManager) {
            NSLog("MeshSetupFlow: \(message)")
        }
    }

    private func fail(withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity = .Error, nsError: Error? = nil) {
        log("error: \(reason.localizedDescription), nsError: \(nsError?.localizedDescription as Optional)")
        self.delegate.meshSetupError(error: reason, severity: severity, nsError: nsError)
    }

    //MARK: Flow control
    //entry to the flow
    func startSetup() {
        currentFlow = preflow
        currentStep = 0

        self.runCurrentStep()
    }

    //public interface
    func cancelSetup() {
        //if we are waiting for the reply = trigger timeout
        if let initialDeviceTransceiver = self.initialDevice.transceiver {
            initialDeviceTransceiver.triggerTimeout()
        }

        //if we are waiting for the reply = trigger timeout
        if let commissionerDeviceTransceiver = self.commissionerDevice?.transceiver {
            commissionerDeviceTransceiver.triggerTimeout()
        }

        self.bluetoothManager.stopScan()
        self.bluetoothManager.dropAllConnections()
    }

    func retryLastAction() {
        self.runCurrentStep()
    }

    private func runCurrentStep() {
        log("stepComplete\n\n" +
                "--------------------------------------------------------------------------------------------\n" +
                "currentStep = \(currentStep), currentCommand = \(currentCommand)")
        self.currentStepFlags = [:]
        switch self.currentCommand {
            //preflow
            case .GetInitialDeviceInfo:
                self.stepGetInitialDeviceInfo()
            case .ConnectToInitialDevice:
                self.stepConnectToInitialDevice()
            case .EnsureLatestFirmware:
                self.stepEnsureLatestFirmware()
            case .EnsureInitialDeviceCanBeClaimed:
                self.stepEnsureInitialDeviceCanBeClaimed()
            case .CheckInitialDeviceHasNetworkInterfaces:
                self.stepCheckInitialDeviceHasNetworkInterfaces()
            case .ChooseFlow:
                 self.stepChooseFlow()

            //main flow
            case .SetClaimCode:
                self.stepSetClaimCode()
            case .EnsureInitialDeviceIsNotOnMeshNetwork:
                self.stepEnsureInitialDeviceIsNotOnMeshNetwork()
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
            case .GetNewDeviceName:
                self.stepGetNewDeviceName()
            case .OfferToAddOneMoreDevice:
                self.stepOfferToAddOneMoreDevice()

            //gateway
            case .EnsureHasInternetAccess:
                self.stepEnsureHasInternetAccess()
            case .StopInitialDeviceListening:
                self.stepStopInitialDeviceListening()
            case .CheckDeviceGotClaimed:
                 self.stepCheckDeviceGotClaimed()
            case .OfferToFinishSetupEarly:
                self.stepOfferToFinishSetupEarly()
            case .OfferSelectOrCreateNetwork:
                self.stepOfferSelectOrCreateNetwork()
            case .ChooseSubflow:
                self.stepChooseSubflow()

            case .CreateNetwork:
                self.stepCreateNetwork()

            default:
                log("Unknown command: \(currentFlow[currentStep])")
            }
    }

    private func stepComplete() {
        if (self.canceled) {
            return
        }

        self.currentStep += 1
        self.runCurrentStep()
    }


    //end of preflow
    private func stepChooseFlow() {
        log("preflow completed")
        //jump to new flow
        self.currentStep = 0
        if (self.initialDevice.hasInternetCapableNetworkInterfaces!) {
            self.currentFlow = gatewayFlow
            log("setting gateway flow")
        } else {
            self.currentFlow = joinerFlow
            log("setting joiner flow")
        }
        self.runCurrentStep()
    }

    private func stepChooseSubflow() {
        self.currentStep = 0
        if newNetworkPassword != nil && newNetworkPassword != nil {
            log("subflow: creator")
            self.currentFlow = creatorSubflow
        } else {
            log("subflow: joiner")
            self.currentFlow = joinerSubflow
        }
        self.runCurrentStep()
    }

    private func removeRepeatedNetworks(_ networks: [MeshSetupNetworkInfo]) -> [MeshSetupNetworkInfo] {
        var ids:Set<String> = []
        var filtered:[MeshSetupNetworkInfo] = []

        for network in networks {
            if (!ids.contains(network.extPanID)) {
                ids.insert(network.extPanID)
                filtered.append(network)
            }
        }

        return filtered
    }

    private func getDeviceType(serialNumber: String) -> ParticleDeviceType? {
        self.log("serialNumber: \(serialNumber)")
        if (serialNumber.lowercased().range(of: "xen")?.lowerBound == serialNumber.startIndex) {
            return .xenon
        } else if (serialNumber.lowercased().range(of: "arg")?.lowerBound == serialNumber.startIndex) {
            return .argon
        } else if (serialNumber.lowercased().range(of: "brn")?.lowerBound == serialNumber.startIndex) {
            return .boron
        } else {
            return nil
        }
    }

    private func handleBluetoothErrorResult(_ result: ControlReplyErrorType) {
        if (self.canceled) {
            return
        }

        if (result == .TIMEOUT && !self.bluetoothReady) {
            self.fail(withReason: .BluetoothDisabled)
            return
        } else {
            self.fail(withReason: .BluetoothError)
        }
    }

    //MARK: BluetoothConnectionManagerDelegate
    func bluetoothConnectionManagerStateChanged(sender: MeshSetupBluetoothConnectionManager, state: MeshSetupBluetoothConnectionManagerState) {
        log("bluetoothConnectionManagerStateChanged = \(state)")
        if (self.bluetoothManager.state == .Ready) {
            self.bluetoothReady = true
        } else if (self.bluetoothManager.state == .Disabled) {
            self.bluetoothReady = false

            //if we are waiting for the reply = trigger timeout
            if let initialDeviceTransceiver = self.initialDevice.transceiver {
                initialDeviceTransceiver.triggerTimeout()
            }

            //if we are waiting for the reply = trigger timeout
            if let commissionerDeviceTransceiver = self.commissionerDevice?.transceiver {
                commissionerDeviceTransceiver.triggerTimeout()
            }
        }
        //other states are really temporary.
    }

    func bluetoothConnectionManagerError(sender: MeshSetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity) {
        log("bluetoothConnectionManagerError = \(error), severity = \(severity)")
        if (self.currentCommand == .ConnectToInitialDevice || self.currentCommand == .ConnectToCommissionerDevice) {
            if (error == .DeviceWasConnected) {
                self.currentStepFlags["reconnect"] = true
                //this will be used in connection dropped to restart the step
            } else if (error == .DeviceTooFar) {
                self.fail(withReason: .DeviceTooFar)
                //after showing promt, step should be repeated
            } else if (error == .FailedToScanBecauseOfTimeout && self.currentStepFlags["reconnectAfterFirmwareFlash"] != nil) {
                //coming online after a flash might take a while, if for some reason we timeout, we should retry the step
                self.stepConnectToInitialDevice()
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
            //TODO: remove this for production
            fatalError("bluetoothConnectionManagerError shouldn't happen in any other step: \(error)")
        }
    }

    func bluetoothConnectionManagerConnectionCreated(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.currentCommand == .ConnectToInitialDevice) {
            self.delegate.meshSetupDidEnterState(state: .InitialDeviceConnected)
        } else if (self.currentCommand == .ConnectToCommissionerDevice) {
            self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceConnected)
        } else {
            //TODO: remove this for production
            fatalError("bluetoothConnectionManagerConnectionCreated shouldn't happen in any other step: \(connection)")
        }
    }

    func bluetoothConnectionManagerConnectionBecameReady(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.currentCommand == .ConnectToInitialDevice) {
            self.delegate.meshSetupDidEnterState(state: .InitialDeviceReady)
            self.initialDeviceConnected(connection: connection)
        } else if (self.currentCommand == .ConnectToCommissionerDevice) {
            self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceReady)
            self.commissionerDeviceConnected(connection: connection)
        } else {
            //TODO: remove this for production
            fatalError("bluetoothConnectionManagerConnectionBecameReady shouldn't happen in any other step: \(connection)")
        }
    }

    func bluetoothConnectionManagerConnectionDropped(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        log("bluetoothConnectionManagerConnectionDropped = \(connection)")
        if (connection == self.initialDevice.transceiver?.connection || connection == self.commissionerDevice?.transceiver?.connection) {
            if self.currentStepFlags["reconnect"] != nil && (self.currentCommand == .ConnectToInitialDevice || self.currentCommand == .ConnectToCommissionerDevice) {
                self.currentStepFlags["reconnect"] = nil
                self.runCurrentStep()
            } else {
                //if we are waiting for the reply = trigger timeout
                if let initialDeviceTransceiver = self.initialDevice.transceiver {
                    initialDeviceTransceiver.triggerTimeout()
                }

                //if we are waiting for the reply = trigger timeout
                if let commissionerDeviceTransceiver = self.commissionerDevice?.transceiver {
                    commissionerDeviceTransceiver.triggerTimeout()
                }
            }
        }
        //if some other connectio was dropped - we dont care
    }
//}

//extension MeshSetupFlowManager {
    //MARK: GetInitialDeviceInfo
    private func stepGetInitialDeviceInfo() {
        self.delegate.meshSetupDidRequestInitialDeviceInfo(setInitialDeviceInfo: setInitialDeviceInfo)
    }

    private func setInitialDeviceInfo(dataMatrix: MeshSetupDataMatrix) {
        self.initialDevice = MeshDevice()

        //these flags are used to determine gateway subflow .. if they are set, new network is being created
        //otherwise gateway is joining the existing network so it is important to clear them
        //we cant use selected network, because that part might be reused if multiple devices are connected to same
        //network without disconnecting commissioner
        self.newNetworkPassword = nil
        self.newNetworkName = nil

        self.log("dataMatrix: \(dataMatrix)")
        self.initialDevice.type = self.getDeviceType(serialNumber: dataMatrix.serialNumber)
        self.log("self.initialDevice.type?.description = \(self.initialDevice.type?.description as Optional)")
        self.initialDevice.credentials = MeshSetupPeripheralCredentials(name: self.initialDevice.type!.description + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        self.stepComplete()
    }

    //MARK: ConnectToInitialDevice
    private func stepConnectToInitialDevice() {
        if (self.bluetoothManager.state != .Ready) {
            self.fail(withReason: .BluetoothDisabled)
            return
        }

        self.bluetoothManager.createConnection(with: self.initialDevice.credentials!)
        self.delegate.meshSetupDidEnterState(state: .InitialDeviceConnecting)
    }

    private func initialDeviceConnected(connection: MeshSetupBluetoothConnection) {
        self.initialDevice.transceiver = MeshSetupProtocolTransceiver(connection: connection)
        self.stepComplete()
    }

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
        self.initialDevice.transceiver!.sendGetSystemVersion { result, version in
            self.log("initialDevice.sendGetSystemVersion: \(result.description()), version: \(version as Optional)")
            if (result == .NONE) {
                //TODO: get the answer from server if firmware should be updated
                if (version!.range(of: "rc.13") != nil) {
                    self.stepComplete()
                } else {
                    self.checkInitialDeviceSupportsCompressedOTA()
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    private func checkInitialDeviceSupportsCompressedOTA() {
        self.initialDevice.transceiver!.sendGetSystemCapabilities { result, capability in
            self.log("initialDevice.sendGetSystemCapabilities: \(result.description()), capability: \(capability?.rawValue as Optional)")
            if (result == .NONE) {
                self.initialDevice.supportsCompressedOTAUpdate = (capability! == SystemCapability.compressedOta)
                self.checkInitialDeviceIsSetupDone()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkInitialDeviceIsSetupDone() {
        self.initialDevice.transceiver!.sendIsDeviceSetupDone { result, isSetupDone in
            self.log("initialDevice.sendIsDeviceSetupDone: \(result.description()), isSetupDone: \(isSetupDone as Optional)")
            if (result == .NONE) {
                self.initialDevice.isSetupDone = isSetupDone
                self.startFirmwareUpdate()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func startFirmwareUpdate() {
        self.log("Starting firmware update")

        //TODO: get proper firmware binary

        let path = Bundle.main.path(forResource: "tinker-0.8.0-rc.13-xenon", ofType: "bin")

        let firmwareData = try! Data(contentsOf: URL(fileURLWithPath: path!))

        self.currentStepFlags["firmwareData"] = firmwareData
        self.initialDevice.transceiver!.sendStartFirmwareUpdate(binarySize: firmwareData.count) { result, chunkSize in
            self.log("initialDevice.sendStartFirmwareUpdate: \(result), chunkSize: \(chunkSize)")
            if (result == .NONE) {
                self.currentStepFlags["chunkSize"] = Int(chunkSize)
                self.currentStepFlags["idx"] = 0

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

        self.log("bytesLeft: \(bytesLeft)")

        let subdata = firmwareData.subdata(in: start ..< min(start+chunk, start+bytesLeft))
        self.initialDevice.transceiver!.sendFirmwareUpdateData(data: subdata) { result in
            self.log("initialDevice.sendFirmwareUpdateData: \(result)")
            if (result == .NONE) {
                if ((idx+1) * chunk >= firmwareData.count) {
                    self.finishFirmwareUpdate()
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
        self.initialDevice.transceiver!.sendFinishFirmwareUpdate(validateOnly: false) { result in
            self.log("initialDevice.sendFinishFirmwareUpdate: \(result)")
            if (result == .NONE) {
                // reconnect to device by jumping back few steps in the sequence
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    if (self.canceled) {
                        return
                    }


                    self.currentStep = self.preflow.index(of: .ConnectToInitialDevice)!
                    self.log("returning to step: \(self.currentStep)")
                    self.runCurrentStep()
                    self.currentStepFlags["reconnectAfterFirmwareFlash"] = true
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    //MARK: CheckInitialDeviceHasNetworkInterfaces
    private func stepCheckInitialDeviceHasNetworkInterfaces() {
        self.initialDevice.transceiver!.sendGetInterfaceList { result, interfaces in
            self.log("initialDevice.sendGetInterfaceList: \(result), networkCount: \(interfaces?.count as Optional)")
            if (result == .NONE) {
                self.initialDevice.hasInternetCapableNetworkInterfaces = false
                self.initialDevice.networkInterfaces = interfaces!
                for interface in interfaces! {
                    if (interface.type == .ethernet || interface.type == .wifi || interface.type == .ppp) {
                        self.initialDevice.hasInternetCapableNetworkInterfaces = true
                        break
                    }
                }
                self.stepComplete()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    //MARK: EnsureDeviceCanBeClaimed
    private func stepEnsureInitialDeviceCanBeClaimed() {
        self.initialDevice.transceiver!.sendGetDeviceId { result, deviceId in
            self.log("didReceiveDeviceIdReply: \(result), deviceId: \(deviceId as Optional)")
            if (result == .NONE) {
                self.initialDevice.deviceId = deviceId!
                self.checkInitialDeviceIsClaimed()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    private func checkInitialDeviceIsClaimed() {
        ParticleCloud.sharedInstance().getDevices { devices, error in
            guard error == nil else {
                self.fail(withReason: .UnableToGenerateClaimCode, nsError: error)
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == self.initialDevice.deviceId!) {
                        self.log("device belongs to user already")
                        self.initialDevice.isClaimed = true
                        self.initialDevice.claimCode = nil
                        self.stepComplete()
                        return
                    }
                }
            }

            self.initialDevice.isClaimed = nil
            self.initialDevice.claimCode = nil

            self.getClaimCode()
        }
    }

    private func getClaimCode() {
        log("generating claim code")
        ParticleCloud.sharedInstance().generateClaimCode { claimCode, userDevices, error in
            guard error == nil else {
                self.fail(withReason: .UnableToGenerateClaimCode, nsError: error)
                return
            }

            self.log("claim code generated")
            self.initialDevice.claimCode = claimCode
            self.initialDevice.isClaimed = false
            self.stepComplete()
        }
    }





    //MARK: SetClaimCode
    private func stepSetClaimCode() {
        if let claimCode = self.initialDevice.claimCode {
            self.initialDevice.transceiver!.sendSetClaimCode(claimCode: claimCode) { result in
                self.log("sendSetClaimCode: \(result)")
                if (result == .NONE) {
                    self.stepComplete()
                } else {
                    self.handleBluetoothErrorResult(result)
                }
            }
        } else {
            self.stepComplete()
        }
    }




    //MARK: EnsureInitialDeviceIsNotOnMeshNetwork
    private func stepEnsureInitialDeviceIsNotOnMeshNetwork() {
        self.initialDevice.transceiver!.sendGetNetworkInfo { result, networkInfo in
            self.log("initialDevice.sendGetNetworkInfo: \(result)")
            if (result == .NOT_FOUND) {
                self.initialDevice.networkInfo = nil
                self.stepComplete()
            } else if (result == .NONE) {
                self.initialDevice.networkInfo = networkInfo
                self.delegate.meshSetupDidRequestToLeaveNetwork(network: networkInfo!, setLeaveNetwork: self.setInitialDeviceLeaveNetwork)
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func setInitialDeviceLeaveNetwork(leave: Bool) {
        if (leave || self.initialDevice.networkInfo == nil) {
            //forcing this command on devices with no network info helps with the joining process
            self.initialDeviceLeaveNetwork()
        } else {
            fail(withReason: .UserRefusedToLeaveMeshNetwork)
        }
    }

    private func initialDeviceLeaveNetwork() {
        self.initialDevice.transceiver!.sendLeaveNetwork { result in
            self.log("didReceiveLeaveNetworkReply: \(result)")
            if (result == .NONE) {
                self.stepComplete()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }



    //MARK: GetUserNetworkSelection
    private func stepGetUserNetworkSelection() {
        //adding more devices to same network
        if (self.selectedNetworkInfo != nil) {
            self.stepComplete()
            return
        }

        self.scanNetworks(onComplete: self.getUserNetworkSelection)
    }

    private func scanNetworks(onComplete: @escaping () -> ()) {
        self.initialDevice.transceiver!.sendScanNetworks { result, networks in
            self.log("sendScanNetworks: \(result), networksCount: \(networks?.count as Optional)\n\(networks as Optional)")
            if (result == .NONE) {
                self.initialDevice.networks = self.removeRepeatedNetworks(networks!)
                onComplete()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    //TODO: GET /v1/networks to get device count


    private func getUserNetworkSelection() {
        self.delegate.meshSetupDidRequestToSelectNetwork(availableNetworks: self.initialDevice.networks!, setSelectedNetwork: setSelectedNetwork)
    }

    private func setSelectedNetwork(_ selectedNetwork: MeshSetupNetworkInfo) {
        self.selectedNetworkInfo = selectedNetwork
        self.stepComplete()
    }


    //MARK: GetCommissionerDeviceInfo
    private func stepGetCommissionerDeviceInfo() {
        //adding more devices to same network
        if (self.commissionerDevice?.credentials != nil) {
            //we need to put the commissioner into listening mode by sending the command
            self.commissionerDevice!.transceiver!.sendStarListening { result in
                self.log("sendStarListening: \(result)")
                if (result == .NONE) {
                    self.stepComplete()
                } else {
                    self.handleBluetoothErrorResult(result)
                }
            }
            return
        }

        self.delegate.meshSetupDidRequestCommissionerDeviceInfo(setCommissionerDeviceInfo: setCommissionerDeviceInfo)
    }

    private func setCommissionerDeviceInfo(dataMatrix: MeshSetupDataMatrix) {
        self.commissionerDevice = MeshDevice()

        self.log("dataMatrix: \(dataMatrix)")
        self.commissionerDevice!.type = self.getDeviceType(serialNumber: dataMatrix.serialNumber)
        self.log("self.commissionerDevice.type?.description = \(self.commissionerDevice!.type?.description as Optional)")
        self.commissionerDevice!.credentials = MeshSetupPeripheralCredentials(name: self.initialDevice.type!.description + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        self.stepComplete()
    }

    //MARK: ConnectToCommissionerDevice
    private func stepConnectToCommissionerDevice() {
        //adding more devices to same network, no need reconnect to commissioner
        if (self.commissionerDevice?.transceiver != nil) {
            self.stepComplete()
            return
        }

        if (self.bluetoothManager.state != .Ready) {
            self.fail(withReason: .BluetoothDisabled)
            return
        }

        self.bluetoothManager.createConnection(with: self.commissionerDevice!.credentials!)
        self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceConnected)
    }

    private func commissionerDeviceConnected(connection: MeshSetupBluetoothConnection) {
        self.commissionerDevice!.transceiver = MeshSetupProtocolTransceiver(connection: connection)
        self.stepComplete()
    }


    //MARK: EnsureCommissionerNetworkMatches
    private func stepEnsureCommissionerNetworkMatches() {
        self.commissionerDevice!.transceiver!.sendGetNetworkInfo { result, networkInfo in
            self.log("commissionerDevice.sendGetNetworkInfo: \(result), networkInfo: \(networkInfo as Optional)")

            if (result == .NOT_FOUND) {
                self.commissionerDevice!.networkInfo = nil
            } else if (result == .NONE) {
                self.commissionerDevice!.networkInfo = networkInfo
            } else {
                self.handleBluetoothErrorResult(result)
                return
            }

            if (self.selectedNetworkInfo?.extPanID == self.commissionerDevice!.networkInfo?.extPanID) {
                self.stepComplete()
            } else {
                self.fail(withReason: .CommissionerNetworkDoesNotMatch)
            }
        }
    }



    //MARK: EnsureCorrectSelectedNetworkPassword
    private func stepEnsureCorrectSelectedNetworkPassword() {
        self.delegate.meshSetupDidRequestToEnterSelectedNetworkPassword(setSelectedNetworkPassword: setSelectedNetworkPassword)
    }

    private func setSelectedNetworkPassword(_ password: String) {
        self.log("password set: \(password)")
        self.selectedNetworkPassword = password

        /// NOT_FOUND: The device is not a member of a network
        /// NOT_ALLOWED: Invalid commissioning credential
        self.commissionerDevice!.transceiver!.sendAuth(password: password) { result in
            self.log("sendAuth: \(result)")
            if (result == .NONE) {
                self.stepComplete()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }



    //MARK: JoinNetwork
    private func stepJoinSelectedNetwork() {
        /// NOT_ALLOWED: The client is not authenticated
        self.commissionerDevice!.transceiver!.sendStartCommissioner { result in
            self.log("sendStartCommissioner: \(result)")
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
        self.initialDevice.transceiver!.sendPrepareJoiner(networkInfo: self.selectedNetworkInfo!) { result, eui64, password in
            self.log("sendPrepareJoiner sent networkInfo: \(self.selectedNetworkInfo!)")
            self.log("sendPrepareJoiner: \(result)")
            if (result == .NONE) {
                self.initialDevice.joinerCredentials = (eui64: eui64!, password: password!)
                self.addJoiner()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func addJoiner() {
        /// NO_MEMORY: No memory available to add the joiner
        /// INVALID_STATE: The commissioner role is not started
        /// NOT_ALLOWED: The client is not authenticated
        self.commissionerDevice!.transceiver!.sendAddJoiner(eui64: self.initialDevice.joinerCredentials!.eui64, password: self.initialDevice.joinerCredentials!.password) { result in
            self.log("sendAddJoiner: \(result)")
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
        /// NOT_FOUND: No joinable network was found
        /// TIMEOUT: The join process timed out
        /// NOT_ALLOWED: Invalid security credentials
        self.initialDevice.transceiver!.sendJoinNetwork { result in
            self.log("sendJoinNetwork: \(result)")
            if (result == .NONE) {
                self.stopCommissioner()
            } else {
                self.handleBluetoothErrorResult(result)
            }
         }
    }

    private func stopCommissioner() {
        /// NOT_ALLOWED: The client is not authenticated
        self.commissionerDevice!.transceiver!.sendStopCommissioner { result in
            self.log("sendStopCommissioner: \(result)")
            if (result == .NONE) {
                self.setSetupDone()
            } else {
                self.handleBluetoothErrorResult(result)
            }
         }
    }

    private func setSetupDone() {
        self.initialDevice.transceiver!.sendDeviceSetupDone (done: true) { result in
            self.log("sendDeviceSetupDone: \(result)")
            if (result == .NONE) {
                self.stopCommissionerListening()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }


    private func stopCommissionerListening() {
        self.commissionerDevice!.transceiver!.sendStopListening { result in
            self.log("commissionerDevice.sendStopListening: \(result)")
            if (result == .NONE) {
                self.stopInitialDeviceListening()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func stopInitialDeviceListening() {
        self.initialDevice.transceiver!.sendStopListening { result in
            self.log("initialDevice.sendStopListening: \(result)")
            if (result == .NONE) {
                self.stepComplete()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    //MARK: CheckDeviceGotClaimed
    private func checkInitialDeviceGotConnected() {
        if (self.currentStepFlags["checkInitialDeviceGotConnectedStartTime"] == nil) {
            self.currentStepFlags["checkInitialDeviceGotConnectedStartTime"] = Date()
        }

        let diff = Date().timeIntervalSince(self.currentStepFlags["checkInitialDeviceGotConnectedStartTime"] as! Date)
        if (diff > MeshSetup.deviceConnectToCloudTimeout) {
            self.fail(withReason: .DeviceConnectToCloudTimeout)
            return
        }

        self.initialDevice.transceiver!.sendGetConnectionStatus { result, status in
            self.log("initialDevice.sendGetConnectionStatus: \(result)")
            if (result == .NONE) {
                self.log("status: \(status as Optional)")
                if (status! == .connected) {
                    self.log("device connected to the cloud")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                        if (self.canceled) {
                            return
                        }
                        self.checkInitialDeviceGotClaimed()
                    }
                } else {
                    self.log("device did NOT connect yet")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                        if (self.canceled) {
                            return
                        }
                        self.checkInitialDeviceGotConnected()
                    }
                }
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    private func checkInitialDeviceGotClaimed() {
        if (self.currentStepFlags["checkInitialDeviceGotClaimedStartTime"] == nil) {
            self.currentStepFlags["checkInitialDeviceGotClaimedStartTime"] = Date()
        }

        let diff = Date().timeIntervalSince(self.currentStepFlags["checkInitialDeviceGotClaimedStartTime"] as! Date)
        if (diff > MeshSetup.deviceGettingClaimedTimeout) {
            fail(withReason: .DeviceGettingClaimedTimeout)
            return
        }

        ParticleCloud.sharedInstance().getDevices { devices, error in
            guard error == nil else {
                self.fail(withReason: .UnableToGetDeviceList, nsError: error!)
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == self.initialDevice.deviceId!) {
                        self.log("device was successfully claimed")
                        self.stepComplete()
                        return
                    }
                }
            }

            self.log("device was NOT successfully claimed")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                self.checkInitialDeviceGotClaimed()
            }
        }
    }



    //MARK: EnsureHasInternetAccess
    private func stepEnsureHasInternetAccess() {
        //we only use ethernet!!!
        if let idx = self.initialDevice.getEthernetInterfaceIdx() {
            self.initialDevice.transceiver!.sendGetInterface(interfaceIndex: idx) { result, interface in
                if (interface!.ipv4Config.addresses.first != nil) {
                    self.initialDevice.hasInternetAddress = true
                    self.stepComplete()
                } else {
                    self.delegate.meshSetupDidRequestToChooseBetweenRetryInternetOrSwitchToJoinerFlow(setSwitchToJoiner: self.setSwitchToJoiner)
                }
            }
        } else {
            //TODO: remove this for prod
            fatalError("device has no ethernet interface")

            //jump to joiner flow
            //we dont switch step because intro to the flow is the same
            self.currentFlow = joinerFlow
            self.runCurrentStep()
        }
    }

    private func setSwitchToJoiner(switchToJoiner: Bool) {
        if (switchToJoiner) {
            self.currentFlow = self.joinerFlow
            self.currentStep = 0
            self.runCurrentStep()
        } else {
            self.runCurrentStep()
        }
    }

    //MARK: StopInitialDeviceListening
    private func stepStopInitialDeviceListening() {
        self.stopInitialDeviceListening()
    }

    //MARK: CheckDeviceGotClaimed
    private func stepCheckDeviceGotClaimed() {
        self.checkInitialDeviceGotConnected()
    }

    //MARK: GetNewDeviceName
    private func stepGetNewDeviceName() {
        self.delegate.meshSetupDidRequestToEnterDeviceName(setDeviceName: setDeviceName)
    }

    private func setDeviceName(name: String) {
        self.log("name entered: \(name)")
        ParticleCloud.sharedInstance().getDevice(self.initialDevice.deviceId!) { device, error in
            if (error == nil) {
                device!.rename(name) { error in
                    if error == nil {
                        self.stepComplete()
                    } else {
                        self.fail(withReason: .UnableToRenameDevice, nsError: error)
                    }
                }
            } else {
                //TODO: remove for prod
                fatalError("unable to get device that was JUST claimed: \(error!)")
            }
        }
    }


    //MARK:OfferToAddOneMoreDevice
    private func stepOfferToAddOneMoreDevice() {
        //disconnect current device
        if (self.initialDevice.transceiver != nil) {
            self.log("Dropping connection to initial device")
            let connection = self.initialDevice.transceiver!.connection
            self.initialDevice.transceiver = nil
            self.bluetoothManager.dropConnection(with: connection)
        }

        self.delegate.meshSetupDidRequestToAddOneMoreDevice(setAddOneMoreDevice: setAddOneMoreDevice)
    }


    private func setAddOneMoreDevice(addOneMoreDevice: Bool) {
        if (addOneMoreDevice) {
            self.currentStep = 0
            self.currentFlow = preflow
            self.runCurrentStep()
        } else {
            self.delegate.meshSetupDidEnterState(state: .SetupComplete)
        }
    }


    //MARK: OfferToFinishSetupEarly
    private func stepOfferToFinishSetupEarly() {
        self.delegate.meshSetupDidRequestToFinishSetupEarly(setFinishSetupEarly: setFinishSetupEarly)
    }

    private func setFinishSetupEarly(finish: Bool) {
        if (finish) {
            self.delegate.meshSetupDidEnterState(state: .SetupComplete)
        } else {
            self.stepComplete()
        }
    }

    //MARK: OfferSelectOrCreateNetwork
    private func stepOfferSelectOrCreateNetwork() {
        self.scanNetworks(onComplete: self.getUserMeshSetupChoice)
    }

    private func getUserMeshSetupChoice() {
        self.delegate.meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: self.initialDevice.networks!, setSelectedNetwork: setSelectedNetworkOptional)
    }

    private func setSelectedNetworkOptional(_ selectedNetwork: MeshSetupNetworkInfo?) {
        if let selectedNetwork = selectedNetwork {
            self.selectedNetworkInfo = selectedNetwork
            self.stepComplete()
        } else {
            self.delegate.meshSetupDidRequestToEnterNewNetworkName(setNewNetworkName: setNetworkName)
        }
    }

    private func setNetworkName(name: String) {
        self.log("set network name: \(name)")
        self.newNetworkName = name

        self.delegate.meshSetupDidRequestToEnterNewNetworkPassword(setNewNetworkPassword: setNetworkPassword)
    }

    private func setNetworkPassword(password: String) {
        self.log("set network password: \(password)")
        self.newNetworkPassword = password

        self.stepComplete()
    }


    //MARK: CreateNetwork
    private func stepCreateNetwork() {
        self.initialDevice.transceiver!.sendCreateNetwork(name: self.newNetworkName!, password: self.newNetworkPassword!) { result, networkInfo in
            self.log("sendCreateNetwork: \(result), networkInfo: \(networkInfo as Optional)")
            if (result == .NONE) {
                self.log("Setting current initial device as commissioner device")
                self.commissionerDevice = self.initialDevice
                self.selectedNetworkInfo = networkInfo!
                self.selectedNetworkPassword = self.newNetworkPassword

                self.initialDevice = MeshDevice()

                self.stepComplete()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }
}