//
// Created by Raimundas Sakalauskas on 06/01/2020.
// Copyright (c) 2020 Particle. All rights reserved.
//

import Foundation

enum DataMatrixError: Error, CustomStringConvertible {
    case InvalidMatrix
    case UnableToRecoverMobileSecret
    case NetworkError

    public var description: String {
        switch self {
            case .InvalidMatrix: return "This is not valid device sticker. Please scan 3rd generation device sticker."
            case .UnableToRecoverMobileSecret: return  "There is a problem with the sticker on your device. Please contact support for a solution."
            case .NetworkError: return  "There was a network error communicating to Particle Device Cloud."
        }
    }
}

internal class Gen3SetupDataMatrix {
    fileprivate(set) public var serialNumber: String
    fileprivate(set) public var mobileSecret: String
    fileprivate(set) public var type: ParticleDeviceType?

    var matrixString: String {
        return "\(serialNumber) \(mobileSecret)"
    }

    init?(device: ParticleDevice) {
        guard let sn = device.serialNumber, let ms = device.mobileSecret else {
            return nil
        }

        serialNumber = sn
        mobileSecret = ms
        type = device.type
    }

    fileprivate init?(dataMatrixString: String, deviceType: ParticleDeviceType? = nil) {
        let regex = try! NSRegularExpression(pattern: "([a-zA-Z0-9]{15})[ ]{1}([a-zA-Z0-9]{12,15})")
        let nsString = dataMatrixString as NSString
        let results = regex.matches(in: dataMatrixString, range: NSRange(location: 0, length: nsString.length))

        if (results.count > 0) {
            let arr = dataMatrixString.split(separator: " ")
            serialNumber = String(arr[0])//"12345678abcdefg"
            mobileSecret = String(arr[1])//"ABCDEFGHIJKLMN"
        } else {
            return nil
        }
    }

    func isMobileSecretValid() -> Bool {
        return mobileSecret.count == 15
    }

    static func getMatrix(fromString matrixString: String, onComplete:@escaping (Gen3SetupDataMatrix?, DataMatrixError?) -> ()) {
        if let matrix = Gen3SetupDataMatrix(dataMatrixString: matrixString) {
            getPlatformId(matrix: matrix, onComplete: onComplete)
        } else {
            onComplete(nil, .InvalidMatrix)
        }
    }

    fileprivate static func getPlatformId(matrix: Gen3SetupDataMatrix, onComplete: @escaping (Gen3SetupDataMatrix?, DataMatrixError?) -> ()) {
        ParticleCloud.sharedInstance().getPlatformId(matrix.serialNumber) { platformId, error in
            if let platformId = platformId, let type = ParticleDeviceType(rawValue: Int(platformId)) {
                matrix.type = type
                if (matrix.isMobileSecretValid()) {
                    onComplete(matrix, nil)
                } else {
                    recoverMobileSecret(matrix: matrix, onComplete: onComplete)
                }
            } else if let nserror = error as? NSError, nserror.code == 404 {
                onComplete(nil, .InvalidMatrix)
            } else {
                onComplete(matrix, .NetworkError)
            }
        }
    }

    fileprivate static func recoverMobileSecret(matrix: Gen3SetupDataMatrix, onComplete: @escaping (Gen3SetupDataMatrix?, DataMatrixError?) -> ()) {
        ParticleCloud.sharedInstance().getRecoveryMobileSecret(matrix.serialNumber, mobileSecret: matrix.mobileSecret) { mobileSecret, error in
            if let mobileSecret = mobileSecret {
                matrix.mobileSecret = mobileSecret
                onComplete(matrix, nil)
            } else if let nserror = error as? NSError, nserror.code == 200 {
                onComplete(matrix, .UnableToRecoverMobileSecret)
            } else {
                onComplete(matrix, .NetworkError)
            }
        }
    }
}
