//
//  MeshSetupSelectNetworkViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupSelectNetworkViewController: MeshSetupViewController, UITableViewDelegate, UITableViewDataSource {
//    var networks: [String]?
//    var selectedNetwork: String?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.networksTableView.delegate = self
//        self.networksTableView.dataSource = self
//
//        // Do any additional setup after loading the view.
//    }
//
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    @IBAction func cancelButtonTapped(_ sender: Any) {
//    }
//
//    @IBOutlet weak var networksTableView: UITableView!
//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return networks!.count
    return 0
    }
//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "networkCell")
//
//        cell!.textLabel!.text = self.networks![indexPath.row]
//        cell!.detailTextLabel!.textColor = UIColor.darkGray
//        cell!.detailTextLabel!.text = "? devices on network"
//
//        cell?.imageView?.image = UIImage.init(named: "imgMeshBlue")
//
//        let itemSize = CGSize(width: 48, height: 48);
//        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
//        let imageRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height);
//        cell?.imageView?.image!.draw(in: imageRect)
//        cell?.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext();
        return cell!
    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.selectedNetwork = networks![indexPath.row]
//        self.flowManager!.networkName = self.selectedNetwork
//        DispatchQueue.main.async {
//            self.performSegue(withIdentifier: "addToNetwork", sender: self)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 64.0
//    }

   

    
}
