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
    func didReceiveDeviceIdReply(sender: MeshSetupProtocolTransceiver, deviceId: String)
    func didReceiveClaimCodeReply(sender: MeshSetupProtocolTransceiver)
    func didReceiveAuthReply(sender: MeshSetupProtocolTransceiver)
    func didReceiveIsClaimedReply(sender: MeshSetupProtocolTransceiver, isClaimed: Bool)
    func didReceiveCreateNetworkReply(sender: MeshSetupProtocolTransceiver, networkInfo: MeshSetupNetworkInfo)
    func didReceiveStartCommissionerReply(sender: MeshSetupProtocolTransceiver)
    func didReceiveStopCommissionerReply(sender: MeshSetupProtocolTransceiver)
    func didReceivePrepareJoinerReply(sender: MeshSetupProtocolTransceiver, eui64: String, password: String)
    func didReceiveAddJoinerReply(sender: MeshSetupProtocolTransceiver)
    func didReceiveRemoveJoinerReply(sender: MeshSetupProtocolTransceiver)
    func didReceiveJoinNetworkReply(sender: MeshSetupProtocolTransceiver)
    func didReceiveSetClaimCodeReply(sender: MeshSetupProtocolTransceiver)
    func didReceiveLeaveNetworkReply(sender: MeshSetupProtocolTransceiver)
    func didReceiveGetNetworkInfoReply(sender: MeshSetupProtocolTransceiver, networkInfo: MeshSetupNetworkInfo?)
    func didReceiveScanNetworksReply(sender: MeshSetupProtocolTransceiver, networks: [MeshSetupNetworkInfo])
    func didReceiveGetSerialNumberReply(sender: MeshSetupProtocolTransceiver, serialNumber: String)
    func didReceiveGetConnectionStatusReply(sender: MeshSetupProtocolTransceiver, connectionStatus: CloudConnectionStatus)
    func didReceiveTestReply(sender: MeshSetupProtocolTransceiver)
    
    func didReceiveErrorReply(sender: MeshSetupProtocolTransceiver, error: ControlRequestErrorType)
    func didTimeout(sender: MeshSetupProtocolTransceiver, lastCommand: ControlRequestMessageType?)
//    func bluetoothConnectionError(
    
}


class MeshSetupProtocolTransceiver: NSObject, MeshSetupBluetoothConnectionDataDelegate {
    
    var role: MeshSetupDeviceRole = .Joiner
    var delegate: MeshSetupProtocolTransceiverDelegate?
    var timeoutValue: TimeInterval = 15.0 // seconds

    //MARK: - View Properties
    private var bluetoothConnection: MeshSetupBluetoothConnection
    private var encryptionManager: MeshSetupEncryptionManager

    // Commissioning process data
    private var requestMessageId: UInt16 = 1
    private var replyRequestTypeDict: [UInt16: ControlRequestMessageType] = [:]

    private var waitingForReply: Bool = false
    private var requestTimer: Timer?

    private var rxBuffer: Data = Data()
    
    required init(delegate: MeshSetupProtocolTransceiverDelegate, connection: MeshSetupBluetoothConnection, role: MeshSetupDeviceRole) {
        self.delegate = delegate
        self.role = role
        self.bluetoothConnection = connection
        self.encryptionManager = MeshSetupEncryptionManager(derivedSecret: bluetoothConnection.derivedSecret!)

        super.init()

        self.bluetoothConnection.delegate = self // take over didReceiveData delegate
    }
    
    private func sendRequestMessage(type: ControlRequestMessageType, payload: Data) {
        func showErrorDialog(message: String) {
            print(message)
        }
        
        if self.waitingForReply {
            showErrorDialog(message: "Waiting to hear back from device for a previously sent command, please wait")
        }

        let requestMsg = RequestMessage(id: self.requestMessageId, type: type, data: payload)

        //encrypt
        self.encryptionManager.encrypt(requestMsg)

        // add to state machine dictt to know which type of reply to deserialize
        self.replyRequestTypeDict[requestMsg.id] = requestMsg.type

        self.waitingForReply = true
        self.requestMessageId += 1
        if (requestMessageId >= 0xff00) {
            self.requestMessageId = 1
        }
        self.bluetoothConnection.send(data: encryptionManager.encrypt(requestMsg))


        self.requestTimer = Timer.scheduledTimer(timeInterval: self.timeoutValue,
                             target: self,
                             selector: #selector(self.requestTimeout),
                             userInfo: nil,
                             repeats: false)

    }
    
