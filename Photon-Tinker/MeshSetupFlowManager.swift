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
    case GetInitialDeviceInfo
    case ConnectToInitialDeviceUsingBLE
    case EnsureDeviceCanBeClaimed
    case CheckInitialDeviceIsSetup
    case CheckInitialDeviceHasNetworkInterfaces
    case DecideFlowSequence
}


enum MeshSetupFlowState {
    case InitialDeviceConnecting
    case InitialDeviceConnected
    case InitialDeviceReady
}

protocol MeshSetupFlowManagerDelegate {
    func meshSetupDidRequestInitialDeviceInfo()

    func meshSetupDidEnterState(state: MeshSetupFlowState)
}

struct MeshDevice {
    var type: ParticleDeviceType?
    var deviceId: String?
    var credentials: MeshSetupPeripheralCredentials?

    var transceiver: MeshSetupProtocolTransceiver?

    var claimCode: String?
    var isClaimed: Bool?

    var isSetupDone: Bool?
    var hasNetworkAccess: Bool?
}

class MeshSetupFlowManager: NSObject, MeshSetupBluetoothConnectionManagerDelegate, MeshSetupTransceiverDelegate {

    private let preflowSequence: [MeshSetupFlowCommands] = [.GetInitialDeviceInfo,
                                                            .ConnectToInitialDeviceUsingBLE,
                                                            .EnsureDeviceCanBeClaimed,
                                                            .CheckInitialDeviceIsSetup,
                                                            .CheckInitialDeviceHasNetworkInterfaces,
                                                            .DecideFlowSequence]

    var delegate: MeshSetupFlowManagerDelegate

    private var bluetoothManager: MeshSetupBluetoothConnectionManager!

    private var initialDevice: MeshDevice!


    private var currentSequence: [MeshSetupFlowCommands]!
    private var currentStep: Int = 0
    private var currentStepFlags: [String: Any]! //if there's shared data needed to properly run the step
    private var currentCommand: MeshSetupFlowCommands {
        return currentSequence[currentStep]
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

    //MARK: Pre-flow
    //pre - flow, before we can determine the flow, we need to know what is the target device,
    //device's current network state, if device is claimed and if device has network interfaces available

    //entry to the flow
    func startSetup() {
        currentSequence = preflowSequence
        currentStep = 0

        self.runCurrentStep()
    }

    private func runCurrentStep() {
        log("currentStep = \(currentStep), currentCommand = \(currentCommand)")
        self.currentStepFlags = [:]
        switch self.currentCommand {
        case .GetInitialDeviceInfo:
            self.getInitialDeviceInfo()
        case .ConnectToInitialDeviceUsingBLE:
            self.connectToInitialDevice()
        case .EnsureDeviceCanBeClaimed:
            self.ensureDeviceCanBeClaimed()
        case .CheckInitialDeviceIsSetup:
            self.checkInitialDeviceIsSetup()
        case .CheckInitialDeviceHasNetworkInterfaces:
            self.checkInitialDeviceHasNetworkInterfaces()
        default:
            log("Unknown command: \(currentSequence[currentStep])")
        }
    }

    private func stepComplete() {
        self.currentStep += 1
        self.runCurrentStep()
    }












    //MARK: BluetoothConnectionManagerDelegate
    func bluetoothConnectionManagerStateChanged(sender: MeshSetupBluetoothConnectionManager, state: MeshSetupBluetoothConnectionManagerState) {
        NSLog("MeshSetupBluetoothConnectionManagerState = \(state)")
        if (self.currentCommand == .ConnectToInitialDeviceUsingBLE) {
            if (self.bluetoothManager.state == .Ready) {
                if let connectWhenReady = self.currentStepFlags["connectWhenReady"] {
                    self.runCurrentStep()
                }
            } else if (self.bluetoothManager.state == .Disabled) {
                //TODO: flow failed?
            }
            //we don't care about other states
        }
        //we don't care about state changes in other steps
    }

    func bluetoothConnectionManagerError(sender: MeshSetupBluetoothConnectionManager, error: BluetoothConnectionManagerError, severity: MeshSetupErrorSeverity) {
        if (self.currentCommand == .ConnectToInitialDeviceUsingBLE) {
            if (error == .DeviceWasConnected) {
                self.currentStepFlags["reconnect"] = true
            } else if (error == .DeviceTooFar) {
                //TODO: show prompt?
            } else {
                //TODO: flow failed?
            }
        } else {
            //TODO: flow failed?
        }
    }

    func bluetoothConnectionManagerConnectionCreated(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.currentCommand == .ConnectToInitialDeviceUsingBLE) {
            self.delegate.meshSetupDidEnterState(state: .InitialDeviceConnected)
        } else {
            //TODO: possibly remove this
            fatalError("bluetoothConnectionManagerConnectionCreated when it should not happen")
        }
    }

