//
//  MeshSetupFlowManager.swift
//  Particle
//
//  Created by Ido Kleinman on 7/3/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

// TODO: define flows
enum MeshSetupFlowType {
    case none
    case initialSetupXenon
    case initialSetupArgon
    case initialSetupBoron
    case setupXenon
    case setupArgon
    case setupBoron
}

protocol MeshSetupFlowManagerDelegate {
    func errorFlow(error : String) //
    func errorPeripheralNotSupported()
    func errorBluetoothDisabled()
    func errorPeripheralDisconnected()
    
    func scannedNetworks(networkNames: [String]?)
    
}

class MeshSetupFlowManager: NSObject, MeshSetupProtocolManagerDelegate, MeshSetupBluetoothManagerDelegate {
    
    var bluetoothManager : MeshSetupBluetoothManager?
    var protocolManager  : MeshSetupProtocolManager?
    var flowType : MeshSetupFlowType = .none
    var delegate : MeshSetupFlowManagerDelegate?
    
    var claimCode : String?
//    var flowState : ...
    
    override init() {
        
    }
    
    
    // MARK: MeshSetupProtocolManagerDelegate
    func didReceiveDeviceIdReply(deviceId: String) {
        switch self.flowType {
        case .initialSetupXenon:
            ParticleCloud.sharedInstance().getDevices { (userDevices : [ParticleDevice]?, error: Error?) in
                if error == nil {
                    if userDevices!.count > 0 {
                        for device in userDevices! {
                            if device.id == deviceId {
                                // device already claimed to user --
                                // seld.delegate.initialSetupAlreadyClaimed()
                            } else {
                                self.protocolManager?.sendSetClaimCode(self.claimCode!)
                            }
                        }
                    }
                }
            }
            
        default:
            print("other flow")
        }
        
    }
    
    func didReceiveClaimCodeReply() {
        <#code#>
    }
    
    func didReceiveAuthReply() {
        <#code#>
    }
    
    func didReceiveIsClaimedReply(isClaimed: Bool) {
        <#code#>
    }
    
    func didReceiveCreateNetworkReply(networkInfo: MeshSetupNetworkInfo) {
        <#code#>
    }
    
    func didReceiveStartCommissionerReply() {
        <#code#>
    }
    
    func didReceiveStopCommissionerReply() {
        <#code#>
    }
    
    func didReceivePrepareJoinerReply(eui64: String, password: String) {
        <#code#>
    }
    
    func didReceiveAddJoinerReply() {
        <#code#>
    }
    
    func didReceiveRemoveJoinerReply() {
        <#code#>
    }
    
    func didReceiveJoinNetworkReply() {
        <#code#>
    }
    
    func didReceiveSetClaimCodeReply() {
        switch self.flowType {
        case .initialSetupXenon:
                self.protocolManager?.sendGetNetworkInfo()
        default:
            print("other flow")
        }
    }
    
    func didReceiveLeaveNetworkReply() {
        switch self.flowType {
        case .initialSetupXenon:
            self.protocolManager?.sendScanNetworks()
        default:
            print("other flow")
        }
    }
    
    func didReceiveGetNetworkInfoReply(networkInfo: MeshSetupNetworkInfo?) {
        switch self.flowType {
        case .initialSetupXenon:
            if networkInfo == nil {
                self.protocolManager?.sendScanNetworks()
            } else {
                // TODO: add delegate function to inform user Xenon is already part of a network (change flow/prompt user)
                self.protocolManager?.sendLeaveNetwork()
            }
            self.protocolManager?.sendGetNetworkInfo()
        default:
            print("other flow")
        }
    }
    
    func didReceiveScanNetworksReply(networks: [MeshSetupNetworkInfo]) {
        switch self.flowType {
        case .initialSetupXenon:
            if networks.count > 0 {
                var networkNames = [String]()
                for network in networks {
                    networkNames.append(network.name)
                }
                // TODO: add call to ParticleCloud.shared().getNetworks() and compare user owned networks to device reples and make intersection between the two
                // networkNames INTERSECT WITH ParticleCloud reply
                self.delegate?.scannedNetworks(networkNames: networkNames)
            } else {
                self.delegate?.scannedNetworks(networkNames: nil)
            }
            self.protocolManager?.sendGetNetworkInfo()
        default:
            print("other flow")
        }
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
        self.delegate?.errorFlow(error: "Device returned control message reply error \(error.description())")
    }
    
    
    // MARK: MeshSetupBluetoothManaherDelegate
    func bluetoothDisabled() {
        self.flowType = .none
        self.delegate?.errorBluetoothDisabled()
    }
    
    func messageToUser(level: RMessageType, message: String) {
        // TODO: do we need this? maybe refactor
    }
    
    func didDisconnectPeripheral() {
        self.flowType = .none
        self.delegate?.errorPeripheralDisconnected()
    }
    
    func peripheralReadyForData() {
        switch self.flowType {
        case .initialSetupXenon:
            self.protocolManager?.sendGetDeviceId()
            
        default:
            print("x")
        }
        
    }
    
    func peripheralNotSupported() {
        self.flowType = .none
        self.delegate?.errorPeripheralNotSupported()
        
    }
    
    func didReceiveData(data buffer: Data) {
        self.protocolManager?.didReceiveData(data: buffer)
    }
    
  
//    func pair(to deviceName: String) {
//        self.bluetoothManager = MeshSetupBluetoothManager(peripheralName: deviceName, delegate: self)
//    }
    
    func initialSetupXenon(deviceName: String, claimCode : String) {
        self.flowType = .initialSetupXenon
        self.claimCode = claimCode
        self.bluetoothManager = MeshSetupBluetoothManager(peripheralName: deviceName, delegate: self)
        self.protocolManager = MeshSetupProtocolManager(bluetoothManager: self.bluetoothManager!)
        
        
        
    }
    
    // MARK:
    
    

}