    @objc func requestTimeout() {
        print("Request Timeout")
        self.delegate?.didTimeout(sender: self, lastCommand: self.getLastRequestMessageSent())
        self.requestTimer = nil
    }
    
    func getLastRequestMessageSent() -> ControlRequestMessageType? {
        if (self.replyRequestTypeDict[requestMessageId-1] != nil) {
            return replyRequestTypeDict[requestMessageId-1]
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
    
    
    
    func sendCreateNetwork(name: String, password: String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_CreateNetworkRequest()
        requestMsgPayload.name = name
        requestMsgPayload.password = password
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_CreateNetworkRequest message")
            return
        }
        self.sendRequestMessage(type: ControlRequestMessageType.CreateNetwork, payload: requestMsgPayloadData)
    }
    
    func sendSetClaimCode(claimCode: String) {
        var requestMsgPayload = Particle_Ctrl_SetClaimCodeRequest()
        requestMsgPayload.code = claimCode
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_SetClaimCodeRequest message")
            return
        }
        self.sendRequestMessage(type: .SetClaimCode, payload: requestMsgPayloadData)
    }

    func sendGetNetworkInfo() {
        let requestMsgPayload = Particle_Ctrl_Mesh_GetNetworkInfoRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_GetNetworkInfoRequest message")
            return
        }
        self.sendRequestMessage(type: .GetNetworkInfo, payload: requestMsgPayloadData)
    }
    
    func sendAuth(password: String) {
        var requestMsgPayload = Particle_Ctrl_Mesh_AuthRequest()
        requestMsgPayload.password = password
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_AuthRequest message")
            return
        }
        self.sendRequestMessage(type: .Auth, payload: requestMsgPayloadData)
    }
    
    
    func sendScanNetworks() {
        let requestMsgPayload = Particle_Ctrl_Mesh_ScanNetworksRequest()
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_ScanNetworksRequest message")
            return
        }
        self.sendRequestMessage(type: .ScanNetworks, payload: requestMsgPayloadData)
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
    
    func sendPrepareJoiner(networkInfo: Particle_Ctrl_Mesh_NetworkInfo) {
        var requestMsgPayload = Particle_Ctrl_Mesh_PrepareJoinerRequest()
        requestMsgPayload.network = networkInfo
        
        guard let requestMsgPayloadData = try? requestMsgPayload.serializedData() else {
            print("Could not serialize protobuf Particle_Ctrl_Mesh_PrepareJoinerRequest message")
            return
        }
        self.sendRequestMessage(type: .PrepareJoiner, payload: requestMsgPayloadData)
    }
    
    func sendAddJoiner(eui64: String, password: String) {
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

        rxBuffer.append(contentsOf: data)
        self.requestTimer?.invalidate()

        //if received data is less than handshake data header length
        if (rxBuffer.count < 2) {
            return
        }

        //read the length of the message
        var length: Int16 = rxBuffer.withUnsafeBytes { (pointer: UnsafePointer<Int16>) -> Int16 in
            return Int16(pointer[0])
        }

        //if we don't have enough data, reschedule timeout timer
        if (rxBuffer.count < Int(ReplyMessage.FRAME_EXTRA_BYTES + length)){
            self.requestTimer = Timer.scheduledTimer(timeInterval: self.timeoutValue,
                target: self,
                selector: #selector(self.requestTimeout),
                userInfo: nil,
                repeats: false)

            return
        }

        //todo: make sure there's enough data
        let rm = encryptionManager.decrypt(data)
        rxBuffer.removeAll()

        self.waitingForReply = false

        if let data = rm.data {
            if rm.result == .NONE {
                print("Received reply message id \(rm.id) --> Payload: \(data.hexString)")
                //                let replyMessageContents
                var decodedReply: Any?
                let replyRequestType = self.replyRequestTypeDict[rm.id]
                
                switch replyRequestType! {
                    
                case .GetDeviceId:
                    
                    do {
                        decodedReply = try Particle_Ctrl_GetDeviceIdReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply GetDeviceIdReply")
                        return
                    }
                    let deviceId = (decodedReply as! Particle_Ctrl_GetDeviceIdReply).id
                    self.delegate?.didReceiveDeviceIdReply(sender: self, deviceId: deviceId)
                    
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
                    
                    let networkInfo: MeshSetupNetworkInfo = (decodedReply as! Particle_Ctrl_Mesh_GetNetworkInfoReply).network
//                    self.networkInfo = MeshSetupNetworkInfo.init(name: rawNetworkInfo.name, extPanID: rawNetworkInfo.extPanID, panID: rawNetworkInfo.panID, channel: rawNetworkInfo.channel)
                    
                    // TODO: remove debug print
                    print("networkInfo:")
                    let msg = "Name: \(networkInfo.name)\nXPAN ID: \(networkInfo.extPanID)\nPAN ID: \(networkInfo.panID)\nChannel: \(networkInfo.channel)"
                    print(msg)

                    if replyRequestType! == .CreateNetwork {
                        self.delegate?.didReceiveCreateNetworkReply(sender: self, networkInfo: networkInfo)
                    } else {
                        // TODO: check if this is how an empty reply behaves? IT DOESNT - IT REPORTS -270 NOT_FOUND
                        if networkInfo.name.isEmpty {
                            self.delegate!.didReceiveGetNetworkInfoReply(sender: self, networkInfo: nil)
                        } else {
                            self.delegate!.didReceiveGetNetworkInfoReply(sender: self, networkInfo: networkInfo)
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
                    self.delegate?.didReceivePrepareJoinerReply(sender: self, eui64: prepareJoinerReply.eui64, password: prepareJoinerReply.password)
                    
                    
                case .ScanNetworks:
                    do {
                        decodedReply = try Particle_Ctrl_Mesh_ScanNetworksReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply ScanNetworksReply")
                        return
                    }
                    print("ScanNetworksReply")
                    print("\(String(describing: decodedReply))") // TODO: process repeated ???
                    
                    self.delegate?.didReceiveScanNetworksReply(sender: self, networks: (decodedReply as! Particle_Ctrl_Mesh_ScanNetworksReply).networks)
                    

                case .GetConnectionStatus:
                    
                    do {
                        decodedReply = try Particle_Ctrl_Cloud_GetConnectionStatusReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply GetConnectionStatusReply")
                        return
                    }
                    self.delegate?.didReceiveGetConnectionStatusReply(sender: self, connectionStatus: (decodedReply as! Particle_Ctrl_Cloud_GetConnectionStatusReply).status)

                case .GetSerialNumber:
                    do {
                        decodedReply = try Particle_Ctrl_GetSerialNumberReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply GetSerialNumberRequest")
                        return
                    }
                    let sn = (decodedReply as! Particle_Ctrl_GetSerialNumberReply).serial
                    self.delegate?.didReceiveGetSerialNumberReply(sender: self, serialNumber: sn)

                case .IsClaimed:
                    print("IsClaimed reply");
                    do {
                        decodedReply = try Particle_Ctrl_IsClaimedReply(serializedData: data)
                    } catch {
                        print("Could not deserialize reply IsClaimedReply")
                        return
                    }
                    let isClaimed = (decodedReply as! Particle_Ctrl_IsClaimedReply).claimed
                    self.delegate?.didReceiveIsClaimedReply(sender: self, isClaimed: isClaimed)

                case .AddJoiner:
                    self.delegate?.didReceiveAddJoinerReply(sender: self)
                    
                case .Auth:
                    self.delegate?.didReceiveAuthReply(sender: self)

                case .JoinNetwork:
                    self.delegate?.didReceiveJoinNetworkReply(sender: self)

                case .LeaveNetwork:
                    self.delegate?.didReceiveLeaveNetworkReply(sender: self)
                    
                case .StartCommissioner:
                    self.delegate?.didReceiveStartCommissionerReply(sender: self)
                    
                case .StopCommissioner:
                    self.delegate?.didReceiveStopCommissionerReply(sender: self)

                case .SetClaimCode:
                    self.delegate?.didReceiveSetClaimCodeReply(sender: self)
                    
                case .GetSecurityKey:
                    fallthrough // ???
                case .SetSecurityKey:
                    // TODO: what are those for ???
                    print("what are those for?!")
                    
                case .RemoveJoiner:
                    self.delegate?.didReceiveRemoveJoinerReply(sender: self)
                    
                case .Test:
                    // TODO: remove for production
                    self.delegate?.didReceiveTestReply(sender: self)
                }
                
                
            } else {
                // TODO: decode reply error type into english via raw values 
                print("Reply Error: \(rm.result)")
                self.delegate?.didReceiveErrorReply(sender: self, error: rm.result)
                
            }
        }
    }
}
