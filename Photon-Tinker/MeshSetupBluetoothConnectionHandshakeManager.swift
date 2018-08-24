//
// Created by Raimundas Sakalauskas on 21/08/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation
import mbedTLSWrapper

protocol MeshSetupBluetoothConnectionHandshakeManagerDelegate {
    func handshakeDidFail(sender: MeshSetupBluetoothConnectionHandshakeManager, error: HanshakeManagerError)
    func handshakeDidSucceed(sender: MeshSetupBluetoothConnectionHandshakeManager, derivedSecret: Data)
}

enum HanshakeManagerError: Error {
    case FailedToInitializeEcJPake
    case FailedToCreateRoundOne
    case FailedToCreateRoundTwo
    case FailedToReadRoundOne
    case FailedToReadRoundTwo
    case FailedToDeriveSecret
    case FailedToCreateConfirmation
    case FailedToVerifySecret
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

    func startHandshake() {
        NSLog("Handshake: start handshake")
        if let temp = ECJPakeWrapper(role: ECJPakeWrapperRoleClient, lowEntropySharedPassword: self.mobileSecret!) {
            ecJPakeWrapper = temp

            handshakeState = .initialized
            sendRoundOne()
        } else {
            handshakeState = .failed
            self.delegate?.handshakeDidFail(sender: self, error: .FailedToInitializeEcJPake)
        }
    }



    private func sendRoundOne() {
        NSLog("Handshake: sendRoundOne")
        let data = ecJPakeWrapper.writeRoundOne()

        if let data = data {
            handshakeData.append(data)
            sendHandshakeData(data)
            handshakeState = .roundOneSent
            //server will respond with data for roundOneRead
        } else {
            handshakeState = .failed
            self.delegate?.handshakeDidFail(sender: self, error: .FailedToCreateRoundOne)
        }
    }

    private func readRoundOne(_ data: Data) {
        NSLog("Handshake: readRoundOne")
        let result = ecJPakeWrapper.readRoundOne(data)

        if (result == 0) {
            handshakeData.append(data)
            handshakeState = .roundOneRead
            //server will respond with data for roundTwoRead
        } else {
            handshakeState = .failed
            self.delegate?.handshakeDidFail(sender: self, error: .FailedToReadRoundOne)
        }
    }

    private func readRoundTwo(_ data: Data) {
        NSLog("Handshake: readRoundTwo")
        let result = ecJPakeWrapper.readRoundTwo(data)

        if (result == 0) {
            handshakeData.append(data)
            handshakeState = .roundTwoRead
            sendRoundTwo()
        } else {
            handshakeState = .failed
            self.delegate?.handshakeDidFail(sender: self, error: .FailedToReadRoundTwo)
        }
    }


    private func sendRoundTwo() {
        NSLog("Handshake: sendRoundTwo")
        let data = ecJPakeWrapper.writeRoundTwo()

        if let data = data {
            handshakeData.append(data)
            sendHandshakeData(data)
            handshakeState = .roundTwoSent
            deriveSecret()
        } else {
            handshakeState = .failed
            self.delegate?.handshakeDidFail(sender: self, error: .FailedToCreateRoundTwo)
        }
    }


    private func deriveSecret() {
        derivedSecret = ecJPakeWrapper.deriveSharedSecret()
        if let secret = derivedSecret {
            sendConfirmation()
        } else {
            handshakeState = .failed
            self.delegate?.handshakeDidFail(sender: self, error: .FailedToDeriveSecret)
        }
    }

    private func sendConfirmation() {
        NSLog("Handshake: sendConfirmation")
        
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
            handshakeState = .failed
            self.delegate?.handshakeDidFail(sender: self, error: .FailedToCreateConfirmation)
        }
    }

    private func readConfirmation(_ data: Data) {
        NSLog("Handshake: readConfirmation")
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
            NSLog("Handshake: completed")
            handshakeState = .completed
            delegate?.handshakeDidSucceed(sender: self, derivedSecret: derivedSecret!)
        } else {
            handshakeState = .failed
            self.delegate?.handshakeDidFail(sender: self, error: .FailedToVerifySecret)
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
                NSLog("Handshake: data received")
                break
            }
        }
    }


    private func getConfirmKey() -> Data? {
        let hash = Sha256Wrapper()
        if hash == nil {
            handshakeState = .failed
            delegate?.handshakeDidFail(sender: self, error: .FailedToCreateConfirmation)
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
            handshakeState = .failed
            delegate?.handshakeDidFail(sender: self, error: .FailedToCreateConfirmation)
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
