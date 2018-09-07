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
enum MeshSetupFlowCommands {
    //preflow
    case GetInitialDeviceInfo
    case ConnectToInitialDevice
    case EnsureInitialDeviceCanBeClaimed
    case CheckInitialDeviceIsSetup
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
    case JoinNetwork
}


enum MeshSetupFlowState {
    case InitialDeviceConnecting
    case InitialDeviceConnected
    case InitialDeviceReady
    case CommissionerDeviceConnecting
    case CommissionerDeviceConnected
    case CommissionerDeviceReady
}

enum MeshSetupFlowError: Error {
    case DeviceAlreadyClaimedByTheUser
    case UnableToGenerateClaimCode
    case DeviceTooFar
    case UserRefusedToLeaveMeshNetwork
}

struct MeshDevice {
    var type: ParticleDeviceType?
    var deviceId: String?
    var credentials: MeshSetupPeripheralCredentials?

    var transceiver: MeshSetupProtocolTransceiver?

    var claimCode: String?
    var isClaimed: Bool?

    var isSetupDone: Bool?
    var hasInternetAccess: Bool?

    var networkInfo: MeshSetupNetworkInfo?
    var networks: [MeshSetupNetworkInfo]?
}

protocol MeshSetupFlowManagerDelegate {
    func meshSetupDidRequestInitialDeviceInfo()
    func meshSetupDidRequestToLeaveNetwork(network: MeshSetupNetworkInfo)
    func meshSetupDidRequestToSelectNetwork(availableNetworks: [MeshSetupNetworkInfo])
    func meshSetupDidRequestCommissionerDeviceInfo()
    func meshSetupDidRequestToEnterSelectedNetworkPassword()
    func meshSetupDidRequestToEnterDeviceName()

    func meshSetupDidEnterState(state: MeshSetupFlowState)
    func meshSetupError(error: MeshSetupFlowError, severity: MeshSetupErrorSeverity)
}

class MeshSetupFlowManager: NSObject, MeshSetupBluetoothConnectionManagerDelegate {

    private let preflow: [MeshSetupFlowCommands] = [
                                                        .GetInitialDeviceInfo,
                                                        .ConnectToInitialDevice,
                                                        .EnsureInitialDeviceCanBeClaimed,
                                                        .CheckInitialDeviceIsSetup,
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
                                                        .JoinNetwork
                                                    ]



    private let gatewayFlow: [MeshSetupFlowCommands] = [.SetClaimCode]

    var delegate: MeshSetupFlowManagerDelegate

    private var bluetoothManager: MeshSetupBluetoothConnectionManager!

    private var initialDevice: MeshDevice!
    private var commissionerDevice: MeshDevice!