    func bluetoothConnectionManagerConnectionBecameReady(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.currentCommand == .ConnectToInitialDeviceUsingBLE) {
            self.delegate.meshSetupDidEnterState(state: .InitialDeviceReady)
            self.initialDevice.transceiver = MeshSetupProtocolTransceiver(delegate: self, connection: connection)

            self.initialDeviceConnected()
        } else {
            //TODO: possibly remove this
            fatalError("bluetoothConnectionManagerConnectionCreated when it should not happen")
        }
    }

    func bluetoothConnectionManagerConnectionDropped(sender: MeshSetupBluetoothConnectionManager, connection: MeshSetupBluetoothConnection) {
        if (self.currentCommand == .ConnectToInitialDeviceUsingBLE) {
            if let reconnect = self.currentStepFlags["reconnect"] {
                self.runCurrentStep()
            } else {
                //TODO: flow failed?
            }
        } else {
            //TODO: flow failed?
        }
    }


    //MARK: MeshSetupTransceiverDelegate
    func didTimeoutSendingMessage(sender: MeshSetupProtocolTransceiver) {
        log("Tranciever timed out: \(sender)")
        //TODO: retry step
    }


}

extension MeshSetupFlowManager {
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
}

extension MeshSetupFlowManager {
    //MARK: ConnectToInitialDevice
    private func connectToInitialDevice() {
        if (self.bluetoothManager.state != .Ready) {
            //TODO: Show appropriate prompt for user to enable the bluetooth
            self.currentStepFlags["connectWhenReady"] = true
            //code execution will continue in bluethoothManagerDelegate methods when manager state changes to ready
            return
        }
        self.bluetoothManager.createConnection(with: self.initialDevice.credentials!)
        self.delegate.meshSetupDidEnterState(state: .InitialDeviceConnecting)
    }

    private func initialDeviceConnected() {
        self.stepComplete()
    }
}

extension MeshSetupFlowManager {
    //MARK: CheckInitialDeviceIsSetup
    private func checkInitialDeviceIsSetup() {
        self.initialDevice.transceiver!.sendIsDeviceSetupDone()
    }

    func didReceiveIsDeviceSetupDoneReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, isDone: Bool) {
        NSLog("didReceiveIsDeviceSetupDoneReply = \(isDone)")
        self.initialDevice.isSetupDone = isDone
        self.stepComplete()
    }
}

extension MeshSetupFlowManager {
    //MARK: CheckInitialDeviceHasNetworkInterfaces
    private func checkInitialDeviceHasNetworkInterfaces() {
        self.initialDevice.transceiver!.sendGetInterfaceList()
    }

    func didReceiveGetInterfaceListReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, networks: [NetworkInterface]) {
        NSLog("didReceiveGetInterfaceListReply = networkCount: \(networks.count)")
        if networks.count > 1 {
            self.initialDevice.hasNetworkAccess = true
        } else {
            self.initialDevice.hasNetworkAccess = false
        }
        self.stepComplete()
    }
}

extension MeshSetupFlowManager {
    //MARK: EnsureDeviceCanBeClaimed
    private func ensureDeviceCanBeClaimed() {
        self.initialDevice.transceiver!.sendGetDeviceId()
    }

    func didReceiveDeviceIdReply(sender: MeshSetupProtocolTransceiver, result: ControlReplyErrorType, deviceId: String) {
        log("didReceiveDeviceIdReply: \(deviceId)")
        self.initialDevice.deviceId = deviceId

        ParticleCloud.sharedInstance().getDevices { [weak self] devices, error in
            guard self != nil else {
                //no longer needed
                return
            }

            guard error == nil else {
                self!.log(error!.localizedDescription)
                //TODO: fail for uknown reason
                return
            }

            if let devices = devices {
                for device in devices {
                    if (device.id == self!.initialDevice.deviceId!) {
                        NSLog("device belongs to user already")
                        self!.initialDevice.isClaimed = true
                        self!.stepComplete()
                        return
                    }
                }
            }

            self!.getClaimCode()
        }
    }

    private func getClaimCode() {
        NSLog("generating claim code")
        ParticleCloud.sharedInstance().generateClaimCode { [weak self] claimCode, userDevices, error in
            guard self != nil else {
                //no longer needed
                return
            }

            guard error == nil else {
                self!.log(error!.localizedDescription)
                //TODO: fail flow? unable to generate claim code
                return
            }

            NSLog("claim code generated")
            self!.initialDevice.claimCode = claimCode
            self!.initialDevice.isClaimed = false
            self!.stepComplete()
        }
    }
}




