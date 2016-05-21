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


class HelpTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

//    @objc var device : SparkDevice? = nil
//    var delegate : SettingsTableViewControllerDelegate? = nil
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
    
    /*
    func selectRowsToEnableImageTinting()
    {
        // ugly hack to make the color tint for the table images work
        var ip = NSIndexPath()
        for (var j=0;j<self.tableView.numberOfSections();j++)
        {
            for (var i=0;i<self.tableView.numberOfRowsInSection(j);i++)
            {
                ip = NSIndexPath(forRow: i, inSection: j)
                self.tableView.selectRowAtIndexPath(ip, animated: false, scrollPosition: .None)
//                self.tableView.deselectRowAtIndexPath(ip, animated: false)
            }
        }
        self.tableView.deselectRowAtIndexPath(ip, animated: false)
    }
*/
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
//    @IBOutlet weak var deviceIDlabel: UILabel!

    // add a navigation bar to the popover like this:
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        return navController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TSMessage.setDefaultViewController(self.navigationController)
        
        
//        self.navigationController?.navigationBar.topItem?.title = "Tinker settings"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Gotham-Book", size: 17)!]//,  NSForegroundColorAttributeName: UIColor.blackColor()]

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
//        self.deviceIDlabel.text = self.device!.id
        
//        [[Mixpanel sharedInstance] track:@"Tinker: error" properties:@{@"type":@"communicate with device"}];
        Mixpanel.sharedInstance().timeEvent("Tinker: Settings screen activity")
    }
    
    override func viewWillDisappear(animated: Bool) {
        Mixpanel.sharedInstance().track("Tinker: Settings screen activity")
    }

    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            let infoDictionary = NSBundle.mainBundle().infoDictionary as [String : AnyObject]?
            let version = infoDictionary!["CFBundleShortVersionString"] as! String
            let build = infoDictionary!["CFBundleVersion"] as! String
            let label = UILabel()
            label.text = NSLocalizedString("Particle Tinker V\(version) (\(build))", comment: "")
            label.textColor = UIColor.grayColor()
            label.font = UIFont(name: "Gotham-Book", size: 13)!
            label.textAlignment = .Center
            return label
        } else {
            return nil
        }
    }

    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section
        {
        case 0: // docs
            Mixpanel.sharedInstance().track("Tinker: Go to documentation")

            var url : NSURL?
            switch indexPath.row
            {
            case 0:
//                print("documentation: app")
                url = NSURL(string: "https://docs.particle.io/guide/getting-started/tinker/photon/")
            case 1:
//                print("documentation: setup your device")
                url = NSURL(string: "https://docs.particle.io/guide/getting-started/start/photon/#connect-your-photon")

            default:
//                print("documentation: make your mobile app")
                url = NSURL(string: "https://docs.particle.io/guide/how-to-build-a-product/mobile-app/")
                
                
            }
        
            
            let webVC : WebViewController = self.storyboard!.instantiateViewControllerWithIdentifier("webview") as! WebViewController
            webVC.link = url
            webVC.linkTitle = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
            
            self.presentViewController(webVC, animated: true, completion: nil)
            
        case 1: // Support
            Mixpanel.sharedInstance().track("Tinker: Go to support")

            var url : NSURL?
            switch indexPath.row
            {
                case 0:
//                    print("support: community")
                    url = NSURL(string: "https://community.particle.io/")
                
                default:
//                    print("support: email")
                    url = NSURL(string: "https://docs.particle.io/support/troubleshooting/common-issues/photon/")
                
            }
            
            let webVC : WebViewController = self.storyboard!.instantiateViewControllerWithIdentifier("webview") as! WebViewController
            webVC.link = url
            webVC.linkTitle = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text

            self.presentViewController(webVC, animated: true, completion: nil)
            
        default:
            print("default")

            
            
        }
    
    
    }

}