    private var selectedNetworkInfo: MeshSetupNetworkInfo?
    private var selectedNetworkPassword: String?


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
            NSLog("MeshSetupFlowUIManager: \(message)")
        }
    }

    func cancel() {
        self.bluetoothManager.dropAllConnections()
    }

    private func fail(withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity) {
        self.delegate.meshSetupError(error: reason, severity: severity)
        log("error: \(reason)")
    }

    //MARK: Flow control

    //entry to the flow
    func startSetup() {
        currentFlow = preflow
        currentStep = 0

        self.runCurrentStep()
    }

    func retryStep() {
        runCurrentStep()
    }

    private func runCurrentStep() {
        log("currentStep = \(currentStep), currentCommand = \(currentCommand)")
        self.currentStepFlags = [:]
        switch self.currentCommand {
        //preflow
        case .GetInitialDeviceInfo:
            self.getInitialDeviceInfo()
        case .ConnectToInitialDevice:
            self.connectToInitialDevice()
        case .EnsureInitialDeviceCanBeClaimed:
            self.ensureDeviceCanBeClaimed()
        case .CheckInitialDeviceIsSetup:
            self.checkInitialDeviceIsSetup()
        case .CheckInitialDeviceHasNetworkInterfaces:
            self.checkInitialDeviceHasNetworkInterfaces()
        case .ChooseFlow:
             self.chooseFlow()

        //main flow
        case .SetClaimCode:
            self.setClaimCode()
        case .EnsureInitialDeviceIsNotOnMeshNetwork:
            self.ensureInitialDeviceIsNotOnMeshNetwork()
        case .GetUserNetworkSelection:
            self.scanInitialDeviceNetworks()
        case .GetCommissionerDeviceInfo:
            self.getCommissionerDeviceInfo()
        case .ConnectToCommissionerDevice:
            self.connectToCommissionerDevice()
        case .EnsureCommissionerNetworkMatches:
            self.ensureCommissionerNetworkMatches()
        case .EnsureCorrectSelectedNetworkPassword:
            self.ensureCorrectSelectedNetworkPassword()
        case .JoinNetwork:
            self.startCommissionner()

        default:
            log("Unknown command: \(currentFlow[currentStep])")
        }
    }

    private func stepComplete() {
        self.currentStep += 1
        self.runCurrentStep()
    }


    //end of preflow
    private func chooseFlow() {
        log("preflow completed")
//        if (self.initialDevice.isClaimed!) {
//            fail(withReason: .DeviceAlreadyClaimedByTheUser, severity: .Error)
//            return
//        }
//
//        if (self.initialDevice.claimCode == nil){
//            fail(withReason: .UnableToGenerateClaimCode, severity: .Error)
//            return
//        }

        //jump to new sub-flow
        self.currentStep = 0
        if (self.initialDevice.hasInternetAccess!) {
            self.currentFlow = gatewayFlow
            log("setting gateway flow")
        } else {
            self.currentFlow = joinerFlow
            log("setting joiner flow")
        }
        self.runCurrentStep()
    }



    //MARK: BluetoothConnectionManagerDelegate
    func bluetoothConnectionManagerStateChanged(sender: MeshSetupBluetoothConnectionManager, state: MeshSetupBluetoothConnectionManagerState) {
        log("MeshSetupBluetoothConnectionManagerState = \(state)")
        if (self.currentCommand == .ConnectToInitialDevice || self.currentCommand == .ConnectToCommissionerDevice) {
            if (self.bluetoothManager.state == .Ready) {
                if let connectWhenReady = self.currentStepFlags["connectWhenReady"] {
                    self.currentStepFlags["connectWhenReady"] = nil
                    self.runCurrentStep()
                }
            } else if (self.bluetoothManager.state == .Disabled) {
                //though this is not yet the reason to fail, but it might be if really soon
            }
            //we don't care about other states
        }
        //we don't care about state changes in other steps
    }

    func bluetoothConnectionManagerError(sender: MeshSetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity) {
        if (self.currentCommand == .ConnectToInitialDevice || self.currentCommand == .ConnectToCommissionerDevice) {
            if (error == .DeviceWasConnected) {
                self.currentStepFlags["reconnect"] = true
            } else if (error == .DeviceTooFar) {
                self.fail(withReason: .DeviceTooFar, severity: .Error) //after showing promt, step should be repeated
            } else {
                //TODO: flow failed?
            }
        } else {
            //TODO: flow failed?
        }
    }

    func bluetoothConnectionManagerConnectionCreated(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.currentCommand == .ConnectToInitialDevice) {
            self.delegate.meshSetupDidEnterState(state: .InitialDeviceConnected)
        } else if (self.currentCommand == .ConnectToCommissionerDevice) {
            self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceConnected)
        } else {
            //TODO: possibly remove this
            fatalError("bluetoothConnectionManagerConnectionCreated when it should not happen")
        }
    }

    func bluetoothConnectionManagerConnectionBecameReady(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.currentCommand == .ConnectToInitialDevice) {
            self.delegate.meshSetupDidEnterState(state: .InitialDeviceReady)
            self.initialDevice.transceiver = MeshSetupProtocolTransceiver(connection: connection)

            self.initialDeviceConnected()
        } else if (self.currentCommand == .ConnectToCommissionerDevice) {
            self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceReady)
            self.commissionerDevice.transceiver = MeshSetupProtocolTransceiver(connection: connection)

            self.commissionerDeviceConnected()
        } else {
            //TODO: possibly remove this
            fatalError("bluetoothConnectionManagerConnectionCreated when it should not happen")
        }
    }

    func bluetoothConnectionManagerConnectionDropped(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.currentCommand == .ConnectToInitialDevice || self.currentCommand == .ConnectToCommissionerDevice) {
            if let reconnect = self.currentStepFlags["reconnect"] {
                self.currentStepFlags["reconnect"] = nil
                self.runCurrentStep()
            } else {
                //TODO: flow failed?
            }
        } else {
            //TODO: flow failed?
        }
    }