//enum MeshSetupFlowType {
//    case None
//    case InitialXenon
//}
//
//
//
//enum MeshSetupErrorType: String {
//    case CommissionerNetworksMismatch
//    case BluetoothConnectionError
//    case BluetoothConnectionManagerError
//    case BluetoothNotReady
//    case BluetoothDisabled
//    case DeviceNotSupported
//    case FlowNotSupported // (device already claimed or any other thing)
//    case MessageTimeout
//    case ParticleCloudClaimCodeFailed
//    case ParticleCloudDeviceListFailed
//    case JoinerAlreadyOnMeshNetwork
//    case CouldNotClaimDevice // basically == device cloud connection timeout
//    case CouldNotNameDevice
//    case InvalidNetworkPassword
//    case NotAuthenticated   // tried StartCommissionerRequest but commissioner password was not provided
//    case UnknownFlowError
//}







//    //    required
//    func flowError(error: String, severity: MeshSetupErrorSeverity, action: MeshSetupErrorAction) //
//    // TODO: make these optional
//    func scannedNetworks(networks: [String]?) // joiner returned detected mesh networks (or empty array if none)
//    func flowManagerReady() // flow manager ready to start the flow
//    func networkMatch() // commissioner network matches the user selection - can proceed to ask for password + commissioning
//    func authSuccess()
//    func joinerPrepared()
//    func joinedNetwork()
//    func deviceOnlineClaimed()
//    func deviceNamed()


// Extension to protocol to create hack for optionals
//extension MeshSetupFlowManagerDelegate {
//    func scannedNetworks(networks: [String]?) {  }
//    func flowManagerReady() {}
//    func networkMatch() {}
//}


//protocol MeshSetupFlowManagerDataSource {
//    func
//
//}





//    var joinerProtocol: MeshSetupProtocolTransceiver?
//    var commissionerProtocol: MeshSetupProtocolTransceiver?
//
//    var joinerDeviceType: ParticleDeviceType?
//    var commissionerDeviceType: ParticleDeviceType?
//
//    var networkPassword: String? {
//        didSet {
//            self.currentFlow?.networkPassword = networkPassword
//        }
//    }
//
//    var networkName: String? {
//        didSet {
//            self.currentFlow?.networkName = networkName
//        }
//    }
//
//    var deviceName: String? {
//        didSet {
//            self.currentFlow?.deviceName = deviceName
//        }
//    }
//
//    var delegate: MeshSetupFlowManagerDelegate?
//
//    var bluetoothManagerReady = false
//
//
//    var joinerPeripheralCredentials: MeshSetupPeripheralCredentials? {
//        didSet {
//            print("joinerPeripheralName didSet")
//            self.createBluetoothConnection(with: joinerPeripheralCredentials!)
//        }
//    }

