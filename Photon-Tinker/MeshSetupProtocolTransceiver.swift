//
//  MeshSetupProtocolTransceiver.swift
//  Particle
//
//  Created by Ido Kleinman on 6/27/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

typealias MeshSetupNetworkInfo = Particle_Ctrl_Mesh_NetworkInfo
typealias CloudConnectionStatus = Particle_Ctrl_Cloud_ConnectionStatus


// TODO: refactor to include sender to be able to determine delegate call from joiner or commssioner
protocol MeshSetupProtocolTransceiverDelegate {
    func didReceiveDeviceIdReply(deviceId : String)
    func didReceiveClaimCodeReply()
    func didReceiveAuthReply()
    func didReceiveIsClaimedReply(isClaimed : Bool)
    func didReceiveCreateNetworkReply(networkInfo : MeshSetupNetworkInfo)
    func didReceiveStartCommissionerReply()
    func didReceiveStopCommissionerReply()
    func didReceivePrepareJoinerReply(eui64 : String, password : String)
    func didReceiveAddJoinerReply()
    func didReceiveRemoveJoinerReply()
    func didReceiveJoinNetworkReply()
    func didReceiveSetClaimCodeReply()
    func didReceiveLeaveNetworkReply()
    func didReceiveGetNetworkInfoReply(networkInfo : MeshSetupNetworkInfo?)
    func didReceiveScanNetworksReply(networks : [MeshSetupNetworkInfo])
    func didReceiveGetSerialNumberReply(serialNumber : String)
    func didReceiveGetConnectionStatusReply(connectionStatus : CloudConnectionStatus)
    func didReceiveTestReply()
    
    func didReceiveErrorReply(error: ControlRequestErrorType)
    func didTimeout()
//    func bluetoothConnectionError(
    
}


class MeshSetupProtocolTransceiver: NSObject, MeshSetupBluetoothConnectionDataDelegate {
    
    //MARK: - View Properties
    private var bluetoothConnection    : MeshSetupBluetoothConnection?
//    var securityManager     : MeshSetupSecurityManager?
    
    // Commissioning process data
    private var requestMessageId     : UInt16 = 1
    private var replyRequestTypeDict : [UInt16: ControlRequestMessageType]?
    private var waitingForReply      : Bool = false
//    var deviceRole          : MeshSetupDeviceRole?
    var delegate                     : MeshSetupProtocolTransceiverDelegate?
    
    private var requestTimer        : Timer?
    var timeoutValue                : TimeInterval = 5.0 // seconds
    
    required init(delegate : MeshSetupProtocolTransceiverDelegate, connection : MeshSetupBluetoothConnection) {
        super.init()
        self.delegate = delegate
        self.bluetoothConnection = connection
        self.bluetoothConnection?.delegate = self // take over didReceiveData delegate
    }
    
    private func sendRequestMessage(type : ControlRequestMessageType, payload : Data) {
        
        func showErrorDialog(message : String) {
            print(message)
        }
        
        if let ble = self.bluetoothConnection {
            if !ble.isReady {
                showErrorDialog(message: "BLE is not paired to mesh device")
                return
            }
            
            if self.waitingForReply {
                    showErrorDialog(message: "Waiting to hear back from device for a previously sent command, please wait")
            }
            
            let requestMsg = RequestMessage(id: self.requestMessageId, type: type, size: UInt32(payload.count), data: payload)
            
            // add to state machine dictt to know which type of reply to deserialize
            if self.replyRequestTypeDict != nil {
                self.replyRequestTypeDict![requestMsg.id] = requestMsg.type
            } else {
                self.replyRequestTypeDict = [UInt16: ControlRequestMessageType]()
                self.replyRequestTypeDict![requestMsg.id] = requestMsg.type
            }
            
            self.waitingForReply = true
            self.requestMessageId = self.requestMessageId + 1
            if (requestMessageId >= 0xff00) {
                self.requestMessageId = 1
            }
            let sendBuffer = RequestMessage.serialize(requestMessage: requestMsg)
            self.bluetoothConnection!.send(data: sendBuffer)
            
            
            self.requestTimer = Timer.scheduledTimer(timeInterval: self.timeoutValue,
                                 target: self,
                                 selector: #selector(self.requestTimeout),
                                 userInfo: nil,
                                 repeats: false)
            
        } else {
            showErrorDialog(message: "BLE is not paired to mesh device")
        }
        
    }
    
