//
// Created by Raimundas Sakalauskas on 21/08/2018.
// Maintained by Raimundas Sakalauskas
// Copyright (c) 2018 Particle. All rights reserved.
//

import Foundation
import mbedTLSWrapper

protocol MeshSetupBluetoothConnectionHandshakeManagerDelegate {
    func handshakeDidFail(sender: MeshSetupBluetoothConnectionHandshakeManager, error: HandshakeManagerError, severity: MeshSetupErrorSeverity)
    func handshakeDidSucceed(sender: MeshSetupBluetoothConnectionHandshakeManager, derivedSecret: Data)
}

enum HandshakeManagerError: Error, CustomStringConvertible {
    case FailedToInitializeEcJPake
    case FailedToCreateRoundOne
    case FailedToCreateRoundTwo
    case FailedToReadRoundOne
    case FailedToReadRoundTwo
    case FailedToDeriveSecret
    case FailedToCreateConfirmation
    case FailedToVerifySecret

    public var description: String {
        switch self {
            case .FailedToInitializeEcJPake : return "Unable to initialize EC-JPake"
            case .FailedToCreateRoundOne : return "Unable to create handshake local round 1 data"
            case .FailedToCreateRoundTwo : return "Unable to create handshake local round 2 data"
            case .FailedToReadRoundOne : return "Unable to read handshake remote round 1 data"
            case .FailedToReadRoundTwo : return "Unable to read handshake remote round 2 data"
            case .FailedToDeriveSecret : return "Unable to derive secret"
            case .FailedToCreateConfirmation : return "Unable to create confirmation data"
            case .FailedToVerifySecret : return "Unable to verify secret"
        }
    }
}

enum HandshakeState: Int {
    case notStarted = 0
    case initialized
    case roundOneSent
    case roundOneRead
    case roundTwoRead
    case roundTwoSent
    case confirmationSent
    case confirmationReceived
    case completed
    case failed
}

class MeshSetupBluetoothConnectionHandshakeManager {
    var delegate: MeshSetupBluetoothConnectionHandshakeManagerDelegate?
    var handshakeState: HandshakeState = .notStarted

    private var connection:MeshSetupBluetoothConnection
    private var mobileSecret:String?

    private var rxBuffer: Data
    private var handshakeData: [Data]

    private var ecJPakeWrapper: ECJPakeWrapper!
    private var derivedSecret: Data?

    required init(connection: MeshSetupBluetoothConnection, mobileSecret: String) {
        self.mobileSecret = mobileSecret
        self.connection = connection

        self.handshakeData = []
        self.rxBuffer = Data()
    }

    private func log(_ message: String) {
        if (MeshSetup.LogBluetoothHandshakeManager) {
            NSLog("HandshakeManager: \(message)")
        }
    }

    private func fail(withReason reason: HandshakeManagerError) {
        handshakeState = .failed
        self.delegate?.handshakeDidFail(sender: self, error: reason, severity: .Error)
        log("failed - \(reason)")
    }

    func startHandshake() {
        log("start handshake")
        if let temp = ECJPakeWrapper(role: ECJPakeWrapperRoleClient, lowEntropySharedPassword: self.mobileSecret!) {
            ecJPakeWrapper = temp

            handshakeState = .initialized
            sendRoundOne()
        } else {
            fail(withReason: .FailedToInitializeEcJPake)
        }
    }




    private func sendRoundOne() {
        log("sendRoundOne")
        let data = ecJPakeWrapper.writeRoundOne()

        if let data = data {
            handshakeData.append(data)
            sendHandshakeData(data)
            handshakeState = .roundOneSent
            //server will respond with data for roundOneRead
        } else {
            fail(withReason: .FailedToCreateRoundOne)
        }
    }

    private func readRoundOne(_ data: Data) {
        log("readRoundOne")
        let result = ecJPakeWrapper.readRoundOne(data)

        if (result == 0) {
            handshakeData.append(data)
            handshakeState = .roundOneRead
            //server will respond with data for roundTwoRead
        } else {
            fail(withReason: .FailedToReadRoundOne)
        }
    }

    private func readRoundTwo(_ data: Data) {
        log("readRoundTwo")
        let result = ecJPakeWrapper.readRoundTwo(data)

        if (result == 0) {
            handshakeData.append(data)
            handshakeState = .roundTwoRead
            sendRoundTwo()
        } else {
            fail(withReason: .FailedToReadRoundTwo)
        }
    }


