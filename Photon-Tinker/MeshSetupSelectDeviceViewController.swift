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
        super.viewDidLoad()
        
        deviceTypeTableView.delegate = self
        deviceTypeTableView.dataSource = self
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(MeshSetupSelectDeviceViewController.cancelButtonTapped))
        self.navigationItem.rightBarButtonItem = cancelButton
    }
    
    // TODO: Streamline this
    let deviceTypes = [ "Xenon", "Argon", "Boron" ]
    var deviceDescriptionTypes = [ "Mesh only", "Mesh and Wi-Fi gateway", "Mesh and Cellular gateway" ]

    
    @objc func cancelButtonTapped() {
//        self.dismiss(animated: true)
        self.navigationController!.dismiss(animated: true)
    }
    
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
        cell?.detailTextLabel?.textColor = UIColor.darkGray
        cell?.detailTextLabel?.text = deviceDescriptionTypes[indexPath.row]
        if (indexPath.row != 0) {
            cell?.textLabel?.textColor = UIColor.lightGray
            cell?.detailTextLabel?.textColor = UIColor.lightGray
        }
        
        cell?.imageView?.image = UIImage.init(named: "imgDevice"+deviceTypes[indexPath.row])
        
        let itemSize = CGSize(width: 30, height: 64);
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height);
        cell?.imageView?.image!.draw(in: imageRect)
        cell?.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
       
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == deviceTypes.index(of: "Xenon") {
            self.deviceType = .xenon
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "getReady", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let vc = segue.destination as? MeshSetupGetReadyViewController else {
                return
            }
        
            vc.deviceType = self.deviceType
    }
    
}

