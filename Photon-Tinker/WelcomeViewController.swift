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

        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        
        let backgroundImage = UIImageView(image: UIImage(named: "imgTrianglifyBackgroundBlue"))
        backgroundImage.frame = UIScreen.mainScreen().bounds
        backgroundImage.contentMode = .ScaleToFill;
//        backgroundImage.alpha = 0.85
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
        let layer = self.getStartedButton.layer
        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.cornerRadius = 3.0
        layer.borderWidth = 2.0
        let verStr = "V"+(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String)
        self.versionLabel.text = verStr
        
        self.customizeSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func checkFontNames()
    {
        for family in UIFont.familyNames()
        {
            print("\(family)\n", terminator: "")
            for name in UIFont.fontNamesForFamilyName(family )
            {
                print("   \(name)\n", terminator: "")
            }
            
        }
    }
    

    // Function will be called when setup finishes
    func sparkSetupViewController(controller: SparkSetupMainController!, didFinishWithResult result: SparkSetupMainControllerResult, device: SparkDevice!) {
        
        if result == .LoggedIn
        {
            self.performSegueWithIdentifier("select", sender: self)
            
            let email = SparkCloud.sharedInstance().loggedInUsername
            Mixpanel.sharedInstance().identify(email!)
        }
        
        if result == .SkippedAuth
        {
            self.performSegueWithIdentifier("select", sender: self)
        }
    }
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    func customizeSetup()
    {
//        self.checkFontNames()
        // Do customization for Spark Setup wizard UI
        let c = SparkSetupCustomization.sharedInstance()
        
        c.allowSkipAuthentication = true
        c.skipAuthenticationMessage = "Skipping authentication will run the app in limited functionality mode - you would only be able to setup Wi-Fi credentials to devices but not claim them nor use Tinker. Are you sure you want to continue?"
        c.pageBackgroundImage = UIImage(named: "imgTrianglifyBackgroundBlue")
        c.normalTextFontName = "Gotham-Book"
        c.boldTextFontName = "Gotham-Medium"
        c.headerTextFontName = "Gotham-Light" // new
        //c.fontSizeOffset = 1;
        c.normalTextColor = UIColor.whiteColor()
        c.linkTextColor = UIColor.whiteColor()
        c.brandImageBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.25)

        c.linkTextColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
        c.elementTextColor = UIColor(red: 0, green: 186.0/255.0, blue: 236.0/255.0, alpha: 1.0) //(patternImage: UIImage(named: "imgOrangeGradient")!)
        c.elementBackgroundColor = UIColor.whiteColor()
        c.brandImage = UIImage(named: "particle-horizontal-head")
//        c.deviceImage = UIImage(named: "imgPhoton")
        c.tintSetupImages = true
        c.instructionalVideoFilename = "photon_wifi.mp4"
        
    }
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBAction func startButtonTapped(sender: UIButton)
    {
        if let _ = SparkCloud.sharedInstance().loggedInUsername
        {
            self.performSegueWithIdentifier("select", sender: self)
        }
        else
        {
            // lines required for invoking the Spark Setup wizard
            if let vc = SparkSetupMainController(authenticationOnly: true)
            {
                vc.delegate = self
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
      
}

