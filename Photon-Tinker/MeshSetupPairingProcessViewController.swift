//
//  MeshSetupPairingProcessViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/21/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupPairingProcessViewController: MeshSetupViewController, MeshSetupFlowManagerDelegate {
  
    var deviceType : ParticleDeviceType?
    var dataMatrix : String?
    var scannedNetworks   : [String]?
    
    
    func flowError(error: String, severity: MeshSetupErrorSeverity, action: flowErrorAction) {
        print("flowError: \(error)")
        
        var messageType : RMessageType
        switch severity {
            case .Info: messageType = .normal
            case .Warning: messageType = .warning
            case .Error: messageType = .error
            case .Fatal: messageType = .error
        }
        RMessage.showNotification(withTitle: "Pairing", subtitle: error, type: messageType, customTypeName: nil, callback: nil)
    }
    
    
    func scannedNetworks(networks: [String]?) {
        
        self.scannedNetworks = networks
        performSegue(withIdentifier: "selectNetwork", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MeshSetupSelectNetworkViewController else {
            return
        }
        
        vc.networks = self.scannedNetworks
        vc.flowManager = self.flowManager
    }
    
    func networkMatch() {
        // ..
    }

    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // we don't need a back button while trying to pair/start setup
        self.navigationItem.hidesBackButton = true
        ParticleSpinner.show(self.view)
//        self.connectRetries = 0
        
        self.flowManager = MeshSetupFlowManager(delegate : self)
        print("flowManager initialized")
        
    }
    
    func flowManagerReady() {
        print("Starting flow with a \(self.deviceType!.description) as Joiner ")
        let ok = self.flowManager!.startFlow(with: self.deviceType!, as: .Joiner, dataMatrix: self.dataMatrix!)
        
        if !ok {
            print("ERROR: Cannot start flow!")
            self.abort()
        }
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.flowManager?.abortFlow()
        self.abort()
    }
    
    func abort() {
//        MeshSetupParameters.shared.bluetoothManager = nil
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
}
