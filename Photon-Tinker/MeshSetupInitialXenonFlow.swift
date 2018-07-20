//
//  MeshSetupInitialXenonFlowManager.swift
//  Particle
//
//  Created by Ido Kleinman on 7/10/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupInitialXenonFlow: MeshSetupFlow {
    
    var deviceID : String?
    var talkingTo : MeshSetupDeviceRole?
    
    override func start() {
        print("Starting MeshSetupInitialXenonFlow...")
        print("sendGetDeviceId")
        self.talkingTo = .Joiner
        self.flowManager?.joinerProtocol?.sendGetDeviceId()
    }
   
    override func startCommissioner() {
        self.talkingTo = .Commissioner
        self.flowManager?.commissionerProtocol?.sendGetNetworkInfo()
    }
    
    override func didReceiveDeviceIdReply(deviceId: String) {
        print("GetDeviceId reply - device ID: \(deviceId)");
        self.deviceID = deviceId
        var deviceIsNew = true
        ParticleCloud.sharedInstance().getDevices { (userDevices : [ParticleDevice]?, error: Error?) in
            if error == nil {
                if userDevices!.count > 0 {
                    for device in userDevices! {
                        if device.id == deviceId {
                            // device already claimed to user --
                            // seld.delegate.initialSetupAlreadyClaimed()
                             self.delegate?.flowError(error: "Device already claimed to user, flow not supported in this app version", severity: .Error, action: .Pop)
                            deviceIsNew = false
                        }
                    }
                }
                
                if deviceIsNew {
                    ParticleCloud.sharedInstance().generateClaimCode { (claimCode : String?, _, error: Error?) in
                        if error == nil {
                            print("Got claim code from the cloud: \(claimCode!)")
                            self.flowManager!.joinerProtocol!.sendSetClaimCode(claimCode: claimCode!)
                        } else {
                            self.delegate?.flowError(error: "Error communicating with Particle cloud to generate claim code", severity: .Error, action: .Pop)
                        }
                    }
                }

            } else {
                self.flowManager?.delegate?.flowError(error: "Could not retrieve user device list from the Particle cloud", severity: .Error, action: .Pop)
            }
        }
    }
    
    override func didReceiveSetClaimCodeReply() {
        print("didReceiveSetClaimCodeReply")
        self.flowManager?.joinerProtocol?.sendGetNetworkInfo()
    }
    
    override func didReceiveGetNetworkInfoReply(networkInfo: MeshSetupNetworkInfo?) {
        if self.talkingTo == .Joiner {
            print("didReceiveGetNetworkInfoReply")
            if networkInfo == nil { // TODO: this option doesn't happen - reply will be NOT_FOUND response code
                print("No network")
                self.flowManager?.joinerProtocol?.sendScanNetworks()
            } else {
                // TODO: add delegate function to inform user Xenon is already part of a network (change flow/prompt user)
                self.flowManager?.joinerProtocol?.sendLeaveNetwork()
                print("Device is already part of mesh network \(networkInfo!.name)")
                self.delegate?.flowError(error: "Device is already part of mesh network - instructing it to leave the current network", severity: .Warning, action: .Dialog)
            }
        } else {
            // talking to commissioner
            if networkInfo?.name != self.selectedNetwork! {
                self.delegate?.flowError(error: "The device you just scanned is not on the mesh network you selected", severity: .Warning, action: .Pop)
            } else {
                self.flowManager?.delegate?.networkMatch()
            }
            
            
        }
    }
    
    override func didReceiveScanNetworksReply(networks: [MeshSetupNetworkInfo]) {
        print("didReceiveScanNetworksReply - networks:")
        if networks.count > 0 {
            var networkNames = [String]()
            for network in networks {
                networkNames.append(network.name)
                print(network.name)
            }
            // TODO: add call to ParticleCloud.shared().getNetworks() and compare user owned networks to device reples and make intersection between the two
            // networkNames INTERSECT WITH ParticleCloud reply
            self.delegate?.scannedNetworks(networks: networkNames)
        } else {
            self.delegate?.scannedNetworks(networks: nil)
        }
        
//        self.protocolManager?.sendGetNetworkInfo()
//        ???
    }
    
    
    override func didReceiveLeaveNetworkReply() {
        print("didReceiveLeaveNetworkReply")
        self.flowManager?.joinerProtocol?.sendScanNetworks()
    }
    
    
    // TODO: consider using callbacks instead of delegation for FlowManager...
    override func didReceiveErrorReply(error: ControlRequestErrorType) {
        func unexpectedFlowError() {
             self.flowManager?.delegate?.flowError(error: "Unexpected flow error", severity: .Fatal, action: .Fail)
        }
        let lastRequestMessageSent : ControlRequestMessageType? = self.flowManager?.joinerProtocol?.getLastRequestMessageSent()
        
        if let lastReq = lastRequestMessageSent {
        
            switch error {
                case .NOT_FOUND :
                switch lastReq {
                    case .GetNetworkInfo :
                        print("OK - device is not part of a network")
                        self.flowManager?.joinerProtocol?.sendScanNetworks()
                    case .LeaveNetwork :
                        print("Device is not part of a network - nothing to leave")
                        self.flowManager?.joinerProtocol?.sendScanNetworks()
                    default :
                            unexpectedFlowError()
                }
                default :
                    unexpectedFlowError()
                
            }
        } else {
               unexpectedFlowError()
        }
            
    }
    
    
}
