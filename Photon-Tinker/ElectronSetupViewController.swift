//
//  WebViewController.swift
//  Particle
//
//  Created by Ido on 6/2/15.
//  Copyright (c) 2015 Particle. All rights reserved.
//

import UIKit
import JavaScriptCore

extension String {
    func unescape()->String {
        
        guard (self != "") else { return self }
        
        var newStr = self
        
        let entities = [
            "%7B" : "{",
            "%7D" : "}",
            "%20" : " ",
            "%3A" : ":",
            "%22" : "\"",
            "%2C" : ",",
        ]
        
        for (name,value) in entities {
            newStr = newStr.replacingOccurrences(of: name, with: value)
        }
        return newStr
    }
}


class ElectronSetupViewController: UIViewController, UIWebViewDelegate, ScanBarcodeViewControllerDelegate {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    
    func printTimestamp() -> String {
        let t = (Date().timeIntervalSince1970 - self.startTime);
        return String(format:"%f", t)
    }
    
    var startTime : Double = 0;

    override func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 13.0, *) {
            if self.responds(to: Selector("overrideUserInterfaceStyle")) {
                self.setValue(UIUserInterfaceStyle.light.rawValue, forKey: "overrideUserInterfaceStyle")
            }
        }
        
        self.modalPresentationStyle = .fullScreen
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startTime = Date().timeIntervalSince1970
        
        print("start:"+self.printTimestamp())

        if ParticleCloud.sharedInstance().currentBaseURL.contains("staging") {
            self.setupWebAddress = URL(string: "https://setup.staging.particle.io?mobile=true")
        } else {
            self.setupWebAddress = URL(string: "https://setup.particle.io?mobile=true")
        }
//        let url =
        
        self.request = URLRequest(url: self.setupWebAddress!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        
//        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.webView.loadRequest(self.request!)
        
//        print("after load request:"+self.printTimestamp())

        self.webView.scrollView.bounces = false
        self.closeButton.isHidden = false//true
        
        // Slick hack to get the JS console.logs() to XCode debugger!
        
        self.context = self.webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        
        let logFunction : @convention(block) (String) -> Void =
        {
            (msg: String) in
            NSLog("JS Console: %@", msg)
        }
//        context!.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self), forKeyedSubscript: "log" as (NSCopying & NSObjectProtocol)!)
//        print("after tapping into console logs:"+self.printTimestamp())
        
        
        // force inject the access token and current username into the JS context global 'window' object
        context!.objectForKeyedSubscript("window").setObject(ParticleCloud.sharedInstance().accessToken, forKeyedSubscript: "particleAccessToken" as (NSCopying & NSObjectProtocol)!)
        context!.objectForKeyedSubscript("window").setObject(ParticleCloud.sharedInstance().loggedInUsername, forKeyedSubscript: "particleUsername" as (NSCopying & NSObjectProtocol)!)
        context!.objectForKeyedSubscript("window").setObject("ios", forKeyedSubscript: "mobileClient" as (NSCopying & NSObjectProtocol)!)  

//        print("after setting mobileClient:"+self.printTimestamp())
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var closeButton: UIButton!

    var context : JSContext? = nil
    var setupWebAddress : URL? = nil
    
    @IBOutlet weak var webView: UIWebView!
    var request : URLRequest? = nil
    var loading : Bool = false
    var loadFramesCount : Int = 0
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        SEGAnalytics.shared().track("Tinker: Electron setup ended", properties: ["result":"cancelled"])
        self.dismiss(animated: true, completion: nil)
    }
    

    func startSpinner()
    {
        if !self.loading
        {
            ParticleSpinner.show(self.view)
            self.loading = true
        }
    }
    
    func stopSpinner()
    {
        ParticleSpinner.hide(self.view)
        self.loading = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.stopSpinner()
//        print("failed loading")
        self.closeButton.isHidden = false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
//        print("DidStartLoad")
        self.loadFramesCount += 1
//        self.startSpinner()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        print("webViewDidFinishLoad:"+self.printTimestamp())
        self.loadFramesCount-=1
        if self.loadFramesCount <= 0 {
            self.stopSpinner()
            self.closeButton.isHidden = false
        }
    }
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let myAppScheme = "particle"
        
        if request.url?.scheme != myAppScheme { //&& request.URL?.host != self.setupWebAddress?.host {
            if navigationType == UIWebViewNavigationType.linkClicked {
                UIApplication.shared.openURL(request.url!)
                return false
            } else {
                
                self.startSpinner()
                return true
            }
        }
        
        let actionType = request.url?.host;
        if actionType == "scanIccid" {
            SEGAnalytics.shared().track("Tinker_ElectronSetupScanICCID")
            self.performSegue(withIdentifier: "scan", sender: self)
        } else if actionType == "scanCreditCard" {
            print("Scan credit card requested.. not implemented yet")
        } else if actionType == "done" {
            SEGAnalytics.shared().track("Tinker_ElectronSetupEnded", properties: ["result":"success"])
            self.dismiss(animated: true, completion: nil)
        } else if actionType == "notification" {
            let JSONDictionary : NSDictionary?
            if let JSONData = request.url?.fragment?.unescape().data(using: String.Encoding.utf8, allowLossyConversion: false) {
                do {
                    
                    JSONDictionary = try JSONSerialization.jsonObject(with: JSONData, options: .allowFragments) as? NSDictionary
                } catch _ {
                    print("could not deserialize request");
                    JSONDictionary = nil
                }
                DispatchQueue.main.async {
                    if JSONDictionary != nil {
                        //crash is happening here, because unable to unwrap title/message. This is to prevent the crash
                        //TODO: investigate why this is nil
                        let title: String? = JSONDictionary!["title"] as? String
                        let message: String? = JSONDictionary!["message"] as? String

                        if JSONDictionary!["level"] as! String == "info" {
                            RMessage.showNotification(in: self, title: title ?? "", subtitle: message ?? "", type: .success, customTypeName: nil, callback: nil)
                        } else {
                            RMessage.showNotification(in: self, title: title ?? "", subtitle: message ?? "", type: .error, customTypeName: nil, duration: -1, callback: nil)
                        }
                    }
                }
            }
        }
        
        return false;

        
    }
    
    // MARK: ScanBarcodeViewControllerDelegate functions

    func didFinishScanningBarcode(withResult scanBarcodeViewController: ScanBarcodeViewController, barcodeValue: String) {
        self.stopSpinner()
        scanBarcodeViewController.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
            
                var jsCode : String = "var inputElement = document.getElementById('iccid');\n"
                jsCode+="inputElement.value = '\(barcodeValue)';\n"
                jsCode+="var e = new Event('change');\n"
                jsCode+="e.target = inputElement;\n"
                jsCode+="inputElement.dispatchEvent(e);\n"
            
                self.webView.stringByEvaluatingJavaScript(from: jsCode)
            }
        })
        
        
    }
    
    func didCancelScanningBarcode(_ scanBarcodeViewController: ScanBarcodeViewController) {
        scanBarcodeViewController .dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan" {
            let sbcvc = segue.destination as? ScanBarcodeViewController
            sbcvc!.delegate = self
        }
    }
}
