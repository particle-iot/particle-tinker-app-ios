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


enum flowErrorSeverity {
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

protocol MeshSetupFlowManagerDelegate {
    //    required
    func errorFlow(error : String, severity : flowErrorSeverity, action : flowErrorAction) //
    func errorPeripheralNotSupported()
    func errorBluetoothDisabled()
    func errorPeripheralDisconnected()
    //    optional
    func scannedNetworks(networkNames: [String]?)
}




class MeshSetupFlowManager: NSObject, MeshSetupBluetoothManagerDelegate, MeshSetupProtocolManagerDelegate {

    var bluetoothManager : MeshSetupBluetoothManager?
    var protocolManager  : MeshSetupProtocolManager?
    var flowType : MeshSetupFlowType = .None
//    var delegate : MeshSetupFlowManagerDelegate?
    var currentFlow : MeshSetupFlow?
    var deviceType : ParticleDeviceType?
    var delegate : MeshSetupFlowManagerDelegate?
    
    var mobileSecret : String?
    var claimCode : String?

    
    
   
    
//    var claimCode : String?
    //    var flowState : ...
    
    // meant to be initialized after choosing device type + scanning sticker
    init?(deviceType : ParticleDeviceType, serialNumber : String, mobileSecret : String, claimCode : String) {
        super.init()
        
        self.deviceType = deviceType
        self.mobileSecret = mobileSecret
        self.claimCode = claimCode
        
        var peripheralName : String
        switch deviceType {
            case .argon :
                peripheralName = "Argon-"+serialNumber.suffix(6)
            case .xenon :
                peripheralName = "Xenon-"+serialNumber.suffix(6)
            case .boron :
                peripheralName = "Boron-"+serialNumber.suffix(6)
            case .ESP32 :
                peripheralName = "ESP32-"+serialNumber.suffix(6)
            default:
                return nil
        }
        
        self.flowType = .Detecting
        self.bluetoothManager = MeshSetupBluetoothManager(peripheralName : peripheralName, delegate : self)
    }

    // init?(...modify...)
    
    
    // MARK: MeshSetupProtocolManagerDelegate
    func didReceiveDeviceIdReply(deviceId: String) {
        self.currentFlow!.didReceiveDeviceIdReply(deviceId: deviceId)
    }
    
    func didReceiveClaimCodeReply() {
        //..
    }
    
    func didReceiveAuthReply() {
        //..
    }
    
    func didReceiveIsClaimedReply(isClaimed: Bool) {
        // first action that happens before flow class instance is determined (TBD: commissioner password request in future for already setup devices)
        if (isClaimed == false) {
            switch self.deviceType! {
            case .xenon :
                self.currentFlow = MeshSetupInitialXenonFlow(flowManager: self)
                self.flowType = .InitialXenon
            default:
                self.delegate?.errorFlow(error: "Device not supported yet", severity: .Fatal, action: .Fail)
                return
            }
        } else {
            switch self.deviceType {
                default:
                    self.delegate?.errorFlow(error: "Device already claimed - flow not supported yet", severity: .Fatal, action: .Fail)
                    return
            }
        }
        
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
        self.currentFlow?.didReceiveSetClaimCodeReply()
    }
    
    func didReceiveLeaveNetworkReply() {
        self.currentFlow!.didReceiveLeaveNetworkReply()
    }
    
    func didReceiveGetNetworkInfoReply(networkInfo: MeshSetupNetworkInfo?) {
        self.currentFlow!.didReceiveGetNetworkInfoReply(networkInfo: networkInfo)
    }
    
    func didReceiveScanNetworksReply(networks: [MeshSetupNetworkInfo]) {
        self.currentFlow!.didReceiveScanNetworksReply(networks: networks)
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
        self.delegate?.errorFlow(error: "Device returned control message reply error \(error.description())", severity: .Error, action: .Pop)
    }
    
    
    // MARK: MeshSetupBluetoothManaherDelegate
    func bluetoothDisabled() {
        self.flowType = .None
        self.delegate?.errorBluetoothDisabled()
    }
    
    func messageToUser(level: RMessageType, message: String) {
        // TODO: do we need this? maybe refactor
    }
    
    func didDisconnectPeripheral() {
        self.flowType = .None
        self.delegate?.errorPeripheralDisconnected()
    }
    
    func peripheralReadyForData()
    {
        // first action for all flows is checking if device is claimed - to determine whether its initial setup process or not (update SDD)
        // TODO: add timeout timer after each send
        self.protocolManager?.sendIsClaimed()
    }
    
    func peripheralNotSupported() {
        self.flowType = .None
        self.delegate?.errorPeripheralNotSupported()
        
    }
    
    func didReceiveData(data buffer: Data) {
        self.protocolManager?.didReceiveData(data: buffer)
    }
    
  
    

}