    private func sendRoundTwo() {
        log("sendRoundTwo")
        let data = ecJPakeWrapper.writeRoundTwo()

        if let data = data {
            handshakeData.append(data)
            sendHandshakeData(data)
            handshakeState = .roundTwoSent
            deriveSecret()
        } else {
            fail(withReason: .FailedToCreateRoundTwo)
        }
    }


    private func deriveSecret() {
        derivedSecret = ecJPakeWrapper.deriveSharedSecret()
        if let secret = derivedSecret {
            sendConfirmation()
        } else {
            fail(withReason: .FailedToDeriveSecret)
        }
    }

    private func sendConfirmation() {
        log("sendConfirmation")
        
        var confirmKey: Data? = getConfirmKey()
        var computedHash: Data? = getComputedHash()
        var computedHmac: Data?

        if let computedHash = computedHash,
           let confirmKey = confirmKey,
           let hmac = HmacWrapper(seed: confirmKey) {
            var result = hmac.update(with: "KC_1_U")
            result = hmac.update(with: "client")
            result = hmac.update(with: "server")
            result = hmac.update(with: computedHash)
            computedHmac = hmac.finish()
        }

        if let data = computedHmac {
            handshakeData.append(data)
            sendHandshakeData(data)
            handshakeState = .confirmationSent
            //server will respond with data for confirmationReceived
        } else {
            fail(withReason: .FailedToCreateConfirmation)
        }
    }

    private func readConfirmation(_ data: Data) {
        log("readConfirmation")
        handshakeState = .confirmationSent

        var confirmKey: Data? = getConfirmKey()
        var computedHash: Data? = getComputedHash()
        var computedHmac: Data?

        if let computedHash = computedHash,
           let confirmKey = confirmKey,
           let hmac = HmacWrapper(seed: confirmKey) {
            var result = hmac.update(with: "KC_1_U")
            result = hmac.update(with: "server")
            result = hmac.update(with: "client")
            result = hmac.update(with: computedHash)
            computedHmac = hmac.finish()
        }

        if (data == computedHmac!) {
            log("completed")
            handshakeState = .completed
            delegate?.handshakeDidSucceed(sender: self, derivedSecret: derivedSecret!)
        } else {
            fail(withReason: .FailedToVerifySecret)
        }

    }


    //MARK: Helpers
    private func sendHandshakeData(_ data: Data) {
        var length = Int16(data.count)
        var header: Data = Data(bytes: &length, count: 2)
        header.append(data)

        connection.send(data: header)
    }

    func readBytes(_ data: Data) {
        rxBuffer.append(data)
        processReceivedData()
    }

    private func processReceivedData() {
        //if received data is less than handshake data header length
        if (rxBuffer.count < 2) {
            return
        }

        //read the length of the message
        var length: Int16 = rxBuffer.withUnsafeBytes { (pointer: UnsafePointer<Int16>) -> Int16 in
            return Int16(pointer[0])
        }

        //if we have the full message in rx buffer (header + message length) - process it
        if (rxBuffer.count >= length + 2) {
            //remove message header
            rxBuffer.removeSubrange(0..<2)

            //copy server message content
            var serverData = rxBuffer.subdata(in: 0..<Int(length))

            //remove server message content from the rxbuffer
            rxBuffer.removeSubrange(0..<Int(length))

            switch (handshakeState) {
            case .roundOneSent:
                readRoundOne(serverData)
                break
            case .roundOneRead:
                readRoundTwo(serverData)
                break
            case .confirmationSent:
                readConfirmation(serverData)
                break
            default:
                log("data received")
                break
            }
        }
    }


    private func getConfirmKey() -> Data? {
        let hash = Sha256Wrapper()
        if hash == nil {
            fail(withReason: .FailedToCreateConfirmation)
            return nil;
        } else {
            var result = hash!.update(with: derivedSecret!)
            result = hash!.update(with: "JPAKE_KC")
            return hash!.finish()!
        }
    }

    private func getComputedHash() -> Data? {
        let hash = Sha256Wrapper()
        if hash == nil {
            fail(withReason: .FailedToCreateConfirmation)
            return nil;
        } else {
            var data = Data()
            for i in 0 ..< handshakeData.count {
                data.append(handshakeData[i])
            }
            var result = hash!.update(with: data)

            return hash!.finish()
        }
    }

}
