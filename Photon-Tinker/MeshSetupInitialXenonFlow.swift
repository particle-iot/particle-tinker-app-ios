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
    
    override func start() {
        self.protocolManager?.sendGetDeviceId()
    }
   
    override func didReceiveDeviceIdReply(deviceId: String) {
            self.deviceID = deviceId
            ParticleCloud.sharedInstance().getDevices { (userDevices : [ParticleDevice]?, error: Error?) in
                if error == nil {
                    if userDevices!.count > 0 {
                        for device in userDevices! {
                            if device.id == deviceId {
                                // device already claimed to user --
                                // seld.delegate.initialSetupAlreadyClaimed()
                                 self.delegate?.flowError(error: "Device already claimed to user, flow not supported in this app version", severity: .Error, action: .Pop)
                            } else {
                                ParticleCloud.sharedInstance().generateClaimCode { (claimCode : String?, _, error: Error?) in
                                    if error == nil {
                                        self.protocolManager?.sendSetClaimCode(claimCode: claimCode!)
                                    } else {
                                        self.delegate?.flowError(error: "Error communicating with Particle cloud to generate claim code", severity: .Error, action: .Pop)
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    override func didReceiveSetClaimCodeReply() {
        self.protocolManager?.sendGetNetworkInfo()
    }
    
    override func didReceiveGetNetworkInfoReply(networkInfo: MeshSetupNetworkInfo?) {
        if networkInfo == nil {
            self.protocolManager?.sendScanNetworks()
        } else {
            // TODO: add delegate function to inform user Xenon is already part of a network (change flow/prompt user)
            self.protocolManager?.sendLeaveNetwork()
            self.delegate?.flowError(error: "Device is already part of mesh network - instructing it to leave the current network", severity: .Warning, action: .Dialog)
        }
    }
    
    override func didReceiveScanNetworksReply(networks: [MeshSetupNetworkInfo]) {
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
        
//        self.protocolManager?.sendGetNetworkInfo()
//        ???
    }
    
    
    override func didReceiveLeaveNetworkReply() {
        self.protocolManager?.sendScanNetworks()
    }
    
    
    
    
    

}
