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


protocol MeshSetupFlowManagerDelegate {
    func meshSetupDidRequestInitialDeviceInfo()
    func meshSetupDidRequestToLeaveNetwork(network: MeshSetupNetworkInfo)
    func meshSetupDidRequestToSelectNetwork(availableNetworks: [MeshSetupNetworkInfo])
    func meshSetupDidRequestCommissionerDeviceInfo()
    func meshSetupDidRequestToEnterSelectedNetworkPassword()
    func meshSetupDidRequestToEnterDeviceName()
    func meshSetupDidRequestToAddOneMoreDevice()

    func meshSetupDidRequestToFinishSetupEarly() //before setting mesh network
    func meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: [MeshSetupNetworkInfo])

    func meshSetupDidEnterState(state: MeshSetupFlowState)
    func meshSetupError(error: MeshSetupFlowError, severity: MeshSetupErrorSeverity)
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

    private let preflow: [MeshSetupFlowCommands] = [
        .GetInitialDeviceInfo,
        .ConnectToInitialDevice,
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

    private var initialDevice: MeshDevice!
    private var commissionerDevice: MeshDevice?

    //for joining flow
    private var selectedNetworkInfo: MeshSetupNetworkInfo?
    private var selectedNetworkPassword: String?

    //for creating flow
    private var newNetworkName: String?
    private var newNetworkPassword: String?


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

    func cancel() {
        self.bluetoothManager.dropAllConnections()
    }

    private func fail(withReason reason: MeshSetupFlowError, severity: MeshSetupErrorSeverity) {
        log("error: \(reason)")
        self.delegate.meshSetupError(error: reason, severity: severity)
    }

    //MARK: Flow control

    //entry to the flow
    func startSetup() {
        currentFlow = preflow
        currentStep = 0

        self.runCurrentStep()
    }

    func retryLastAction() {
        self.runCurrentStep()
    }

    private func runCurrentStep() {
        log("\n\n--------------------------------------------------------------------------------------------\n" +
                "currentStep = \(currentStep), currentCommand = \(currentCommand)")
        self.currentStepFlags = [:]
        switch self.currentCommand {
            //preflow
            case .GetInitialDeviceInfo:
                self.stepGetInitialDeviceInfo()
            case .ConnectToInitialDevice:
                self.stepConnectToInitialDevice()
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
        self.currentStep += 1
        self.runCurrentStep()
    }


    //end of preflow
    private func stepChooseFlow() {
        log("preflow completed")
        if (!self.initialDevice.isClaimed! && self.initialDevice.claimCode == nil) {
            fail(withReason: .UnableToGenerateClaimCode, severity: .Error)
            return
        }

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
        log("subflow")

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
                self.log("bluetooth manager error: \(error)")
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
            self.initialDeviceConnected(connection: connection)
        } else if (self.currentCommand == .ConnectToCommissionerDevice) {
            self.delegate.meshSetupDidEnterState(state: .CommissionerDeviceReady)
            self.commissionerDeviceConnected(connection: connection)
        } else {
            //TODO: possibly remove this
            fatalError("bluetoothConnectionManagerConnectionCreated when it should not happen")
        }
    }

    func bluetoothConnectionManagerConnectionDropped(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (connection == self.initialDevice.transceiver?.connection || connection == self.commissionerDevice?.transceiver?.connection) {
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
        } else {
            //we dont care
        }
    }
//}

//extension MeshSetupFlowManager {
    //MARK: GetInitialDeviceInfo
    private func stepGetInitialDeviceInfo() {
        self.delegate.meshSetupDidRequestInitialDeviceInfo()
    }

    func setInitialDeviceInfo(deviceType: ParticleDeviceType, dataMatrix: MeshSetupDataMatrix) {
        self.initialDevice = MeshDevice()

        //these flags are used to determine gateway subflow .. if they are set, new network is being created
        //otherwise gateway is joining the existing network so it is important to clear them
        //we cant use selected network, because that part might be reused if multiple devices are connected to same
        //network without disconnecting commissioner
        self.newNetworkPassword = nil
        self.newNetworkName = nil

        self.initialDevice.type = deviceType
        self.initialDevice.credentials = MeshSetupPeripheralCredentials(name: deviceType.description + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        self.stepComplete()
    }


    //MARK: ConnectToInitialDevice
    private func stepConnectToInitialDevice() {
        if (self.bluetoothManager.state != .Ready) {
            self.currentStepFlags["connectWhenReady"] = true
            return
            //TODO: Show appropriate prompt for user to enable the bluetooth
            //code execution will continue in bluethoothManagerDelegate methods when manager state changes to ready
        }

        self.bluetoothManager.createConnection(with: self.initialDevice.credentials!)
        self.delegate.meshSetupDidEnterState(state: .InitialDeviceConnecting)
    }

    private func initialDeviceConnected(connection: MeshSetupBluetoothConnection) {
        self.initialDevice.transceiver = MeshSetupProtocolTransceiver(connection: connection)
        self.stepComplete()
    }



    //MARK: CheckInitialDeviceHasNetworkInterfaces
    private func stepCheckInitialDeviceHasNetworkInterfaces() {
        self.initialDevice.transceiver!.sendGetInterfaceList { result, interfaces in
            self.log("initialDevice.sendGetInterfaceList: \(result), networkCount: \(interfaces?.count)")
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
                //TODO: handle errors?
            }
        }
    }


    //MARK: EnsureDeviceCanBeClaimed
    private func stepEnsureInitialDeviceCanBeClaimed() {
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
    private func stepSetClaimCode() {
        if let claimCode = self.initialDevice.claimCode {
            self.initialDevice.transceiver!.sendSetClaimCode(claimCode: claimCode) { result in
                self.log("sendSetClaimCode: \(result)")
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
    private func stepEnsureInitialDeviceIsNotOnMeshNetwork() {
        self.initialDevice.transceiver!.sendGetNetworkInfo { result, networkInfo in
            self.log("initialDevice.sendGetNetworkInfo: \(result)")
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
            self.initialDeviceLeaveNetwork() //forcing this command helps with the joining process
            //self.stepComplete()
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
            self.log("sendScanNetworks: \(result), networksCount: \(networks?.count)\n\(networks)")
            if (result == .NONE) {
                self.initialDevice.networks = networks
                onComplete()
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
    private func stepGetCommissionerDeviceInfo() {
        //adding more devices to same network
        if (self.commissionerDevice?.credentials != nil) {
            //we need to put the commissioner into listening mode by sending the command
            self.commissionerDevice!.transceiver!.sendStarListening { result in
                self.log("sendStarListening: \(result)")
                if (result == .NONE) {
                    self.stepComplete()
                } else {
                    //TODO: problems...
                }
            }
            return
        }

        self.delegate.meshSetupDidRequestCommissionerDeviceInfo()
    }

    func setCommissionerDeviceInfo(deviceType: ParticleDeviceType, dataMatrix: MeshSetupDataMatrix) {
        self.commissionerDevice = MeshDevice()

        self.commissionerDevice!.type = deviceType
        self.commissionerDevice!.credentials = MeshSetupPeripheralCredentials(name: deviceType.description + "-" + dataMatrix.serialNumber.suffix(6), mobileSecret: dataMatrix.mobileSecret)

        self.stepComplete()
    }

    //MARK: ConnectToCommissionerDevice
    private func stepConnectToCommissionerDevice() {
        //adding more devices to same network
        if (self.commissionerDevice?.transceiver != nil) {
            self.stepComplete()
            return
        }

        if (self.bluetoothManager.state != .Ready) {
            //TODO: Show appropriate prompt for user to enable the bluetooth
            self.currentStepFlags["connectWhenReady"] = true
            //code execution will continue in bluethoothManagerDelegate methods when manager state changes to ready
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
            self.log("commissionerDevice.sendGetNetworkInfo: \(result), networkInfo: \(networkInfo)")

            if (result == .NOT_FOUND) {
                self.commissionerDevice!.networkInfo = nil
            } else if (result == .NONE) {
                self.commissionerDevice!.networkInfo = networkInfo
            } else {
                //TODO: problems
            }

            if (self.selectedNetworkInfo?.extPanID == self.commissionerDevice!.networkInfo?.extPanID) {
                self.stepComplete()
            } else {
                //TODO: fail cause commisioner has no network
            }
        }
    }



    //MARK: EnsureCorrectSelectedNetworkPassword
    private func stepEnsureCorrectSelectedNetworkPassword() {
        self.delegate.meshSetupDidRequestToEnterSelectedNetworkPassword()
    }

    func setSelectedNetworkPassword(_ password: String) {
        self.log("password set: \(password)")
        self.selectedNetworkPassword = password

        /// NOT_FOUND: The device is not a member of a network
        /// NOT_ALLOWED: Invalid commissioning credential
        self.commissionerDevice!.transceiver!.sendAuth(password: password) { result in
            self.log("sendAuth: \(result)")
            if (result == .NONE) {
                self.stepComplete()
            } else {
                //TODO: problems...
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
                //TODO: problems...
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
                //TODO: problems...
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
                    self.joinNetwork()
                }
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

                self.log("====================== attempting to recover ======================")
                self.initialDevice.transceiver!.sendLeaveNetwork { result in
                    self.log("leave network result: \(result)")

                    self.initialDevice.transceiver?.sendScanNetworks { result, networs in
                        self.log("recovery in progress")
                        self.log("sendScanNetworks result: \(result)")
                        self.log("sendScanNetworks result: \(networs)")

                        self.log("lets try prepare joiner once more")
                        self.prepareJoiner()
                    }

                }

                //TODO: problems...
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
                //TODO: problems...
            }
         }
    }

    private func setSetupDone() {
        self.initialDevice.transceiver!.sendDeviceSetupDone (done: true) { result in
            self.log("sendDeviceSetupDone: \(result)")
            if (result == .NONE) {
                self.stopCommissionerListening()
            } else {
                //TODO: problems...
            }
        }
    }


    private func stopCommissionerListening() {
        self.commissionerDevice!.transceiver!.sendStopListening { result in
            self.log("commissionerDevice.sendStopListening: \(result)")
            if (result == .NONE) {
                self.stopInitialDeviceListening(onComplete: self.checkInitialDeviceGotConnected)
            } else {
                //TODO: problems...
            }
        }
    }

    private func stopInitialDeviceListening(onComplete: @escaping () -> ()) {
        self.initialDevice.transceiver!.sendStopListening { result in
            self.log("initialDevice.sendStopListening: \(result)")
            if (result == .NONE) {
                onComplete()
            } else {
                //TODO: problems...
            }
        }
    }


    private func checkInitialDeviceGotConnected() {
        if (self.currentStepFlags["checkInitialDeviceGotConnectedStartTime"] == nil) {
            self.currentStepFlags["checkInitialDeviceGotConnectedStartTime"] = Date()
        }

        let diff = Date().timeIntervalSince(self.currentStepFlags["checkInitialDeviceGotConnectedStartTime"] as! Date)
        log("diff: \(diff)")
        if (diff > 45) {
            //TODO: problem connecting?
            return
        }

        self.initialDevice.transceiver!.sendGetConnectionStatus { result, status in
            self.log("initialDevice.sendGetConnectionStatus: \(result)")
            if (result == .NONE) {
                self.log("status: \(status)")
                if (status == .connected) {
                    self.log("device connected to the cloud")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
                        self.checkInitialDeviceGotClaimed()
                    }
                } else {
                    self.log("device did NOT connect yet")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
                        self.checkInitialDeviceGotConnected()
                    }
                }
            } else {
                //TODO: problems...
            }
        }
    }

    private func checkInitialDeviceGotClaimed() {
        if (self.currentStepFlags["checkInitialDeviceGotClaimedStartTime"] == nil) {
            self.currentStepFlags["checkInitialDeviceGotClaimedStartTime"] = Date()
        }

        let diff = Date().timeIntervalSince(self.currentStepFlags["checkInitialDeviceGotClaimedStartTime"] as! Date)
        log("diff: \(diff)")
        if (diff > 45) {
            //TODO: problem claiming
            return
        }

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
                        self.stepComplete()
                        //TODO: ask for new name
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
            self.log("status: \(idx)")
            self.initialDevice.transceiver!.sendGetInterface(interfaceIndex: idx) { result, interface in
                if (interface!.ipv4Config.addresses.first != nil) {
                    self.initialDevice.hasInternetAddress = true
                    self.stepComplete()
                } else {
                    //TODO: no internet
                }
            }
        } else {
            //TODO: device has no ethernet interface
        }
    }

    //MARK: StopInitialDeviceListening
    private func stepStopInitialDeviceListening() {
        self.stopInitialDeviceListening(onComplete: self.stepComplete)
    }

    //MARK: CheckDeviceGotClaimed
    private func stepCheckDeviceGotClaimed() {
        self.checkInitialDeviceGotConnected()
    }

    //MARK: GetNewDeviceName
    private func stepGetNewDeviceName() {
        self.delegate.meshSetupDidRequestToEnterDeviceName()
    }

    func setDeviceName(name: String) {
        self.log("name entered: \(name)")
        ParticleCloud.sharedInstance().getDevice(self.initialDevice.deviceId!) { device, error in
            if (error == nil) {
                device!.rename(name) { error in
                    if error == nil {
                        self.stepComplete()
                    } else {
                        self.log("rename error: \(error)")
                        //TODO: Error renaming the device
                    }
                }
            } else {
                self.log("getDevice error: \(error)")
                //TODO: Error renaming the device - device was not claimed?
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

        self.delegate.meshSetupDidRequestToAddOneMoreDevice()
    }


    func setAddOneMoreDevice(addOneMoreDevice: Bool) {
        if (addOneMoreDevice) {
            self.currentStep = 0
            self.currentFlow = preflow
            self.runCurrentStep()
        } else {
            //TODO: flow complete
        }
    }


    //MARK: OfferToFinishSetupEarly
    private func stepOfferToFinishSetupEarly() {
        self.delegate.meshSetupDidRequestToFinishSetupEarly()
    }

    func setFinishSetupEarly(finish: Bool) {
        if (finish) {
            //TODO: this not implemented
        } else {
            self.stepComplete()
        }
    }

    //MARK: OfferSelectOrCreateNetwork
    private func stepOfferSelectOrCreateNetwork() {
        self.scanNetworks(onComplete: self.getUserMeshSetupChoice)
    }

    private func getUserMeshSetupChoice() {
        self.delegate.meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: self.initialDevice.networks!)
    }

    func setNetworkNameAndPassword(name: String, password: String) {
        self.log("set network name: \(name), password: \(password)")
        self.newNetworkName = name
        self.newNetworkPassword = password
        self.stepComplete()
    }


    //MARK: CreateNetwork
    private func stepCreateNetwork() {
        self.initialDevice.transceiver!.sendCreateNetwork(name: self.newNetworkName!, password: self.newNetworkPassword!) { result, networkInfo in
            self.log("sendCreateNetwork: \(result), networkInfo: \(networkInfo)")
            if (result == .NONE) {
                self.log("Setting current initial device as commissioner device")
                self.commissionerDevice = self.initialDevice
                self.selectedNetworkInfo = networkInfo!
                self.selectedNetworkPassword = self.newNetworkPassword

                self.initialDevice = MeshDevice()

                self.stepComplete()
            } else {
                //TODO: problem?
            }
        }
    }
}