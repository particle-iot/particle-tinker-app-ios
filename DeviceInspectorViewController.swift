//
//  DeviceInspectorController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/27/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

class DeviceInspectorViewController : UIViewController {
    
    
    
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBOutlet weak var actionButtonTapped: UIButton!
    
    @IBOutlet weak var deviceOnlineIndicatorImageView: UIImageView!
    
    
    @IBAction func segmentControlChanged(sender: UISegmentedControl) {
        
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: {
            self.deviceInfoContainerView.alpha = (sender.selectedSegmentIndex == 0 ? 1.0 : 0.0)
            self.deviceDataContainerView.alpha = (sender.selectedSegmentIndex == 1 ? 1.0 : 0.0)
            self.deviceEventsContainerView.alpha = (sender.selectedSegmentIndex == 2 ? 1.0 : 0.0)
            
        }) { (Bool) in
            self.deviceInfoContainerView.hidden = (sender.selectedSegmentIndex == 0 ? false : true)
            self.deviceDataContainerView.hidden = (sender.selectedSegmentIndex == 1 ? false : true)
            self.deviceEventsContainerView.hidden = (sender.selectedSegmentIndex == 2 ? false : true)
            
        }
    }
    
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var deviceEventsContainerView: UIView!
    @IBOutlet weak var deviceDataContainerView: UIView!
    @IBOutlet weak var deviceInfoContainerView: UIView!
    
    var device : SparkDevice?
    
    
    override func viewDidLoad() {

        self.deviceInfoContainerView.hidden = false
        self.deviceDataContainerView.hidden = true
        self.deviceEventsContainerView.hidden = true

       
        let font = UIFont(name: "Gotham-book", size: 15.0)
        
        let attrib = [NSFontAttributeName : font!]
        
        self.modeSegmentedControl.setTitleTextAttributes(attrib, forState: .Normal)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // if its either the info data or events VC then set the device to what we are inspecting
        if let vc = segue.destinationViewController as? DeviceInspectorChildViewController {
            vc.device = self.device
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        DeviceUtils.animateOnlineIndicatorImageView(self.deviceOnlineIndicatorImageView, online: self.device!.connected)
    }
    
    
}