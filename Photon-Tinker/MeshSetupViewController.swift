//
//  MeshSetupViewController.swift
//  
//
//  Created by Ido Kleinman on 6/19/18.
//

import UIKit

class MeshSetupViewController: UIViewController, MeshSetupFlowManagerDelegate {

    
    
    var flowManager: MeshSetupFlowManager?
    var deviceType: ParticleDeviceType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // replace the {{placeholders}} with real strings
        if let d = self.deviceType { // before FlowManager instasiated
            replaceMeshSetupStringTemplates(view: self.view, deviceType: d, networkName: nil, deviceName: nil)
        } else if let fm = self.flowManager { // after
            replaceMeshSetupStringTemplates(view: self.view, deviceType: fm.joinerDeviceType, networkName: fm.networkName, deviceName: fm.deviceName)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let fm = self.flowManager {
            fm.delegate = self
        }
    }

    
    func flowError(error: String, severity: MeshSetupErrorSeverity, action: MeshSetupErrorAction) {
        print("flowError: \(error)")
        
        var messageType: RMessageType
        switch severity {
            case .Info: messageType = .normal
            case .Warning: messageType = .warning
            case .Error: messageType = .error
            case .Fatal: messageType = .error
        }
       
        // TODO: work out the actions
        switch action {
            case .Fail:
                fallthrough
            case .Pop:
                fallthrough
            case .Dialog:
                DispatchQueue.main.async {
                    RMessage.showNotification(withTitle: "Mesh Device Setup", subtitle: error, type: messageType, customTypeName: nil, callback: nil)
                }
            }
    }
    
    // MARK: MeshSetupFlowManagerDelegate functions - some should be overriden in UI subclasses
    func flowManagerReady() {
        // override in subclass if needed
        print("flowManagerReady")
    }
    
    func scannedNetworks(networks: [String]?) {
        // override in subclass if needed
        print("scannedNetworks")
    }
    
    func networkMatch() {
        // override in subclass if needed
        print("networkMatch")
    }
    
    func authSuccess() {
        // override in subclass if needed
        print("authSuccess")
    }
    
    func joinerPrepared() {
        // override in subclass if needed
        print("joinerPrepared")
    }
    
    func joinedNetwork() {
        // override in subclass if needed
        print("joinedNetwork")
    }
    
    func deviceOnlineClaimed() {
        // override in subclass if needed
        print("deviceOnlineClaimed")
    }
    
    func deviceNamed() {
        // override in subclass if needed
        print("deviceNamed")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("motherclass - prepare, setting flowmanager")
        guard let vc = segue.destination as? MeshSetupViewController else {
            print("guard failed")
            return
        }
        
        if let fm = self.flowManager {
            vc.flowManager = fm
        }
    }
    

 

}
