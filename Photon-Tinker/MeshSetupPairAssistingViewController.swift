//
//  MeshSetupPairAssistingViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 7/25/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

class MeshSetupPairAssistingViewController: MeshSetupViewController {

//    var commissionerDataMatrix: String?
//
//    override func networkMatch() {
//        print("networkMatch - commissioner is on user selected mesh network")
//        // commissioner scanned is on the network user has chosen on previous screen - can advance
//        DispatchQueue.main.async {
//            self.performSegue(withIdentifier: "networkPassword", sender: self)
//        }
//    }
//
//    @IBOutlet weak var hintView: UIView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//    }
//
//    func didScanCode(code: String) {
//        if !code.isEmpty {
//            // TODO: initialize flow manager here
//            // Split code into deviceID and SN
//            self.commissionerDataMatrix = code
//            // TODO: specify wildcard for with: (commissioner can be any type of device)
//            let ok = self.flowManager!.startFlow(with: .xenon, as: .Commissioner, dataMatrix: code)
//
//            if !ok {
//                self.flowError(error: "Error starting flow with assisting device", severity: .Error, action: .Pop)
//            }
//
//        }
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        switch segue.identifier! {
//        case "networkPassword" :
//            guard let vc = segue.destination as? MeshSetupNetworkPasswordViewController  else {
//                return
//            }
//            vc.flowManager = self.flowManager
//
//        case "scanAssistingDevice" :
//            guard let vc = segue.destination as? MeshSetupScanCodeViewController  else {
//                return
//            }
//            vc.delegate = self
//
//        default:
//            print("Error segue")
//
//        }
//    }
}
