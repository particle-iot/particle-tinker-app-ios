//
//  ViewController.swift
//  Photon-Tikner
//
//  Copyright (c) 2019 particle. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, ParticleSetupMainControllerDelegate {

    @IBOutlet weak var getStartedButton: ParticleButton!
    @IBOutlet weak var versionLabel: UILabel!

    private var versionLabelTapCount = 0

    // Minimum time the branded splash (logo on navy) stays on screen for a logged-in
    // user before we continue to the device list, so it doesn't just flash by.
    private let splashMinimumDuration: TimeInterval = 2.0
    private var hasAutoStarted = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)

        let verStr = TinkerStrings.Welcome.Version
                .replacingOccurrences(of: "{{version}}", with: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
                .replacingOccurrences(of: "{{build}}", with:(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String))
        self.versionLabel.text = verStr
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // While we hold the splash for an already-logged-in user, present a clean logo
        // screen by hiding the call-to-action button. When logged out (e.g. after
        // returning here via logout) the button must be visible.
        let loggedIn = ParticleCloud.sharedInstance().loggedInUsername != nil
        self.getStartedButton.isHidden = loggedIn && !hasAutoStarted
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        versionLabelTapCount = 0

        if !hasAutoStarted, ParticleCloud.sharedInstance().loggedInUsername != nil {
            hasAutoStarted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + splashMinimumDuration) { [weak self] in
                guard let self = self else { return }
                self.performSegue(withIdentifier: "start_no_animation", sender: self)
            }
        }
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
        // The custom cloud API override (used to point the app at staging) is a
        // developer-only tool. It is compiled out of release builds so a shipped
        // build can never be redirected away from production.
        #if !DEBUG
            return
        #else
        versionLabelTapCount += 1

        if (versionLabelTapCount >= 10) {
            versionLabelTapCount = 0

            let ac = UIAlertController(title: TinkerStrings.Welcome.Prompt.CloudAPI.Title, message: TinkerStrings.Welcome.Prompt.CloudAPI.Message, preferredStyle: .alert)
            ac.addTextField { field in
                field.placeholder = TinkerStrings.Welcome.Prompt.CloudAPI.Title
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
        #endif
    }


}

