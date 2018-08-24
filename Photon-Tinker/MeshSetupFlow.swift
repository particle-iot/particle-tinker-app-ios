//
//  MeshSetupFlow.swift
//  Particle
//
//  Created by Ido Kleinman on 7/10/18.
//  Copyright © 2018 spark. All rights reserved.
//


protocol MeshSetupUserInteractionProtocol {
    func userDidSelectNetwork(networkName: String)
    func userDidTypeNetworkPassword(password: String)
}

class MeshSetupFlow: NSObject, MeshSetupProtocolTransceiverDelegate {

    var flowManager: MeshSetupFlowManager?
    var delegate: MeshSetupFlowManagerDelegate?
    var networkName: String? {
        didSet {
            // TODO: remove debug
            print("user selected network \(networkName!)")
        }
    }
    var networkPassword: String? {
        didSet {
            self.userDidSetNetworkPassword(networkPassword: networkPassword!)
        }
    }
    var deviceName: String? {
        didSet {
            self.userDidSetDeviceName(deviceName: deviceName!)
        }
    }
    
    
    required init(flowManager: MeshSetupFlowManager) {
        self.flowManager = flowManager
        self.delegate = flowManager.delegate
    }
    
    // must override in subclass
    func start() {
         fatalError("Must Override in subclass")
    }
    
    func startCommissioner() {
        fatalError("Must Override in subclass")
    }
    
    
    // MARK: MeshSetupProtocolTransceiverDelegate functions - must be overriden in subclass
    func didReceiveDeviceIdReply(sender: MeshSetupProtocolTransceiver, deviceId: String) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveAuthReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveClaimCodeReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveSetClaimCodeReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveIsClaimedReply(sender: MeshSetupProtocolTransceiver, isClaimed: Bool) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveCreateNetworkReply(sender: MeshSetupProtocolTransceiver, networkInfo: MeshSetupNetworkInfo) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveStartCommissionerReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveStopCommissionerReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    func didReceivePrepareJoinerReply(sender: MeshSetupProtocolTransceiver, eui64: String, password: String) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveAddJoinerReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveRemoveJoinerReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveJoinNetworkReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    
    func didReceiveLeaveNetworkReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveGetNetworkInfoReply(sender: MeshSetupProtocolTransceiver, networkInfo: MeshSetupNetworkInfo?) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveScanNetworksReply(sender: MeshSetupProtocolTransceiver, networks: [MeshSetupNetworkInfo]) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveGetSerialNumberReply(sender: MeshSetupProtocolTransceiver, serialNumber: String) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveGetConnectionStatusReply(sender: MeshSetupProtocolTransceiver, connectionStatus: CloudConnectionStatus) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveTestReply(sender: MeshSetupProtocolTransceiver) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveErrorReply(sender: MeshSetupProtocolTransceiver, error: ControlRequestErrorType) {
        // TODO: Set to a generic error handling once Sergey removes error -270 NOT FOUND reply for GetNetworkInfo as valid response
        self.delegate?.flowError(error: "Device returned control message reply error \(error.description())", severity: .Error, action: .Pop)
    }
    
    
    func userDidSetNetworkPassword(networkPassword: String) {
        
    }
    
    func userDidSetDeviceName(deviceName: String) {
       fatalError("Must Override in subclass")
    }
    
    func didReceiveErrorReply(error: ControlRequestErrorType) {
        
    }
    

    func commissionDeviceToNetwork() {
        print("commissionDeviceToNetwork")
        
    }
    
    func didTimeout(sender: MeshSetupProtocolTransceiver, lastCommand: ControlRequestMessageType?) {
        print("Message time out on \(sender.role) - last command sent: \(lastCommand)")
        self.flowManager?.delegate?.flowError(error: "Timeout receiving response from \(sender.role) device", severity: .Error, action: .Pop)
    }
    
    
}
