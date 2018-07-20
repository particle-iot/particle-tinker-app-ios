//
//  MeshSetupSelectNetworkViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/19/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupSelectNetworkViewController: MeshSetupViewController, UITableViewDelegate, UITableViewDataSource {
    var networks : [String]?
    var selectedNetwork : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
    }
    
    @IBOutlet weak var networksTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "networkCell")
        
        cell?.textLabel?.text = self.networks![indexPath.row]
        cell?.detailTextLabel?.textColor = UIColor.darkGray
        cell?.detailTextLabel?.text = "? devices on network"
      
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedNetwork = networks![indexPath.row]
        self.flowManager?.selectedNetwork = self.selectedNetwork
        performSegue(withIdentifier: "addDevice", sender: self)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MeshSetupAddToNetworkViewController else {
            return
        }
        
        vc.flowManager = self.flowManager
    }

    
}
