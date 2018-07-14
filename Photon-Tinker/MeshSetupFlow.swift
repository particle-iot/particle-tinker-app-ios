//
//  MeshSetupFlow.swift
//  Particle
//
//  Created by Ido Kleinman on 7/10/18.
//  Copyright © 2018 spark. All rights reserved.
//


protocol MeshSetupUserInteractionProtocol {
    func userDidSelectNetwork(networkName : String)
    func userDidTypeNetworkPassword(password : String)
}

class MeshSetupFlow: NSObject, MeshSetupProtocolTransceiverDelegate {
   
//    var bluetoothManager : MeshSetupBluetoothManager?
    var flowManager : MeshSetupFlowManager?
//    var protocolManager : MeshSetupProtocolTransceiver?
    var delegate : MeshSetupFlowManagerDelegate?
    
    
    required init(flowManager : MeshSetupFlowManager) {
        self.flowManager = flowManager
        self.delegate = flowManager.delegate
    }
    
    // must override in subclass
    func start() {
         fatalError("Must Override in subclass")
    }
    
    
    // MARK: MeshSetupProtocolTransceiverDelegate functions - must be overriden in subclass
    func didReceiveDeviceIdReply(deviceId: String) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveAuthReply() {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveClaimCodeReply() {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveSetClaimCodeReply() {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveIsClaimedReply(isClaimed: Bool) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveCreateNetworkReply(networkInfo: MeshSetupNetworkInfo) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveStartCommissionerReply() {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveStopCommissionerReply() {
        fatalError("Must Override in subclass")
    }
    
    func didReceivePrepareJoinerReply(eui64: String, password: String) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveAddJoinerReply() {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveRemoveJoinerReply() {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveJoinNetworkReply() {
        fatalError("Must Override in subclass")
    }
    
    
    func didReceiveLeaveNetworkReply() {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveGetNetworkInfoReply(networkInfo: MeshSetupNetworkInfo?) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveScanNetworksReply(networks: [MeshSetupNetworkInfo]) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveGetSerialNumberReply(serialNumber: String) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveGetConnectionStatusReply(connectionStatus: CloudConnectionStatus) {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveTestReply() {
        fatalError("Must Override in subclass")
    }
    
    func didReceiveErrorReply(error: ControlRequestErrorType) {
        fatalError("Must Override in subclass")
    }
    
    
}
