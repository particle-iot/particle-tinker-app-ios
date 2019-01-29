//
//  DeviceInspectorChildViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/29/16.
//  Copyright © 2016 Particle. All rights reserved.
//



class DeviceInspectorChildViewController: UIViewController {

    var device : ParticleDevice? {
        didSet {
            ParticleLogger.logInfo(NSStringFromClass(type(of: self)), format: "Device set: %@ for instance: %@", withParameters: getVaList(["\(device)", String(describing: self)]))
        }
    }
    
    func showTutorial() {
        assert(false, "This method must be overriden by the DeviceInspectorChildViewController subclass")
    }
    
}
