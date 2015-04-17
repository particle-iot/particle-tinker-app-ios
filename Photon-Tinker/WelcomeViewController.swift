//
//  ViewController.swift
//  Photon-Tikner
//
//  Created by Ido on 4/7/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, SparkSetupMainControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        SparkCloud.sharedInstance().logout()
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func checkFontNames()
    {
        for family in UIFont.familyNames()
        {
            print("\(family)\n")
            for name in UIFont.fontNamesForFamilyName(family as! String)
            {
                print("   \(name)\n")
            }
            
        }
    }
    

    
    
    // Function will be called when setup finishes
    func sparkSetupViewController(controller: SparkSetupMainController!, didFinishWithResult result: SparkSetupMainControllerResult, device: SparkDevice!) {
        
        if result == .LoggedIn
        {
            self.performSegueWithIdentifier("select", sender: self)
        }
    }
    
    
    func customizeSetup()
    {
//        self.checkFontNames()
        // Do customization for Spark Setup wizard UI
        let c = SparkSetupCustomization.sharedInstance()
        
//        c.brandImage = UIImage(named: "brand-logo-head")
//        c.brandName = "Acme"
//        c.brandImageBackgroundColor = UIColor(red: 0.88, green: 0.96, blue: 0.96, alpha: 0.9)
//        c.appName = "Acme Setup"
//        c.deviceImage = UIImage(named: "anvil")
//        c.deviceName = "Connected Anvil"
//        c.welcomeVideoFilename = "rr.mp4"
        
        c.pageBackgroundImage = UIImage(named: "imgBackgroundLogin")
        c.normalTextFontName = "Gotham-Book"
        c.boldTextFontName = "Gotham-Medium"
        //c.fontSizeOffset = 1;
        c.normalTextColor = UIColor.whiteColor()
        c.linkTextColor = UIColor.whiteColor()
        c.brandImageBackgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        
    }
    
    @IBAction func startButtonTapped(sender: UIButton)
    {
        if let u = SparkCloud.sharedInstance().loggedInUsername
        {
            self.performSegueWithIdentifier("select", sender: self)
        }
        else
        {
            // Comment out this line to revert to standard "Unbranded" Spark Setup app
            self.customizeSetup()
            
            // lines required for invoking the Spark Setup wizard
            if let vc = SparkSetupMainController(authenticationOnly: ())
            {
                vc.delegate = self
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    
}