//}

//extension MeshSetupFlowManager {
    //MARK: GetInitialDeviceInfo
    private func getInitialDeviceInfo() {
        self.delegate.meshSetupDidRequestInitialDeviceInfo()
    }

    func setInitialDeviceInfo(deviceType: ParticleDeviceType, dataMatrix: MeshSetupDataMatrix) {
        self.initialDevice = MeshDevice()

        self.initialDevice.type = deviceType
        self.initialDevice.credentials = MeshSetupPeripheralCredentials(name: deviceType.description + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        self.stepComplete()
    }

    //MARK: ConnectToInitialDevice
    private func connectToInitialDevice() {
        if (self.bluetoothManager.state != .Ready) {
            self.currentStepFlags["connectWhenReady"] = true
            return
            //TODO: Show appropriate prompt for user to enable the bluetooth
            //code execution will continue in bluethoothManagerDelegate methods when manager state changes to ready
        }

        self.bluetoothManager.createConnection(with: self.initialDevice.credentials!)
        self.delegate.meshSetupDidEnterState(state: .InitialDeviceConnecting)
    }

    private func initialDeviceConnected() {
        self.stepComplete()
    }


    //MARK: CheckInitialDeviceIsSetup
    private func checkInitialDeviceIsSetup() {
        self.initialDevice.transceiver!.sendIsDeviceSetupDone { result, isDone in
            self.log("didReceiveIsDeviceSetupDoneReply: \(result), isDone: \(isDone)")
            if (result == .NONE) {
                self.stepComplete()
            } else {
                //TODO: handle errors?
            }
        }
    }


    //MARK: CheckInitialDeviceHasNetworkInterfaces
    private func checkInitialDeviceHasNetworkInterfaces() {
        self.initialDevice.transceiver!.sendGetInterfaceList { result, interfaces in
            self.log("didReceiveStartCommissionerReply: \(result), networkCount: \(interfaces?.count)")
            if (result == .NONE) {
                self.initialDevice.hasInternetAccess = false
                for interface in interfaces! {
                    if (interface.type == .ethernet || interface.type == .wifi || interface.type == .ppp) {
                        self.initialDevice.hasInternetAccess = true
                        break
                    }
                }
                self.stepComplete()
            } else {
                //TODO: handle errors?
            }
        }
    }


    //MARK: EnsureDeviceCanBeClaimed
    private func ensureDeviceCanBeClaimed() {
        self.initialDevice.transceiver!.sendGetDeviceId { result, deviceId in
            self.log("didReceiveDeviceIdReply: \(result), deviceId: \(deviceId)")
            if (result == .NONE) {
                self.initialDevice.deviceId = deviceId!
                self.checkInitialDeviceIsClaimed()
            } else {
                //TODO: problems...
            }
        }
    }

    private func checkInitialDeviceIsClaimed() {
        ParticleCloud.sharedInstance().getDevices { devices, error in
            guard error == nil else {
                self.log(error!.localizedDescription)
                //TODO: fail for uknown reason
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == self.initialDevice.deviceId!) {
                        self.log("device belongs to user already")
                        self.initialDevice.isClaimed = true
                        self.stepComplete()
                        return
                    }
                }
            }

            self.getClaimCode()
        }
    }

    private func getClaimCode() {
        log("generating claim code")
        ParticleCloud.sharedInstance().generateClaimCode { claimCode, userDevices, error in
            guard error == nil else {
                self.log(error!.localizedDescription)
                //TODO: fail flow? unable to generate claim code
                return
            }

            self.log("claim code generated")
            self.initialDevice.claimCode = claimCode
            self.initialDevice.isClaimed = false
            self.stepComplete()
        }
    }





    //MARK: SetClaimCode
    private func setClaimCode() {
        if let claimCode = self.initialDevice.claimCode {
            self.initialDevice.transceiver!.sendSetClaimCode(claimCode: self.initialDevice.claimCode!) { result in
                self.log("didReceiveSetClaimCodeReply: \(result)")
                if (result == .NONE) {
                    self.stepComplete()
                } else {
                    //TODO: problems...
                }
            }
        } else {
            //TODO: make sure this is fine
            self.stepComplete()
        }
    }




    //MARK: EnsureInitialDeviceIsNotOnMeshNetwork
    private func ensureInitialDeviceIsNotOnMeshNetwork() {
        self.initialDevice.transceiver!.sendGetNetworkInfo { result, networkInfo in
            self.log("didReceiveInitialDeviceNetworkInfoReply: \(result)")
            if (result == .NOT_FOUND) {
                self.initialDevice.networkInfo = nil
                self.stepComplete()
            } else if (result == .NONE) {
                self.initialDevice.networkInfo = networkInfo
                self.delegate.meshSetupDidRequestToLeaveNetwork(network: networkInfo!)
            } else {
                //TODO: problems...
            }
        }
    }

    func setInitialDeviceLeaveNetwork(leave: Bool) {
        if (self.initialDevice.networkInfo == nil) {
            self.stepComplete()
        } else if (leave) {
            self.initialDeviceLeaveNetwork()
        } else {
            fail(withReason: .UserRefusedToLeaveMeshNetwork, severity: .Error)
        }
    }

    func initialDeviceLeaveNetwork() {
        self.initialDevice.transceiver!.sendLeaveNetwork { result in
            self.log("didReceiveLeaveNetworkReply: \(result)")
            if (result == .NONE) {
                self.stepComplete()
            } else {
                //TODO: problems...
            }
        }
    }



    //MARK: GetUserNetworkSelection
    private func scanInitialDeviceNetworks() {
        self.initialDevice.transceiver!.sendScanNetworks { result, networks in
            self.log("sendScanNetworks: \(result), networksCount: \(networks?.count)\n\(networks)")
            if (result == .NONE) {
                self.initialDevice.networks = networks
                self.getUserNetworkSelection()
            } else {
                //TODO: problems...
            }
        }
    }

    //TODO: GET /v1/networks to get device count

    private func getUserNetworkSelection() {
        self.delegate.meshSetupDidRequestToSelectNetwork(availableNetworks: self.initialDevice.networks!)
    }

    func setSelectedNetwork(_ selectedNetwork: MeshSetupNetworkInfo) {
        self.selectedNetworkInfo = selectedNetwork
        self.stepComplete()
    }


    //MARK: GetCommissionerDeviceInfo
    private func getCommissionerDeviceInfo() {
        self.delegate.meshSetupDidRequestCommissionerDeviceInfo()
    }

    func setCommissionerDeviceInfo(deviceType: ParticleDeviceType, dataMatrix: MeshSetupDataMatrix) {
        self.commissionerDevice = MeshDevice()

        self.commissionerDevice.type = deviceType
        self.commissionerDevice.credentials = MeshSetupPeripheralCredentials(name: deviceType.description + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        self.stepComplete()
    }

    //MARK: ConnectToCommissionerDevice
    private func connectToCommissionerDevice() {
        if (self.bluetoothManager.state != .Ready) {
            //TODO: Show appropriate prompt for user to enable the bluetooth
            self.currentStepFlags["connectWhenReady"] = true
            //code execution will continue in bluethoothManagerDelegate methods when manager state changes to ready
            return
        }
        self.bluetoothManager.createConnection(with: self.commissionerDevice.credentials!)
        self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceConnected)
    }

    private func commissionerDeviceConnected() {
        self.stepComplete()
    }


    //MARK: EnsureCommissionerNetworkMatches
    private func ensureCommissionerNetworkMatches() {
        self.commissionerDevice.transceiver!.sendGetNetworkInfo { result, networkInfo in
            self.log("sendGetNetworkInfo: \(result), networkInfo: \(networkInfo)")

            if (result == .NOT_FOUND) {
                self.commissionerDevice.networkInfo = nil
            } else if (result == .NONE) {
                self.initialDevice.networkInfo = networkInfo
            } else {
                //TODO: problems
            }

            if (self.selectedNetworkInfo?.extPanID == networkInfo?.extPanID) {
                self.stepComplete()
            } else {
                //TODO: fail cause commisioner has no network
            }
        }
    }



    //MARK: EnsureCorrectSelectedNetworkPassword
    private func ensureCorrectSelectedNetworkPassword() {
        self.delegate.meshSetupDidRequestToEnterSelectedNetworkPassword()
    }

    func setSelectedNetworkPassword(_ password: String) {
        self.selectedNetworkPassword = password

        /// NOT_FOUND: The device is not a member of a network
        /// NOT_ALLOWED: Invalid commissioning credential
        self.commissionerDevice.transceiver!.sendAuth(password: password) { result in
            self.log("sendAuth: \(result)")
            if (result == .NONE) {
                self.stepComplete()
            } else {
                //TODO: problems...
            }
        }
    }



    //MARK: JoinNetwork
    private func startCommissionner() {

        /// NOT_ALLOWED: The client is not authenticated
        self.commissionerDevice.transceiver!.sendStartCommissioner { result in
            self.log("sendStartCommissioner: \(result)")
            if result == .NONE {
                self.prepareJoiner()
            } else {
                //TODO: problems...
            }
        }
    }

    private func prepareJoiner() {
        /// ALREADY_EXIST: The device is already a member of a network
        /// NOT_ALLOWED: The client is not authenticated
        self.initialDevice.transceiver!.sendPrepareJoiner(networkInfo: self.selectedNetworkInfo!) { result, eui64, password in
            self.log("sendPrepareJoiner: \(result)")
            if (result == .NONE) {
                self.addJoiner(eui64: eui64!, password: password!)
            } else {
                //TODO: problems...
            }
        }
    }

    private func addJoiner(eui64: String, password: String) {
        /// NO_MEMORY: No memory available to add the joiner
        /// INVALID_STATE: The commissioner role is not started
        /// NOT_ALLOWED: The client is not authenticated
        self.commissionerDevice.transceiver!.sendAddJoiner(eui64: eui64, password: password) { result in
            self.log("sendAddJoiner: \(result)")
            if (result == .NONE) {
                self.joinNetwork()
            } else {
                //TODO: problems...
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
                //TODO: problems...
            }

         }
    }

    private func stopCommissioner() {
        /// NOT_ALLOWED: The client is not authenticated
        self.commissionerDevice.transceiver!.sendStopCommissioner { result in
            self.log("sendStopCommissioner: \(result)")
            if (result == .NONE) {
                self.stopCommissionerListening()
            } else {
                //TODO: problems...
            }
         }
    }


    private func stopCommissionerListening() {
        self.commissionerDevice.transceiver!.sendStopListening { result in
            self.log("commissionerDevice.sendStopListening: \(result)")
            if (result == .NONE) {
                self.stopInitialDeviceListening()
            } else {
                //TODO: problems...
            }
        }
    }

    private func stopInitialDeviceListening() {
        self.initialDevice.transceiver!.sendStopListening { result in
            self.log("initialDevice.sendStopListening: \(result)")
            if (result == .NONE) {
                self.checkInitialDeviceGotClaimed()
            } else {
                //TODO: problems...
            }
        }
    }

    private func checkInitialDeviceGotClaimed() {
        ParticleCloud.sharedInstance().getDevices { devices, error in
            guard error == nil else {
                self.log(error!.localizedDescription)
                //TODO: fail for uknown reason
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == self.initialDevice.deviceId!) {
                        self.log("device was successfully claimed")
                        return
                    }
                }
            }

            self.log("device was NOT successfully claimed")
        }
    }
}