//
//  MeshSetupSelectDeviceViewController.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/18/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import Foundation
import UIKit

class MeshSetupSelectDeviceViewController : MeshSetupViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        deviceTypeTableView.delegate = self
        deviceTypeTableView.dataSource = self
    }
    
    var deviceTypes = [ "Xenon", "Argon", "Boron" ]
    @IBOutlet weak var deviceTypeTableView : UITableView!
    
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
        
        cell?.textLabel?.text = deviceTypes[indexPath.row]
        if (indexPath.row != 0) {
            cell?.textLabel?.textColor = UIColor.lightGray
        }
       
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == deviceTypes.index(of: "Xenon") {
                performSegue(withIdentifier: "getReady", sender: self)
        }
    }
    
}

