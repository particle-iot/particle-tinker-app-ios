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
        print("Starting flow...")
        print("sendGetDeviceId")
        self.flowManager?.joinerProtocol?.sendGetDeviceId()
    }
   
    override func didReceiveDeviceIdReply(deviceId: String) {
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
        print("didReceiveGetNetworkInfoReply")
        if networkInfo == nil {
            print("No network")
            self.flowManager?.joinerProtocol?.sendScanNetworks()
        } else {
            // TODO: add delegate function to inform user Xenon is already part of a network (change flow/prompt user)
            self.flowManager?.joinerProtocol?.sendLeaveNetwork()
            print("Device is already part of mesh network \(networkInfo?.name)")
            self.delegate?.flowError(error: "Device is already part of mesh network - instructing it to leave the current network", severity: .Warning, action: .Dialog)
        }
    }
    
    override func didReceiveScanNetworksReply(networks: [MeshSetupNetworkInfo]) {
        print("didReceiveGetNetworkInfoReply - networks:")
        if networks.count > 0 {
            var networkNames = [String]()
            for network in networks {
                networkNames.append(network.name)
                print(network.name)
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
        print("didReceiveGetNetworkInfoReply")
        self.flowManager?.joinerProtocol?.sendScanNetworks()
    }
    
    
    
    
    

}
