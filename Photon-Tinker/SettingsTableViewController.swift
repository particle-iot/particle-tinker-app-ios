//
//  SettingsTableViewController.swift
//  Particle
//
//  Created by Ido on 5/29/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

@objc protocol SettingsTableViewControllerDelegate
{
    func resetAllPinFunctions()
}


class SettingsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    @objc var device : SparkDevice? = nil
    var delegate : SettingsTableViewControllerDelegate? = nil
    
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
    
    @IBOutlet weak var deviceIDlabel: UILabel!

    // add a navigation bar to the popover like this:
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        var navController = UINavigationController(rootViewController: controller.presentedViewController)
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
        self.deviceIDlabel.text = self.device!.id
    }

    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            let infoDictionary = NSBundle.mainBundle().infoDictionary as! [String : AnyObject]
            let version = infoDictionary["CFBundleShortVersionString"] as! String!
            let build = infoDictionary["CFBundleVersion"] as! String!
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
        case 0: // actions
            switch indexPath.row
            {
            case 0:
                println("copy device id")
                UIPasteboard.generalPasteboard().string = self.device?.id
                TSMessage.showNotificationInViewController(self.navigationController, title: "Device ID", subtitle: "Your device ID string has been copied to clipboard", type: .Success)

            case 1:
                println("reset all pins")
                self.delegate?.resetAllPinFunctions()
                self.dismissViewControllerAnimated(true, completion: nil)
//                TSMessage.showNotificationInViewController(self, title: "Pin functions", subtitle: "Your device ID string has been copied to clipboard", type: .Message)

            case 2:
                println("reflash tinker")
                if self.device!.isFlashing == false
                {
                    switch (self.device!.type)
                    {
                        
                    case .Core:
                        self.device!.flashKnownApp("tinker", completion: { (error:NSError!) -> Void in
                            if let e=error
                            {
                                TSMessage.showNotificationWithTitle("Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .Error)
                            }
                            else
                            {
                                TSMessage.showNotificationWithTitle("Flashing successful", subtitle: "Please wait while your device is being flashed with Tinker firmware...", type: .Success)
                                self.device!.isFlashing = true
                            }
                        })
                        
                    case .Photon:
                        let bundle = NSBundle.mainBundle()
                        let path = bundle.pathForResource("photon-tinker", ofType: "bin")
                        var error:NSError?
                        if let binary: NSData? = NSData.dataWithContentsOfMappedFile(path!) as? NSData // TODO: fix depracation
                        {
                            let filesDict = ["tinker.bin" : binary!]
                            self.device!.flashFiles(filesDict, completion: { (error:NSError!) -> Void in
                                if let e=error
                                {
                                    TSMessage.showNotificationWithTitle("Flashing error", subtitle: "Error flashing device: \(e.localizedDescription)", type: .Error)
                                }
                                else
                                {
                                    TSMessage.showNotificationWithTitle("Flashing successful", subtitle: "Please wait while your device is being flashed with Tinker firmware...", type: .Success)
                                    self.device!.isFlashing = true
                                }
                            })
                            
                        }
                    }
                }

                
                
            default:
                println("default0")
            
            }
        case 1: // documenation
            var url : NSURL?
            switch indexPath.row
            {
            case 0:
                println("documentation: app")
                url = NSURL(string: "http://docs.particle.io/photon/tinker/#tinkering-with-tinker")
            case 1:
                println("documentation: setup your device")
                url = NSURL(string: "http://docs.particle.io/photon/connect/#connecting-your-device")

            case 2:
                println("documentation: make ios app")
                url = NSURL(string: "http://docs.particle.io/photon/ios/#ios-cloud-sdk")
                
            default:
                println("default1")
                
            }
        
            
            var webVC : WebViewController = self.storyboard!.instantiateViewControllerWithIdentifier("webview") as! WebViewController
            webVC.link = url
            webVC.linkTitle = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
            
            self.presentViewController(webVC, animated: true, completion: nil)
            
        case 2: // Support
            var url : NSURL?
            switch indexPath.row
            {
                case 0:
                println("support: community")
                url = NSURL(string: "http://community.particle.io/")
                
                case 1:
                println("support: email")
                url = NSURL(string: "http://support.particle.io/hc/en-us")
                
                default:
                println("default2")
            }
            
            var webVC : WebViewController = self.storyboard!.instantiateViewControllerWithIdentifier("webview") as! WebViewController
            webVC.link = url
            webVC.linkTitle = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text

            self.presentViewController(webVC, animated: true, completion: nil)
            
        default:
            println("default")

            
            
        }
    
    
    }

}
