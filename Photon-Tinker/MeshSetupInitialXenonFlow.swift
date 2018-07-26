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
    //    private var talkingTo : MeshSetupDeviceRole = .Joiner // TODO: detect by sender!
    private var networkInfo : MeshSetupNetworkInfo?
    private var claimTimer : Timer?
    private var claimTryCounter : Int = 0
   
    override func start() {
        print("Starting MeshSetupInitialXenonFlow...")
        print("sendIsClaimed")
        
        self.flowManager!.joinerProtocol?.sendIsClaimed()
    }
    
    override func didReceiveIsClaimedReply(sender: MeshSetupProtocolTransceiver, isClaimed: Bool) {
        // if device claimed then error - other flow needed
        if (isClaimed) {
            self.flowManager!.delegate?.flowError(error: "Device already claimed to user, flow not supported in this app version", severity: .Fatal, action: .Fail)
        } else {
            self.flowManager!.joinerProtocol?.sendGetDeviceId()
        }
    }
   
    override func startCommissioner() {
        self.flowManager!.commissionerProtocol?.sendGetNetworkInfo()
    }
    
    override func didReceiveDeviceIdReply(sender: MeshSetupProtocolTransceiver, deviceId: String) {
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
                             self.flowManager!.delegate?.flowError(error: "Device already claimed to user, flow not supported in this app version", severity: .Error, action: .Pop)
                            deviceIsNew = false
                        }
                    }
                }
                
                if deviceIsNew {
                    ParticleCloud.sharedInstance().generateClaimCode { (claimCode : String?, _, error: Error?) in
                        if error == nil {
                            print("Got claim code from the cloud: \(claimCode!)")
                            self.flowManager!.joinerProtocol?.sendSetClaimCode(claimCode: claimCode!)
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
    
    override func didReceiveSetClaimCodeReply(sender: MeshSetupProtocolTransceiver) {
        print("didReceiveSetClaimCodeReply")
        self.flowManager?.joinerProtocol?.sendGetNetworkInfo()
    }
    
    
    
    override func didReceiveGetNetworkInfoReply(sender: MeshSetupProtocolTransceiver, networkInfo: MeshSetupNetworkInfo?) {
        if sender.role == .Joiner {
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
    
    override func didReceiveScanNetworksReply(sender: MeshSetupProtocolTransceiver, networks: [MeshSetupNetworkInfo]) {
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
    
    
    override func didReceiveLeaveNetworkReply(sender: MeshSetupProtocolTransceiver) {
        print("didReceiveLeaveNetworkReply")
        self.flowManager?.joinerProtocol?.sendScanNetworks()
    }
    
    
    
    override func userDidSetNetworkPassword(networkPassword : String) {
        print("network password set to: \(networkPassword)")
        self.flowManager!.commissionerProtocol?.sendAuth(password: networkPassword)
    }
    
    override func didReceiveAuthReply(sender: MeshSetupProtocolTransceiver) {
        print("network password correct")
        self.flowManager!.delegate?.authSuccess()
    }
    
    
    override func didReceiveStartCommissionerReply(sender: MeshSetupProtocolTransceiver) {
        print("didReceiveStartCommissionerReply from \(sender.role)")
        self.flowManager!.joinerProtocol?.sendPrepareJoiner(networkInfo: self.networkInfo!)
        
    }
    
    override func didReceivePrepareJoinerReply(sender: MeshSetupProtocolTransceiver, eui64: String, password: String) {
        print("didReceivePrepareJoinerReply from \(sender.role)")
        print("eui64: \(eui64), joinerCredential: \(password)")
//        self.eui64 = eui64
//        self.joiningDeviceCredential = password
        self.flowManager!.commissionerProtocol?.sendAddJoiner(eui64: eui64, password: password)
        
        
    }
    
    override func didReceiveAddJoinerReply(sender: MeshSetupProtocolTransceiver) {
        print("didReceiveAddJoinerReply from \(sender.role)")
        self.flowManager!.delegate?.joinerPrepared()
        // TODO: try to add delay before sending this -- debug
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            // delay is needed otherwise joiner returns -1 
            self.flowManager!.joinerProtocol?.sendJoinNetwork()
            print("sent sendJoinNetwork to joiner")
        }
        
    }
    
    
    
    
    
    override func didReceiveJoinNetworkReply(sender: MeshSetupProtocolTransceiver) {
        print("didReceiveJoinNetworkReply from \(sender.role) -- joined mesh network!")
        self.flowManager!.delegate?.joinedNetwork()
        self.flowManager!.commissionerProtocol?.sendStopCommissioner()
        
    }
    
    
    @objc func timerDeviceClaimedByUser() {
        
        if (self.pollDeviceClaimedByUser()) {
            self.claimTimer!.invalidate()
            self.flowManager!.delegate?.deviceOnlineClaimed()
        } else {
            self.claimTryCounter += 1
        }
        if self.claimTryCounter >= 3 { // TODO >= 6
            // TODO: stop mocking success once border routing and claiming works!
            self.flowManager!.delegate?.deviceOnlineClaimed()
            
            self.claimTimer!.invalidate()
            self.flowManager!.delegate?.flowError(error: "Could not claim device to user", severity: .Warning, action: .Dialog)
            
            
        }
    }
    
    override func didReceiveStopCommissionerReply(sender: MeshSetupProtocolTransceiver) {
        print("didReceiveStopCommissionerReply")
        // poll cloud for device
        DispatchQueue.main.async {
            self.claimTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                                 target: self,
                                                 selector: #selector(self.timerDeviceClaimedByUser),
                                                 userInfo: nil,
                                                 repeats: true)

        }
//        RunLoop.current.add(self.claimTimer!, forMode: .commonModes)
        
    }
    
    override func userDidSetDeviceName(deviceName : String) {
        print("user set device name to \(deviceName)")
        self.flowManager!.delegate?.deviceNamed()
        
        // TODO: remove the success mock when real cloud connectivity is achived, validate access token existence
        ParticleCloud.sharedInstance().getDevice(self.deviceID!) { (particleDevice : ParticleDevice?, error : Error?) in
            if (error != nil) {
                self.flowManager!.delegate?.flowError(error: "Could not retrieve device from Particle cloud", severity: .Warning, action: .Dialog)
            } else {
                if let device = particleDevice {
                    device.rename(deviceName, completion: { (error : Error?) in
                        if (error != nil) {
                            self.flowManager!.delegate?.flowError(error: "Could not set device name", severity: .Warning, action: .Dialog)
                            
                        } else {
                            self.flowManager!.delegate?.deviceNamed()
                        }
                    })
                }
                
            }
            
        }
    }
    
    
    override func commissionDeviceToNetwork() {
        print("user ready to start commissionDeviceToNetwork")
        self.flowManager!.commissionerProtocol?.sendStartCommissioner()
    }

    
    
    func pollDeviceClaimedByUser() -> Bool {
        print("pollDeviceClaimedByUser")
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
    override func didReceiveErrorReply(sender: MeshSetupProtocolTransceiver, error: ControlRequestErrorType) {
        func unexpectedFlowError() {
             self.flowManager!.delegate?.flowError(error: "Unexpected flow error", severity: .Fatal, action: .Fail)
        }
        var lastRequestMessageSent : ControlRequestMessageType?
        
        lastRequestMessageSent = sender.getLastRequestMessageSent()
        
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
            case .NOT_ALLOWED :
                if (lastReq == .Auth) {
                    print("network password incorrect")
                    self.flowManager!.delegate?.flowError(error: "Invalid network password", severity: .Error, action: .Dialog)
                }
                if (lastReq == .StartCommissioner) {
                    self.flowManager!.delegate?.flowError(error: "Did not authenticate with network password", severity: .Error, action: .Dialog)
                }
            default :
                    unexpectedFlowError()
                
            }
        } else {
            unexpectedFlowError()
        }
            
    }
  
}
