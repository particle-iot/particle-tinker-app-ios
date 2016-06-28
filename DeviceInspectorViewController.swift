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
    }
    
    
    @IBOutlet weak var actionButtonTapped: UIButton!
    
    
    
    @IBAction func segmentControlChanged(sender: UISegmentedControl) {
        
        UIView.animateWithDuration(1.0) { 
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
    
    
}