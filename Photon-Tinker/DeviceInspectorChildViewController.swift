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

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: DeviceInspectorChildViewControllerDelegate?
    weak var device : ParticleDevice!

    var refreshControl: UIRefreshControl!

    func setup(device: ParticleDevice) {
        self.device = device
    }

    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysHide;
    }

    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().previousNextDisplayMode = .default
    }


    func showTutorial() {
        assert(false, "This method must be overriden by the DeviceInspectorChildViewController subclass")
    }

    func update() {

    }

    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: .valueChanged)
        self.refreshControl = refreshControl

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    @objc func refreshData(sender: UIRefreshControl) {
        self.delegate?.childViewDidRequestDataRefresh(self)
    }
}
