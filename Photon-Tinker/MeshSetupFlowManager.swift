//
//  MeshSetupFlowManager.swift
//  Particle
//
//  Created by Ido Kleinman on 7/3/18.
//  Copyright © 2018 spark. All rights reserved.
//

import Foundation

// TODO: define flows
enum MeshSetupFlowType {
    case None
    case Detecting
    case InitialXenon
    case InitialArgon
    case InitialBoron
    case InitialESP32 // future
    case ModifyXenon // future
    case ModifyArgon // future
    case ModifyBoron // future
    case ModifyESP32 // future
    case Diagnostics // future
    
}


enum MeshSetupErrorSeverity {
    case Info
    case Warning
    case Error
    case Fatal
}

// future
enum flowErrorAction {
    case Dialog
    case Pop
    case Fail
}


enum MeshSetupDeviceRole {
    case Joiner
    case Commissioner
}

protocol MeshSetupFlowManagerDelegate {
    //    required
    func flowError(error : String, severity : MeshSetupErrorSeverity, action : flowErrorAction) //
    func scannedNetworks(networkNames: [String]?)
    func flowManagerReady()
}




class MeshSetupFlowManager: NSObject, MeshSetupBluetoothConnectionManagerDelegate, MeshSetupProtocolTransceiverDelegate {
    
    var joinerProtocol : MeshSetupProtocolTransceiver?
    var commissionerProtocol : MeshSetupProtocolTransceiver?
    var joinerDeviceType : ParticleDeviceType?
    var commissionerDeviceType : ParticleDeviceType?
    private var bluetoothManager : MeshSetupBluetoothConnectionManager?
    private var flowType : MeshSetupFlowType = .None
    private var currentFlow : MeshSetupFlow?
    
    var delegate : MeshSetupFlowManagerDelegate?
    var bluetoothManagerReady = false
    
    var joinerPeripheralName : String? {
        didSet {
            self.createBluetoothConnection(with: joinerPeripheralName!)
        }
    }
    
    var commissionerPeripheralName : String? {
        didSet {
            self.createBluetoothConnection(with: commissionerPeripheralName!)
        }
    }
    
    // meant to be initialized after choosing device type + scanning sticker
    required init(delegate : MeshSetupFlowManagerDelegate) {
        super.init()
        self.delegate = delegate
        self.bluetoothManager = MeshSetupBluetoothConnectionManager(delegate : self)
    }
    
    func startFlow(with deviceType : ParticleDeviceType, as deviceRole : MeshSetupDeviceRole, dataMatrix : String) -> Bool {
        
        if !bluetoothManagerReady {
            return false
        }
        let (serialNumber, mobileSecret) = self.processDataMatrix(dataMatrix: dataMatrix)
        switch deviceRole {
        case .Joiner :
            self.joinerPeripheralName = deviceType.description+"-"+serialNumber.suffix(6)
            self.joinerDeviceType = deviceType
            self.flowType = .Detecting
        case .Commissioner :
            self.commissionerPeripheralName = deviceType.description+"-"+serialNumber.suffix(6)
            self.commissionerDeviceType = deviceType
//            self.flowType = ...
        }
        
        return true

    }
    
    func bluetoothConnectionManagerReady() {
        print("bluetoothConnectionManagerReady")
        
        self.bluetoothManagerReady = true
        self.delegate?.flowManagerReady()
//        self.createBluetoothConnection(with: self.joinerPeripheralName!)
    }
    
    
    func bluetoothConnectionError(connection: MeshSetupBluetoothConnection, error: String, severity: MeshSetupErrorSeverity) {
        print("bluetoothConnectionError [\(connection.peripheralName ?? "peripheral")] \(severity): \(error)")
        self.delegate?.flowError(error: error, severity: severity, action: .Dialog) // TODO: figure out action per error
    }
    
    func bluetoothConnectionManagerError(error: String, severity: MeshSetupErrorSeverity) {
        print("bluetoothConnectionManagerError -- \(severity): \(error)")
        self.delegate?.flowError(error: error, severity: severity, action: .Dialog) // TODO: figure out action per error
        // TODO: analyze error and sometimes:
//        self.bluetoothManagerReady = false
    }
    
    func bluetoothConnectionCreated(connection: MeshSetupBluetoothConnection) {
        print("BLE connection with \(connection.peripheralName!) created")
        // waiting for connection ready
    }
//    func bluetoothConnectionCreated(connection: MeshSetupBluetoothConnection) {
    func bluetoothConnectionReady(connection: MeshSetupBluetoothConnection) {
        if let joiner = joinerPeripheralName {
            if connection.peripheralName! == joiner {
                self.joinerProtocol = MeshSetupProtocolTransceiver(delegate: self, connection: connection)
                print("Joiner BLE connection with \(connection.peripheralName!) ready - sending isClaimed")
                
                // TODO: the right thing
                self.joinerProtocol?.sendIsClaimed()
//                self.joinerProtocol!.sendGetDeviceId()
            }
        }
        
        if let comm = commissionerPeripheralName {
            if connection.peripheralName! == comm {
                self.commissionerProtocol = MeshSetupProtocolTransceiver(delegate: self, connection: connection)
                print("Commissioner BLE connection with \(connection.peripheralName!) ready - sending TBD...")

            }
        }


    }
    
