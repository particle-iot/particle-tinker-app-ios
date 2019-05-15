//
//  DeviceInspectorChildViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/29/16.
//  Copyright © 2016 Particle. All rights reserved.
//

protocol DeviceInspectorChildViewControllerDelegate: class {
    func childViewDidRequestDataRefresh(_ childView: DeviceInspectorChildViewController)
}

class DeviceInspectorChildViewController: UIViewController {

    weak var delegate: DeviceInspectorChildViewControllerDelegate?
    weak var device : ParticleDevice!
    
    func showTutorial() {
        assert(false, "This method must be overriden by the DeviceInspectorChildViewController subclass")
    }

    func update() {

    }
}