//    var commissionerPeripheralCredentials: MeshSetupPeripheralCredentials? {
//        didSet {
//            print("commissionerPeripheralName didSet")
//            self.createBluetoothConnection(with: commissionerPeripheralCredentials!)
//        }
//    }
//
//    private var bluetoothManager: MeshSetupBluetoothConnectionManager?
//    private var flowType: MeshSetupFlowType = .None // TODO: do we even need this?
//    private var currentFlow: MeshSetupFlow?
//    private var isReady: Bool = false
//
//    // meant to be initialized after choosing device type + scanning sticker
//    required init(delegate: MeshSetupFlowManagerDelegate) {
//        super.init()
//        self.delegate = delegate
//        self.bluetoothManager = MeshSetupBluetoothConnectionManager(delegate: self)
//    }
//
//    func startFlow(with deviceType: ParticleDeviceType, as deviceRole: MeshSetupDeviceRole, dataMatrix: String) -> Bool {
//
//        print("startFlow called - \(deviceRole)")
//        if !bluetoothManagerReady {
//            return false
//        }
//        // TODO: add support for "any" device type by scanning and pairing to SN suffix wildcard only (for commissioner) - TBD - break out to a seperate function
//        let (serialNumber, mobileSecret) = self.processDataMatrix(dataMatrix: dataMatrix)
//
//        switch deviceRole {
//        case .Joiner :
//            self.joinerPeripheralCredentials = MeshSetupPeripheralCredentials(name: deviceType.description+"-"+serialNumber.suffix(6), mobileSecret: mobileSecret)
//            self.joinerDeviceType = deviceType
//            self.flowType = .Detecting
//        case .Commissioner :
//            self.commissionerPeripheralCredentials = MeshSetupPeripheralCredentials(name: deviceType.description+"-"+serialNumber.suffix(6), mobileSecret: mobileSecret)
//            self.commissionerDeviceType = deviceType
////            self.flowType = ...
//        }
//
//        return true
//
//    }
//
//    func bluetoothConnectionManagerReady() {
//        print("bluetoothConnectionManagerReady")
//
//        self.bluetoothManagerReady = true
//        if (!self.isReady) {
//            self.isReady = true
//            self.delegate?.flowManagerReady()
//        }
//
//
////        self.createBluetoothConnection(with: self.joinerPeripheralName!)
//    }
//
//
//    func bluetoothConnectionError(connection: MeshSetupBluetoothConnection, error: String, severity: MeshSetupErrorSeverity) {
//        print("bluetoothConnectionError [\(connection.peripheralName ?? "peripheral")] \(severity): \(error)")
//        self.delegate?.flowError(error: error, severity: severity, action: .Dialog) // TODO: figure out action per error
//    }
//
//    func bluetoothConnectionManagerError(error: String, severity: MeshSetupErrorSeverity) {
//        print("bluetoothConnectionManagerError -- \(severity): \(error)")
//        self.delegate?.flowError(error: error, severity: severity, action: .Dialog) // TODO: figure out action per error
//        // TODO: analyze error and sometimes:
////        self.bluetoothManagerReady = false
//    }
//
//    func bluetoothConnectionCreated(connection: MeshSetupBluetoothConnection) {
//        print("BLE connection with \(connection.peripheralName!) created")
//        // waiting for connection ready
//    }
////    func bluetoothConnectionCreated(connection: MeshSetupBluetoothConnection) {
//    func bluetoothConnectionReady(connection: MeshSetupBluetoothConnection) {
//        if let joiner = joinerPeripheralCredentials {
//            if connection.peripheralName! == joiner.name {
//
//                print("Joiner BLE connection with \(connection.peripheralName!) ready - setting up flow")
//
//
//                switch self.joinerDeviceType! {
//                case .xenon :
//                    self.currentFlow = MeshSetupInitialXenonFlow(flowManager: self)
//                    self.joinerProtocol = MeshSetupProtocolTransceiver(delegate: self.currentFlow!, connection: connection, role: .Joiner)
//                    self.flowType = .InitialXenon
//                    self.currentFlow!.start()
//                default:
//                    self.delegate?.flowError(error: "Device not supported yet", severity: .Fatal, action: .Fail)
//                    return
//                }
//                // TODO: the right thing - pass the decision to current flow, stop being protocol delegate
////                self.joinerProtocol?.sendIsClaimed()
//            }
//        }
//
//        if let comm = commissionerPeripheralCredentials {
//            if connection.peripheralName == comm.name {
//                self.commissionerProtocol = MeshSetupProtocolTransceiver(delegate: self.currentFlow!, connection: connection, role: .Commissioner)
//                print("Commissioner BLE connection with \(connection.peripheralName!) ready")
//                self.currentFlow!.startCommissioner()
//            }
//        }
//
//
//    }
//
//    func createBluetoothConnection(with credentials: MeshSetupPeripheralCredentials) {
//        let bleReady = self.bluetoothManager!.createConnection(with: credentials)
//        if bleReady == false {
//            // TODO: handle flow
//            self.delegate?.flowError(error: "BLE is not ready to create connection with \(credentials)", severity: .Error, action: .Pop)
//            print ("Bluetooth not ready")
//        }
//    }
//
//
//    func bluetoothConnectionDropped(connection: MeshSetupBluetoothConnection) {
//
//        print("Connection to \(connection.peripheralName!) was dropped")
//        if let joiner = joinerPeripheralCredentials {
//            if connection.peripheralName! == joiner.name {
//                self.joinerProtocol = nil
//                self.isReady = false // TODO: check this assumption
//            }
//        }
//
//        if let comm = commissionerPeripheralCredentials {
//            if connection.peripheralName! == comm.name {
//                self.commissionerProtocol = nil
//            }
//        }
//
//        // TODO: check if it was intentional or not via flow - if it wasn't then report an error
//        self.delegate?.flowError(error: "BLE connection to \(connection.peripheralName!) was dropped", severity: .Error, action: .Fail) // TODO: figure out action per error
//
//
//    }
//
//

//
//    func abortFlow() {
//        self.bluetoothManager?.dropAllConnections()
////        self.joinerProtocol = nil
////        self.commissionerProtocol = nil
//    }
//
//
//
//    func commissionDeviceToNetwork() {
//        print("commissionDeviceToNetwork manager")
//        self.currentFlow!.commissionDeviceToNetwork()
//    }
//
//
//    // MARK: MeshSetupBluetoothManaherDelegate
//    func bluetoothDisabled() {
//        self.flowType = .None
//        self.delegate?.flowError(error: "Bluetooth is disabled, please enable bluetooth on your phone to setup your device", severity: .Fatal, action: .Fail)
////        self.delegate?.errorBluetoothDisabled()
//    }