    func createBluetoothConnection(with peripheralName : String) {
        let bleReady = self.bluetoothManager!.createConnection(with: peripheralName)
        if bleReady == false {
            // TODO: handle flow
            self.delegate?.flowError(error: "BLE is not ready to create connection with \(peripheralName)", severity: .Error, action: .Pop)
            print ("BLE is not ready to create connection with \(peripheralName)")
        }
    }
    
    
    func bluetoothConnectionDropped(connection: MeshSetupBluetoothConnection) {

        print("Connection to \(connection.peripheralName!) was dropped")
        if let joiner = joinerPeripheralName {
            if connection.peripheralName! == joiner {
                self.joinerProtocol = nil
            }
        }
        
        if let comm = commissionerPeripheralName {
            if connection.peripheralName! == comm {
                self.commissionerProtocol = nil
            }
        }

        // TODO: check if it was intentional or not via flow - if it wasn't then report an error
        self.delegate?.flowError(error: "BLE connection to \(connection.peripheralName!) was dropped", severity: .Error, action: .Fail) // TODO: figure out action per error


    }
    

    private func processDataMatrix(dataMatrix : String) -> (serialNumer : String, mobileSecret : String) {
        let arr = dataMatrix.split(separator: " ")
        let serialNumber = String(arr[0])//"12345678abcdefg"
        let mobileSecret = String(arr[1])//"ABCDEFGHIJKLMN"
        return (serialNumber, mobileSecret)
    }
    
    func abortFlow() {
        self.bluetoothManager?.dropAllConnections()
//        self.joinerProtocol = nil
//        self.commissionerProtocol = nil
    }
    
    // MARK: MeshSetupProtocolTransceiverDelegate
    func didReceiveDeviceIdReply(deviceId: String) {
        print("didReceiveDeviceIdReply \(deviceId)")
//        self.currentFlow!.didReceiveDeviceIdReply(deviceId: deviceId)
    }
    
    func didReceiveClaimCodeReply() {
        self.currentFlow!.didReceiveClaimCodeReply()
    }
    
    func didReceiveAuthReply() {
        //..
    }
    
    func didReceiveIsClaimedReply(isClaimed: Bool) {
        // first action that happens before flow class instance is determined (TBD: commissioner password request in future for already setup devices or getNetworkInfo - to see if device already on mesh or any other future commands)
        if (isClaimed == false) {
            switch self.joinerDeviceType! {
            case .xenon :
                self.currentFlow = MeshSetupInitialXenonFlow(flowManager: self)
                self.flowType = .InitialXenon
            default:
                self.delegate?.flowError(error: "Device not supported yet", severity: .Fatal, action: .Fail)
                return
            }
        } else {
            switch self.joinerDeviceType! {
                default:
                    self.delegate?.flowError(error: "Device already claimed - flow not supported yet", severity: .Fatal, action: .Fail)
                    return
            }
        }
        
        // pass on all future replies to the current Flow
        self.joinerProtocol?.delegate = self.currentFlow
        // Start the flow
        self.currentFlow!.start()
        
    }
    
    func didReceiveCreateNetworkReply(networkInfo: MeshSetupNetworkInfo) {
        //..
    }
    
    func didReceiveStartCommissionerReply() {
        //..
    }
    
    func didReceiveStopCommissionerReply() {
        //..
    }
    
    func didReceivePrepareJoinerReply(eui64: String, password: String) {
        //..
    }
    
    func didReceiveAddJoinerReply() {
        //..
    }
    
    func didReceiveRemoveJoinerReply() {
        //..
    }
    
    func didReceiveJoinNetworkReply() {
        //..
    }
    
    func didReceiveSetClaimCodeReply() {
//        self.currentFlow?.didReceiveSetClaimCodeReply()
    }
    
    func didReceiveLeaveNetworkReply() {
//        self.currentFlow!.didReceiveLeaveNetworkReply()
    }
    
    func didReceiveGetNetworkInfoReply(networkInfo: MeshSetupNetworkInfo?) {
//        self.currentFlow!.didReceiveGetNetworkInfoReply(networkInfo: networkInfo)
    }
    
    func didReceiveScanNetworksReply(networks: [MeshSetupNetworkInfo]) {
//        self.currentFlow!.didReceiveScanNetworksReply(networks: networks)
    }
    
    func didReceiveGetSerialNumberReply(serialNumber: String) {
        //
    }
    
    func didReceiveGetConnectionStatusReply(connectionStatus: CloudConnectionStatus) {
        //
    }
    
    func didReceiveTestReply() {
        //
        print("Test control message to device OK")
    }
    
    func didReceiveErrorReply(error: ControlRequestErrorType) {
        self.delegate?.flowError(error: "Device returned control message reply error \(error.description())", severity: .Error, action: .Pop)
    }
    
    func didTimeout() {
          self.delegate?.flowError(error: "Timeout receiving response from device", severity: .Error, action: .Pop)
    }
    
    // MARK: MeshSetupBluetoothManaherDelegate
    func bluetoothDisabled() {
        self.flowType = .None
        self.delegate?.flowError(error: "Bluetooth is disabled, please enable bluetooth on your phone to setup your device", severity: .Fatal, action: .Fail)
//        self.delegate?.errorBluetoothDisabled()
    }
    
    func messageToUser(level: RMessageType, message: String) {
        // TODO: do we need this? maybe refactor
    }
    
    
    /*
    func didDisconnectPeripheral() {
        self.flowType = .None
        self.delegate?.flowError(error: "Device disconnected from phone", severity: .Fatal, action: .Fail)
    }
    

    
    
    func peripheralNotSupported() {
        self.flowType = .None
        self.delegate?.flowError(error: "Device does not seems to be a Particle device", severity: .Fatal, action: .Fail)
    }
 
 */
  
    

}
