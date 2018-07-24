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
    var networkInfo : MeshSetupNetworkInfo?
    var claimTimer : Timer?
    var claimTryCounter : Int = 0
    
    override func start() {
        print("Starting MeshSetupInitialXenonFlow...")
        print("sendGetDeviceId")
        self.talkingTo = .Joiner
        self.flowManager!.joinerProtocol?.sendGetDeviceId()
    }
   
    override func startCommissioner() {
        self.talkingTo = .Commissioner
        self.flowManager!.commissionerProtocol!.sendGetNetworkInfo()
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
                self.flowManager!.delegate?.flowError(error: "Could not retrieve user device list from the Particle cloud", severity: .Error, action: .Pop)
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
                self.flowManager!.joinerProtocol?.sendScanNetworks()
            } else {
                // TODO: add delegate function to inform user Xenon is already part of a network (change flow/prompt user)
                self.flowManager!.joinerProtocol?.sendLeaveNetwork()
                print("Device is already part of mesh network \(networkInfo!.name)")
                self.delegate?.flowError(error: "Device is already part of mesh network - instructing it to leave the current network", severity: .Warning, action: .Dialog)
            }
        } else {
            // talking to commissioner
            print("didReceiveGetNetworkInfoReply from commissioner")
            
            if networkInfo!.name != self.networkName! {
                
                self.delegate?.flowError(error: "The device you just scanned is not on the mesh network you selected", severity: .Warning, action: .Pop)
            } else {
                self.networkInfo = networkInfo
                self.flowManager!.delegate!.networkMatch()
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
    
    
    
    override func userDidSetNetworkPassword(networkPassword : String) {
        self.talkingTo = .Commissioner
        self.flowManager!.commissionerProtocol?.sendAuth(password: networkPassword)
    }
    
    override func didReceiveAuthReply() {
        self.talkingTo = .Commissioner
        self.flowManager!.commissionerProtocol?.sendStartCommissioner()
    }
    
    override func didReceiveStartCommissionerReply() {
        self.talkingTo = .Joiner
        self.flowManager!.joinerProtocol?.sendPrepareJoiner(networkInfo: self.networkInfo!)
        
    }
    
    override func didReceivePrepareJoinerReply(eui64: String, password: String) {
//        self.eui64 = eui64
//        self.joiningDeviceCredential = password
        self.talkingTo = .Commissioner
        
        self.flowManager!.commissionerProtocol?.sendAddJoiner(eui64: eui64, password: password)
        
        
    }
    
    override func didReceiveAddJoinerReply() {
        self.talkingTo = .Joiner
        self.flowManager!.delegate?.joinerPrepared()
        self.flowManager!.joinerProtocol!.sendJoinNetwork()
    }
    
    
    
    
    
    override func didReceiveJoinNetworkReply() {
        self.flowManager!.delegate?.joinedNetwork()
        // TODO: do it in non iOS 10 supported only way
        // poll cloud for device
        if #available(iOS 10.0, *) {
            self.claimTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer : Timer ) in
                
                
                if (self.pollDeviceClaimedByUser()) {
                    timer.invalidate()
                    self.flowManager!.delegate?.deviceOnlineClaimed()
                } else {
                    self.claimTryCounter += 1
                }
                if self.claimTryCounter == 6 {
                    self.flowManager!.delegate?.flowError(error: "Could not claim device to user", severity: .Error, action: .Pop)
                }
            })
        } else {
            // Fallback on earlier versions
            print("need iOS 10+ for polling device claiming")
        }
        
    }
    
    override func userDidSetDeviceName(deviceName : String) {
        ParticleCloud.sharedInstance().getDevice(self.deviceID!) { (particleDevice : ParticleDevice?, error : Error?) in
            if (error != nil) {
                self.flowManager!.delegate?.flowError(error: "Could not retrieve device from Particle cloud", severity: .Error, action: .Dialog)
            } else {
                if let device = particleDevice {
                    device.rename(deviceName, completion: { (error : Error?) in
                        if (error != nil) {
                            self.flowManager!.delegate?.flowError(error: "Could not set device name", severity: .Error, action: .Dialog)
                        } else {
                            self.flowManager!.delegate?.deviceNamed()
                        }
                    })
                }
                
            }
            
        }
    }
    
    
    func pollDeviceClaimedByUser() -> Bool {
        var r = false
        ParticleCloud.sharedInstance().getDevices { (userDevices : [ParticleDevice]?, error: Error?) in
            if error == nil {
                if userDevices!.count > 0 {
                    for device in userDevices! {
                        if device.id == self.deviceID {
                            r = true
                        }
                    }
                }
                
            } else {
                // TODO: add error code
                self.flowManager!.delegate?.flowError(error: "Could not retrieve user device list from the Particle cloud", severity: .Error, action: .Pop)
            }
        }
        
        return r
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
