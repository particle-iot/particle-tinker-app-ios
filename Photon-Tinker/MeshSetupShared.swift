//
//  ParticleCommon.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/18/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import Foundation
import UIKit

/*
enum ParticleDeviceType : String {
    case Xenon
    case Argon
    case Boron
    
    case ESP32
    case Photon
    case Electron
    case P0
    case P1
    case Core
    case E0
    
    func name() -> String {
        return self.rawValue
    }
    
    
}

class MeshSetupParameters {
    
    // TODO: remove hard coding
    static let shared = MeshSetupParameters()
    
        // Initialization
    var deviceType : ParticleDeviceType?
    var networkName : String?
    var deviceName : String?
    var claimCode : String?
    
//    var bluetoothManager : MeshSetupBluetoothManager?
    var flowManager : MeshSetupFlowManager?
    
    private init() {
        
    }
    
}
 */

// TODO: should be globally reference not just for mesh
extension ParticleDeviceType : CustomStringConvertible {
    public var description: String {
        switch self {
            case .unknown : return "Unknown"
            case .core : return "Core"
            case .photon : return "Photon"
            case .P1 : return "P1"
            case .electron : return "Electron"
            case .raspberryPi : return "RaspberryPi"
            case .redBearDuo : return "RedBearDuo"
            case .bluz : return "Bluz"
            case .digistumpOak : return "DigistumpOak"
            case .ESP32 : return "ESP32"
            case .argon : return "Argon"
            case .boron : return "Boron"
            case .xenon : return "Xenon"
        }
    }
}


func replaceMeshSetupStringTemplates(view: UIView) {
    
    let subviews = view.subviews
    
    for subview in subviews {
        if subview is UILabel {
            let label = subview as! UILabel
            var newLabelString = label.text
            // TODO: retrieve info diffrently
//            if let t = MeshSetupParameters.shared.deviceType {
//                newLabelString = label.text?.replacingOccurrences(of: "{{device}}", with: t.description)
//            }
//
//            if let n = MeshSetupParameters.shared.networkName {
//                newLabelString = newLabelString!.replacingOccurrences(of: "{{network}}", with: n)
//            }
//
//            if let d = MeshSetupParameters.shared.deviceName {
//                newLabelString = newLabelString!.replacingOccurrences(of: "{{deviceName}}", with: d)
//            }

            label.text = newLabelString
        }
        
    }
}


