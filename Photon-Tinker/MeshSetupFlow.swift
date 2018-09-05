//
//  MeshSetupFlow.swift
//  Particle
//
//  Created by Ido Kleinman on 7/10/18.
//  Maintained by Raimundas Sakalauskas
//  Copyright © 2018 Particle. All rights reserved.
//

//
//protocol MeshSetupUserInteractionProtocol {
////    func userDidSelectNetwork(networkName: String)
////    func userDidTypeNetworkPassword(password: String)
//}

class MeshSetupBaseFlow: NSObject { //, MeshSetupTransceiverDelegate {

//    func didTimeoutSendingMessage(sender: MeshSetupProtocolTransceiver) {
//
//    }

//
//    var flowManager: MeshSetupFlowManager?
//    var delegate: MeshSetupFlowManagerDelegate?
//    var networkName: String? {
//        didSet {
//            // TODO: remove debug
//            print("user selected network \(networkName!)")
//        }
//    }
//    var networkPassword: String? {
//        didSet {
//            self.userDidSetNetworkPassword(networkPassword: networkPassword!)
//        }
//    }
//    var deviceName: String? {
//        didSet {
//            self.userDidSetDeviceName(deviceName: deviceName!)
//        }
//    }
//
//
//    required init(flowManager: MeshSetupFlowManager) {
//        self.flowManager = flowManager
//        self.delegate = flowManager.delegate
//    }
//
//    // must override in subclass
//    func start() {
//         fatalError("Must Override in subclass")
//    }
//
//    func startCommissioner() {
//        fatalError("Must Override in subclass")
//    }
//
//
//    // MARK: MeshSetupProtocolTransceiverDelegate functions - must be overriden in subclass
//
//
//    func userDidSetNetworkPassword(networkPassword: String) {
//
//    }
//
//    func userDidSetDeviceName(deviceName: String) {
//       fatalError("Must Override in subclass")
//    }
//
//    func didReceiveErrorReply(error: ControlReplyErrorType) {
//
//    }
//
//
//    func commissionDeviceToNetwork() {
//        print("commissionDeviceToNetwork")
//    }
//
//    func didTimeout(sender: MeshSetupProtocolTransceiver, lastCommand: ControlRequestMessageType?) {
//        print("Message time out on \(sender.role) - last command sent: \(lastCommand)")
//        self.flowManager?.delegate?.flowError(error: "Timeout receiving response from \(sender.role) device", severity: .Error, action: .Pop)
//    }
//
//
}
