//
//  ViewController.swift
//  Photon-Tikner
//
//  Created by Ido on 4/7/15.
//  Copyright (c) 2015 particle. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, ParticleSetupMainControllerDelegate {

    @IBOutlet weak var getStartedButton: ParticleButton!
    @IBOutlet weak var versionLabel: UILabel!

    private var versionLabelTapCount = 0

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)

        let verStr = TinkerStrings.Welcome.Version
                .replacingOccurrences(of: "{{0}}", with: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
                .replacingOccurrences(of: "{{1}}", with:(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String))
        self.versionLabel.text = verStr
        
        if let _ = ParticleCloud.sharedInstance().loggedInUsername
        {
            self.performSegue(withIdentifier: "start_no_animation", sender: self)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        versionLabelTapCount = 0
    }

    func checkFontNames()
    {
        for family in UIFont.familyNames
        {
            print("\(family)\n", terminator: "")
            for name in UIFont.fontNames(forFamilyName: family )
            {
                print("   \(name)\n", terminator: "")
            }
            
        }
    }
    

    // Function will be called when setup finishes
    func particleSetupViewController(_ controller: ParticleSetupMainController!, didFinishWith result: ParticleSetupMainControllerResult, device: ParticleDevice!) {
        if result == .loggedIn
        {
            self.performSegue(withIdentifier: "start", sender: self)
            
            if let email = ParticleCloud.sharedInstance().loggedInUsername {
                SEGAnalytics.shared().identify(email)
            }
        }
        
        if result == .skippedAuth
        {
            self.performSegue(withIdentifier: "start", sender: self)
        }
    }

    func customizeSetupForLoginFlow()
    {
        // Do customization for Particle Setup wizard UI
        let c = ParticleSetupCustomization.sharedInstance()
        
        c?.allowSkipAuthentication = true
        c?.skipAuthenticationMessage = TinkerStrings.Welcome.SkipAuthWarning
        c?.pageBackgroundImage = UIImage(named: "ImgAppBackground")
        c?.normalTextFontName = "Gotham-Book"
        c?.boldTextFontName = "Gotham-Medium"
        c?.headerTextFontName = "Gotham-Light" // new
        c?.normalTextColor = UIColor.white
        c?.linkTextColor = UIColor.white

        c?.linkTextColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
        c?.elementTextColor = UIColor(red: 0, green: 186.0/255.0, blue: 236.0/255.0, alpha: 1.0) //(patternImage: UIImage(named: "ImgOrangeGradient")!)
        c?.elementBackgroundColor = UIColor.white
        c?.brandImage = UIImage(named: "ImgParticleLogoHorizontal")
        c?.brandImageBackgroundColor = .clear
        c?.brandImageBackgroundImage = nil
        c?.tintSetupImages = true
        c?.allowPasswordManager = true
        c?.lightStatusAndNavBar = true
        
        #if ORG_TEST_MODE
            ParticleSetupCustomization.sharedInstance().organization = true
            ParticleSetupCustomization.sharedInstance().organizationSlug = "dinobots"
            ParticleSetupCustomization.sharedInstance().productSlug = "ido-test-product-1"
            
            // for creating customers (signup) to work you need:
            ParticleCloud.sharedInstance().OAuthClientId = orgTestClientId
            ParticleCloud.sharedInstance().OAuthClientSecret = orgTestSecret

            print("Tinker app in ORG_TEST_MODE")
        #endif
    }

    @IBAction func startButtonTapped(_ sender: UIButton?)
    {
        if (sender != nil) {
            ParticleCloud.sharedInstance().customAPIBaseURL = nil
        }

        if let _ = ParticleCloud.sharedInstance().loggedInUsername
        {
            self.performSegue(withIdentifier: "start", sender: self)
        }
        else
        {
            self.customizeSetupForLoginFlow()
            if let vc = ParticleSetupMainController(authenticationOnly: true)
            {
                vc.delegate = self
                vc.startWithLogin = true
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func versionButtonTapped(_ sender: Any) {
        versionLabelTapCount += 1

        if (versionLabelTapCount >= 10) {
            versionLabelTapCount = 0

            let ac = UIAlertController(title: TinkerStrings.Welcome.CloudAPIPrompt.Title, message: TinkerStrings.Welcome.CloudAPIPrompt.Message, preferredStyle: .alert)
            ac.addTextField { field in
                field.placeholder = TinkerStrings.Welcome.CloudAPIPrompt.Title
                field.text = kParticleAPIBaseURL
            }

            ac.addAction(UIAlertAction(title: TinkerStrings.Action.Use, style: .default) { action in
                let baseURL = ac.textFields?[0].text

                ParticleCloud.sharedInstance().customAPIBaseURL = baseURL
                self.startButtonTapped(nil)
            })

            ac.addAction(UIAlertAction(title: TinkerStrings.Action.Cancel, style: .cancel))

            self.present(ac, animated: true)
        }
    }
    
      
}

