//
//  SettingsTableViewController.swift
//  Particle
//
//  Created by Ido on 5/29/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

//@objc protocol SettingsTableViewControllerDelegate
//{
//    func resetAllPinFunctions()
//}


class HelpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    @objc var device : SparkDevice? = nil
//    var delegate : SettingsTableViewControllerDelegate? = nil
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
    
   
    // add a navigation bar to the popover like this:
    /*
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        return navController
    }
    */
    @IBOutlet weak var helpTableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
   
        Mixpanel.sharedInstance().timeEvent("Tinker: Support/Documentation screen activity")
    }
    
  

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section==2) ? 1 : 3;
    }
    
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 { //1?
            let infoDictionary = NSBundle.mainBundle().infoDictionary as [String : AnyObject]?
            let version = infoDictionary!["CFBundleShortVersionString"] as! String
            let build = infoDictionary!["CFBundleVersion"] as! String
            let label = UILabel()
            label.text = NSLocalizedString("Particle Tinker V\(version) (\(build))", comment: "")
            label.textColor = UIColor.grayColor()
            label.font = UIFont(name: "Gotham-Book", size: 13)!
            label.textAlignment = .Center
            return label.text
        } else {
            return nil
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : HelpTableViewCell = self.helpTableView.dequeueReusableCellWithIdentifier("helpCell") as! HelpTableViewCell
        
        switch indexPath.section
        {
        case 0: // docs
            switch indexPath.row
            {
            case 0:
                cell.helpItemLabel.text = "Particle App"
            case 1:
                cell.helpItemLabel.text = "Setting Up Your Device"
            default:
                cell.helpItemLabel.text = "Create Your Own App"
                
                
            }
        case 1: // support
            switch indexPath.row
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
    
    @IBOutlet weak var closeButton: UIButton!
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0 :
                return "Documentation"
            case 1 :
                return "Support"
            default :
                return "Settings"
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.helpTableView.deselectRowAtIndexPath(indexPath, animated: true)
        var url : NSURL?
        var openWebView : Bool = true
        
        switch indexPath.section
        {
        case 0: // docs
            Mixpanel.sharedInstance().track("Tinker: Go to documentation")

            
            switch indexPath.row
            {
            case 0:
//                print("documentation: app")
                url = NSURL(string: "https://docs.particle.io/guide/getting-started/tinker/")
            case 1:
//                print("documentation: setup your device")
                url = NSURL(string: "https://docs.particle.io/guide/getting-started/start/photon/#connect-your-photon")

            default:
//                print("documentation: make your mobile app")
                url = NSURL(string: "https://docs.particle.io/guide/how-to-build-a-product/mobile-app/")
                
                
            }
        
            
        case 1: // Support
            Mixpanel.sharedInstance().track("Tinker: Go to support")

            switch indexPath.row
            {
                case 0:
                    url = NSURL(string: "https://community.particle.io/")

                case 1:
                    url = NSURL(string: "https://docs.particle.io/support/troubleshooting/common-issues/photon/")

                default:
                    url = NSURL(string: "https://docs.particle.io/support/support-and-fulfillment/menu-base/")
                
            }
            
        default:
            ParticleUtils.resetTutorialWasDisplayed()
            dispatch_async(dispatch_get_main_queue()) {
                TSMessage.showNotificationWithTitle("Tutorials", subtitle: "Tutorials were reset and will be displayed ", type: .Success)
            }

            openWebView = false
            
            
        }
        
        if openWebView {
            let webVC : WebViewController = self.storyboard!.instantiateViewControllerWithIdentifier("webview") as! WebViewController
            webVC.link = url
            let cell : HelpTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! HelpTableViewCell
            
            
            webVC.linkTitle = cell.helpItemLabel.text
            self.presentViewController(webVC, animated: true, completion: nil)
        }
        
        
    
    }

}
