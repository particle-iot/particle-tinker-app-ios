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

    // MARK: - Table view data source

      /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        self.deviceIDlabel.text = self.device!.id
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
                println("default")
            
            }
        case 1: // documenation
            switch indexPath.row
            {
            case 0:
                println("documentation: app")
            case 1:
                println("documentation: setup")
            case 2:
                println("documentation: make ios app ")
            default:
                println("default")
                
            }
            
        case 2: // Support
            switch indexPath.row
            {
                case 0:
                println("support: community")
                case 1:
                println("support: email")
            default:
                println("default")
                
                
            }
        default:
            println("default")

            
            
        }
    
    
    }

}
