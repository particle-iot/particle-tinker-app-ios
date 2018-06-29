//
//  MeshSetupProtocolManager.swift
//  Particle
//
//  Created by Ido Kleinman on 6/27/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit


class MeshSetupNetworkInfo { // a clean reflection of "Particle_Ctrl_Mesh_NetworkInfo"
    /// Network name
    var name: String?
    /// Extended PAN ID
    var extPanID: String?
    /// PAN ID
    var panID: UInt32?
    /// Channel number
    var channel: UInt32?
    
    init(name : String, extPanID : String, panID : UInt32, channel : UInt32) {
        self.name = name
        self.extPanID = extPanID
        self.panID = panID
        self.channel = channel
    }
}

enum CloudConnectionStatus : UInt16 { // a clean reflection of "Particle_Ctrl_Cloud_ConnectionStatus"
    case disconnected = 0
    case connecting = 1
    case connected = 2
    case disconnecting = 3
}



protocol MeshSetupProtocolManagerDelegate {
    func didReceiveDeviceIdReply(deviceId : String)
    func didReceiveClaimCodeReply()
    func didReceiveAuthReply()
    func didReceiveCreateNetworkReply(networkInfo : MeshSetupNetworkInfo)
    func didReceiveStartCommissionerReply()
    func didReceiveStopCommissionerReply()
    func didReceivePrepareJoinerRequest(eui64 : String, password : String)
    func didReceiveAddJoinerReply()
    func didReceiveRemoveJoinerReply()
    func didReceiveJoinNetworkReply()
    func didReceiveLeaveNetworkReply()
    func didReceiveGetNetworkInfoReply(networkInfo : MeshSetupNetworkInfo)
    func didReceiveScanNetworksReply(networks : [MeshSetupNetworkInfo])
    func didReceiveGetSerialNumberReply(serialNumber : String)
    func didReceiveGetConnectionStatusReply(connectionStatus : CloudConnectionStatus)
    
}


class MeshSetupProtocolManager: NSObject {
    //MARK: - View Properties
    var bluetoothManager    : MeshSetupBluetoothManager?
//    var securityManager     : MeshSetupSecurityManager?
    
    // Commissioning process data
    var requestMessageId    : UInt16 = 0
    var replyRequestTypeDict : [UInt16: ControlRequestMessageType]?
    var waitingForReply     : Bool?
    
    // Commissioning data points
    var networkInfo                     : Particle_Ctrl_Mesh_NetworkInfo?
    var eui64                           : String?
    var commissioningCredPassword       : String?
    var commissioningCredPasswordTry    : String?
    var joiningDeviceCred               : String?
    
    func sendRequestMessage(type : ControlRequestMessageType, payload : Data) {
        
        func showErrorDialog(message : String) {
            print(message)
//            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (_) in }
//            alertController.addAction(cancelAction)
//            self.present(alertController, animated: true, completion: nil)
        }
        
        if let ble = self.bluetoothManager {
            if !ble.isConnected {
                showErrorDialog(message: "BLE is not paired to mesh device")
                return
            }
            
            if let wfr = self.waitingForReply {
                if wfr {
                    showErrorDialog(message: "Waiting to hear back from device for a previously sent command, please wait")
                }
            }
            
            let requestMsg = RequestMessage(id: self.requestMessageId, type: type, size: UInt32(payload.count), data: payload)
            
            // add to state machine dictt to know which type of reply to deserialize
            if self.replyRequestTypeDict != nil {
                self.replyRequestTypeDict![requestMsg.id] = requestMsg.type
            } else {
                self.replyRequestTypeDict = [UInt16: ControlRequestMessageType]()
                self.replyRequestTypeDict![requestMsg.id] = requestMsg.type
            }
            
            DispatchQueue.main.async { // Correct
//                self.activityIndicator.startAnimating()
                self.waitingForReply = true
            }
            self.requestMessageId = self.requestMessageId + 1
            let sendBuffer = RequestMessage.serialize(requestMessage: requestMsg)
            self.bluetoothManager?.send(data: sendBuffer)
            
        } else {
            showErrorDialog(message: "BLE is not paired to mesh device")
        }
        
    }
    
    func sendCreateNetwork(name : String, password : String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_CreateNetworkRequest()
        requestMsgPayload.name = name
        requestMsgPayload.password = password
        self.commissioningCredPasswordTry = password
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_CreateNetworkRequest message")
            return
        }
        self.sendRequestMessage(type: ControlRequestMessageType.CreateNetwork, payload: requestMsgPayloadData)
    }
    
    
    func sendAuth(password : String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_AuthRequest()
        requestMsgPayload.password = password
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_AuthRequest message")
            return
        }
        self.sendRequestMessage(type: .Auth, payload : requestMsgPayloadData)
    }
    
    func sendStartCommissioner() {
        let requestMsgPayload = Particle_Ctrl_Mesh_StartCommissionerRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_StartCommissionerRequest message")
            return
        }
        self.sendRequestMessage(type: .StartCommissioner, payload: requestMsgPayloadData)
    }
    
    func sendPrepareJoiner(networkInfo : Particle_Ctrl_Mesh_NetworkInfo) {
        var requestMsgPayload = Particle_Ctrl_Mesh_PrepareJoinerRequest()
        requestMsgPayload.network = networkInfo
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_PrepareJoinerRequest message")
            return
        }
        self.sendRequestMessage(type: .PrepareJoiner, payload: requestMsgPayloadData)
    }
    
    func sendAddJoiner(eui64 : String, password : String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_AddJoinerRequest()
        requestMsgPayload.eui64 = self.eui64!
        requestMsgPayload.password = self.joiningDeviceCred!
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_AddJoinerRequest message")
            return
        }
        self.sendRequestMessage(type: .AddJoiner, payload: requestMsgPayloadData)
    }
    
    func sendJoinNetwork() {
        let requestMsgPayload = Particle_Ctrl_Mesh_JoinNetworkRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_JoinNetworkRequest message")
            return
        }
        self.sendRequestMessage(type: .JoinNetwork, payload: requestMsgPayloadData)
    }
    
    func sendStopCommissioner() {
        let requestMsgPayload = Particle_Ctrl_Mesh_StopCommissionerRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_StopCommissionerRequest message")
            return
        }
        self.sendRequestMessage(type: .StopCommissioner, payload: requestMsgPayloadData)
    }
    
    func sendLeaveNetwork() {
        let requestMsgPayload = Particle_Ctrl_Mesh_LeaveNetworkRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_LeaveNetworkRequest message")
            return
        }
        self.sendRequestMessage(type: .LeaveNetwork, payload: requestMsgPayloadData)
    }
    
    
}
