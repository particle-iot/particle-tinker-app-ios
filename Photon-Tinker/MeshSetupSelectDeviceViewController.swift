//
//  MeshSetupSelectDeviceViewController.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/18/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import Foundation
import UIKit

class MeshSetupSelectDeviceViewController: MeshSetupViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var deviceTypeTableView: UITableView!

    private let deviceTypes = [ "Xenon", "Argon", "Boron" ]
    private let deviceDescriptionTypes = ["Mesh only", "Mesh and Wi-Fi gateway", "Mesh and Cellular gateway" ]

    private var callback: ((ParticleDeviceType) -> ())?

    func setup(didSelectDevice: @escaping (ParticleDeviceType) -> ()) {
        self.callback = didSelectDevice
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        deviceTypeTableView.delegate = self
        deviceTypeTableView.dataSource = self
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return deviceTypes.count;
        } else {
            return 0;
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceType")

        if let cell = cell {
            cell.textLabel?.text = deviceTypes[indexPath.row]
            cell.detailTextLabel?.textColor = UIColor.darkGray
            cell.detailTextLabel?.text = deviceDescriptionTypes[indexPath.row]
            if (indexPath.row != 0) {
                cell.textLabel?.textColor = UIColor.lightGray
                cell.detailTextLabel?.textColor = UIColor.lightGray
            }

            cell.imageView?.image = UIImage.init(named: "imgDevice" + deviceTypes[indexPath.row])

            let itemSize = CGSize(width: 30, height: 64);
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
            let imageRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height);
            cell.imageView?.image!.draw(in: imageRect)
            cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext();
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let callback = callback {
            switch indexPath.row {
                case 0:
                    callback(ParticleDeviceType.xenon)
                case 1:
                    callback(ParticleDeviceType.argon)
                case 2:
                    callback(ParticleDeviceType.boron)
                default:
                    callback(ParticleDeviceType.xenon)
            }
        }
    }
}

