//
//  SettingsTableViewController.swift
//  Particle
//
//  Created by Ido on 5/29/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var helpTableView: UITableView!

    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: { () -> Void in

        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section==2) ? 1 : 3;
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 { //1?
            let infoDictionary = Bundle.main.infoDictionary as [String : AnyObject]?
            let version = infoDictionary!["CFBundleShortVersionString"] as! String
            let build = infoDictionary!["CFBundleVersion"] as! String
            let label = UILabel()
            label.text = NSLocalizedString("Particle Tinker V\(version) (\(build))", comment: "")
            label.textColor = UIColor.gray
            label.font = UIFont(name: "Gotham-Book", size: 13)!
            label.textAlignment = .center
            return label.text
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : HelpTableViewCell = self.helpTableView.dequeueReusableCell(withIdentifier: "helpCell") as! HelpTableViewCell
        
        switch (indexPath as NSIndexPath).section
        {
            case 0: // docs
                switch (indexPath as NSIndexPath).row
                {
                    case 0:
                        cell.helpItemLabel.text = "Particle App"
                    case 1:
                        cell.helpItemLabel.text = "Setting Up Your Device"
                    default:
                        cell.helpItemLabel.text = "Create Your Own App"
                }
            case 1: // support
                switch (indexPath as NSIndexPath).row
                {
                    case 0:
                        cell.helpItemLabel.text = "Particle Community"
                    case 1:
                        cell.helpItemLabel.text = "Troubleshooting"
                    default:
                        cell.helpItemLabel.text = "Contact Us"
                }

            case 2:
                cell.helpItemLabel.text = "Reset App Tutorials";

            default:
                print()
        }
        
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0 :
                return "Documentation"
            case 1 :
                return "Support"
            default :
                return "Settings"
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.helpTableView.deselectRow(at: indexPath, animated: true)
        var url : URL?
        var openWebView : Bool = true
        
        switch (indexPath as NSIndexPath).section
        {
        case 0: // docs
            SEGAnalytics.shared().track("Tinker_GoToDocumentation")

            switch (indexPath as NSIndexPath).row
            {
                case 0:
                    url = URL(string: "https://docs.particle.io/guide/getting-started/tinker/")
                case 1:
                    url = URL(string: "https://docs.particle.io/guide/getting-started/start/photon/#connect-your-photon")
                default:
                    url = URL(string: "https://docs.particle.io/guide/how-to-build-a-product/mobile-app/")
            }
        
            
        case 1: // Support
            SEGAnalytics.shared().track("Tinker_GoToSupport")

            switch (indexPath as NSIndexPath).row
            {
                case 0:
                    url = URL(string: "https://community.particle.io/")

                case 1:
                    url = URL(string: "https://docs.particle.io/support/troubleshooting/common-issues/photon/")

                default:
                    url = URL(string: "https://docs.particle.io/support/support-and-fulfillment/menu-base/")
                
            }
            
        default:
            SEGAnalytics.shared().track("Tinker_TutorialsReset")
            ParticleUtils.resetTutorialWasDisplayed()
            DispatchQueue.main.async {
                RMessage.showNotification(withTitle: "Tutorials reset", subtitle: "App tutorials will now be displayed once again", type: .success, customTypeName: nil, callback: nil)
            }

            openWebView = false
            
            
        }
        
        if openWebView {
            let webVC : WebViewController = self.storyboard!.instantiateViewController(withIdentifier: "webview") as! WebViewController
            webVC.link = url
            let cell : HelpTableViewCell = tableView.cellForRow(at: indexPath) as! HelpTableViewCell
            
            
            webVC.linkTitle = cell.helpItemLabel.text
            self.present(webVC, animated: true, completion: nil)
        }
    }

}