    @objc func requestTimeout() {
        print("Request Timeout")
        self.delegate?.didTimeout()
        self.requestTimer = nil
    }
    
    func getLastRequestMessageSent() -> ControlRequestMessageType? {
        if (self.replyRequestTypeDict != nil) {
            return replyRequestTypeDict![requestMessageId-1]
        } else {
            return nil
        }
    }
    
    func sendGetDeviceId() {
        let requestMsgPayload = Particle_Ctrl_GetDeviceIdRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_GetDeviceIdRequest message")
            return
        }
        print("sending getDeviceId")
        self.sendRequestMessage(type: .GetDeviceId, payload: requestMsgPayloadData)
    }
    
    
    
    func sendCreateNetwork(name : String, password : String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_CreateNetworkRequest()
        requestMsgPayload.name = name
        requestMsgPayload.password = password
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_CreateNetworkRequest message")
            return
        }
        self.sendRequestMessage(type: ControlRequestMessageType.CreateNetwork, payload: requestMsgPayloadData)
    }
    
    func sendSetClaimCode(claimCode : String) {
        var requestMsgPayload = Particle_Ctrl_SetClaimCodeRequest()
        requestMsgPayload.code = claimCode
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_SetClaimCodeRequest message")
            return
        }
        self.sendRequestMessage(type: .SetClaimCode, payload : requestMsgPayloadData)
    }

    func sendGetNetworkInfo() {
        let requestMsgPayload = Particle_Ctrl_Mesh_GetNetworkInfoRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_GetNetworkInfoRequest message")
            return
        }
        self.sendRequestMessage(type: .GetNetworkInfo, payload : requestMsgPayloadData)
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
    
    
    func sendScanNetworks() {
        let requestMsgPayload = Particle_Ctrl_Mesh_ScanNetworksRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_ScanNetworksRequest message")
            return
        }
        self.sendRequestMessage(type: .ScanNetworks, payload : requestMsgPayloadData)
    }
    
    func sendStartCommissioner() {
        let requestMsgPayload = Particle_Ctrl_Mesh_StartCommissionerRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_StartCommissionerRequest message")
            return
        }
        self.sendRequestMessage(type: .StartCommissioner, payload: requestMsgPayloadData)
    }
    
    func sendIsClaimed() {
        let requestMsgPayload = Particle_Ctrl_IsClaimedRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_IsClaimedRequest message")
            return
        }
        print("sending isClaimed")
        self.sendRequestMessage(type: .IsClaimed, payload: requestMsgPayloadData)

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
        requestMsgPayload.eui64 = eui64
        requestMsgPayload.password = password
        
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
    
    
    func bluetoothConnectionDidReceiveData(sender: MeshSetupBluetoothConnection, data: Data) {
        // TODO: error handler
        let rm = ReplyMessage.deserialize(buffer: data)
        
        self.waitingForReply = false
        self.requestTimer?.invalidate()

        if let data = rm.data {
            if rm.result == .NONE {
                print("Received reply message id \(rm.id) --> Payload: \(data.hexString)")
                //                let replyMessageContents
                var decodedReply : Any?
                let replyRequestType = self.replyRequestTypeDict![rm.id]
                
                switch replyRequestType! {
                    
                case .GetDeviceId:
                    
                    do {
                        decodedReply = try Particle_Ctrl_GetDeviceIdReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply GetDeviceIdReply")
                        return
                    }
                    let deviceId = (decodedReply as! Particle_Ctrl_GetDeviceIdReply).id
                    self.delegate?.didReceiveDeviceIdReply(deviceId: deviceId)
                    
                case .GetNetworkInfo:
                    fallthrough
                // GetNetworkInfoReply and CreateNetworkReply are the same!
                case .CreateNetwork:
                    do {
                        decodedReply = try Particle_Ctrl_Mesh_GetNetworkInfoReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply GetNetworkInfoReply")
                        return
                    }
                    
                    let networkInfo : MeshSetupNetworkInfo = (decodedReply as! Particle_Ctrl_Mesh_GetNetworkInfoReply).network
//                    self.networkInfo = MeshSetupNetworkInfo.init(name: rawNetworkInfo.name, extPanID: rawNetworkInfo.extPanID, panID: rawNetworkInfo.panID, channel: rawNetworkInfo.channel)
                    
                    // TODO: remove debug print
                    print("networkInfo:")
                    let msg = "Name: \(networkInfo.name)\nXPAN ID: \(networkInfo.extPanID)\nPAN ID: \(networkInfo.panID)\nChannel: \(networkInfo.channel)"
                    print(msg)

                    if replyRequestType! == .CreateNetwork {
                        self.delegate?.didReceiveCreateNetworkReply(networkInfo: networkInfo)
                    } else {
                        // TODO: check if this is how an empty reply behaves?
                        if networkInfo.name.isEmpty {
                            self.delegate?.didReceiveGetNetworkInfoReply(networkInfo: nil)
                        } else {
                            self.delegate?.didReceiveGetNetworkInfoReply(networkInfo: networkInfo)
                        }
                    }
                    
                    
                case .PrepareJoiner:
                    print("PrepareJoiner reply");
                    do {
                        decodedReply = try Particle_Ctrl_Mesh_PrepareJoinerReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply PrepareJoinerReply")
                        return
                    }
                    let prepareJoinerReply = (decodedReply as! Particle_Ctrl_Mesh_PrepareJoinerReply)
                    self.delegate?.didReceivePrepareJoinerReply(eui64: prepareJoinerReply.eui64, password: prepareJoinerReply.password)
                    
                    
                case .ScanNetworks:
                    do {
                        decodedReply = try Particle_Ctrl_Mesh_ScanNetworksReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply ScanNetworksReply")
                        return
                    }
                    print("ScanNetworksReply")
                    print("\(String(describing: decodedReply))") // TODO: process repeated ???
                    
                    self.delegate?.didReceiveScanNetworksReply(networks: (decodedReply as! Particle_Ctrl_Mesh_ScanNetworksReply).networks)
                    

                case .GetConnectionStatus:
                    
                    do {
                        decodedReply = try Particle_Ctrl_Cloud_GetConnectionStatusReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply GetConnectionStatusReply")
                        return
                    }
                    self.delegate?.didReceiveGetConnectionStatusReply(connectionStatus: (decodedReply as! Particle_Ctrl_Cloud_GetConnectionStatusReply).status)

                case .GetSerialNumber:
                    do {
                        decodedReply = try Particle_Ctrl_GetSerialNumberReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply GetSerialNumberRequest")
                        return
                    }
                    let sn = (decodedReply as! Particle_Ctrl_GetSerialNumberReply).serial
                    self.delegate?.didReceiveGetSerialNumberReply(serialNumber: sn)

                case .IsClaimed:
                    print("IsClaimed reply");
                    do {
                        decodedReply = try Particle_Ctrl_IsClaimedReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply IsClaimedReply")
                        return
                    }
                    let isClaimed = (decodedReply as! Particle_Ctrl_IsClaimedReply).claimed
                    self.delegate?.didReceiveIsClaimedReply(isClaimed: isClaimed)

                case .AddJoiner:
                    self.delegate?.didReceiveAddJoinerReply()
                    
                case .Auth:
                    self.delegate?.didReceiveAuthReply()

                case .JoinNetwork:
                    self.delegate?.didReceiveJoinNetworkReply()

                case .LeaveNetwork:
                    self.delegate?.didReceiveLeaveNetworkReply()
                    
                case .StartCommissioner:
                    self.delegate?.didReceiveStartCommissionerReply()
                    
                case .StopCommissioner:
                    self.delegate?.didReceiveStopCommissionerReply()

                case .SetClaimCode:
                    self.delegate?.didReceiveSetClaimCodeReply()
                    
                case .GetSecurityKey:
                    fallthrough // ???
                case .SetSecurityKey:
                    // TODO: what are those for ???
                    print("what are those for?!")
                    
                case .RemoveJoiner:
                    self.delegate?.didReceiveRemoveJoinerReply()
                    
                case .Test:
                    // TODO: remove for production
                    self.delegate?.didReceiveTestReply()
                }
                
                
            } else {
                // TODO: decode reply error type into english via raw values 
                print("Reply Error: \(rm.result)")
                self.delegate?.didReceiveErrorReply(error: rm.result)
                
            }
        }
    }
}
