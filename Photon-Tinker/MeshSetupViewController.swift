//
//  MeshSetupViewController.swift
//  
//
//  Created by Ido Kleinman on 6/19/18.
//

import UIKit

class MeshSetupViewController: UIViewController, MeshSetupFlowManagerDelegate {
    
    var flowManager : MeshSetupFlowManager?
    var deviceType : ParticleDeviceType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // replace the {{placeholders}} with real strings
        if let d = self.deviceType { // before FlowManager instasiated
            replaceMeshSetupStringTemplates(view: self.view, deviceType: d, networkName: nil, deviceName: nil)
        } else if let fm = self.flowManager { // after
            replaceMeshSetupStringTemplates(view: self.view, deviceType: fm.joinerDeviceType, networkName: fm.selectedNetwork, deviceName: fm.deviceName)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let fm = self.flowManager {
            fm.delegate = self
        }
    }

    
    func flowError(error: String, severity: MeshSetupErrorSeverity, action: flowErrorAction) {
        print("flowError: \(error)")
        
        var messageType : RMessageType
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
                RMessage.showNotification(withTitle: "Pairing", subtitle: error, type: messageType, customTypeName: nil, callback: nil)
            }
        }
    }
    
    // MARK: MeshSetupFlowManagerDelegate functions - some should be overriden in UI subclasses
    func flowManagerReady() {
        // override in subclass if needed
    }
    
    func scannedNetworks(networks: [String]?) {
        // override in subclass if needed
    }
    
    func networkMatch() {
        // override in subclass if needed
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 

}
