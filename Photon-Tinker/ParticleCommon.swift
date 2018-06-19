//
//  ParticleCommon.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/18/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import Foundation
import UIKit

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

func replaceMeshSetupStringTemplates(view: UIView, deviceType : ParticleDeviceType?, networkName : String?, deviceName : String?) {
    
    
    let subviews = view.subviews
    
    for subview in subviews {
        if subview is UILabel {
            let label = subview as! UILabel
            var newLabelString = label.text
            if let t = deviceType {
                newLabelString = label.text?.replacingOccurrences(of: "{{device}}", with: t.name())
            }
            
            if let n = networkName {
                newLabelString = newLabelString!.replacingOccurrences(of: "{{network}}", with: n)
            }
            
            if let d = deviceName {
                newLabelString = newLabelString!.replacingOccurrences(of: "{{deviceName}}", with: d)
            }

            label.text = newLabelString
        }
        
    }
}


