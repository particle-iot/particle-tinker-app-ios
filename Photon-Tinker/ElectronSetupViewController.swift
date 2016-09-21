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
//        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .FullStyle)
        let t = (Date().timeIntervalSince1970 - self.startTime);
        return String(format:"%f", t)
    }
    
    var startTime : Double = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startTime = Date().timeIntervalSince1970
        
        print("start:"+self.printTimestamp())
        
        self.setupWebAddress = URL(string: "https://setup.particle.io/") //://localhost:8080") //
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
//            NSLog("JS Console: %@", msg)
        }
        context!.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self), forKeyedSubscript: "log" as (NSCopying & NSObjectProtocol)!)
//        print("after tapping into console logs:"+self.printTimestamp())
        
        
        // force inject the access token and current username into the JS context global 'window' object
        context!.objectForKeyedSubscript("window").setObject(SparkCloud.sharedInstance().accessToken, forKeyedSubscript: "particleAccessToken" as (NSCopying & NSObjectProtocol)!)
        context!.objectForKeyedSubscript("window").setObject(SparkCloud.sharedInstance().loggedInUsername, forKeyedSubscript: "particleUsername" as (NSCopying & NSObjectProtocol)!)
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
//        print("DidFinishLoad")
//        print(self.loadFramesCount)
        self.loadFramesCount-=1
        if self.loadFramesCount <= 0 {
            self.stopSpinner()
            self.closeButton.isHidden = false
        }
        
//        let contentSize = self.webView.scrollView.contentSize;
//        let viewSize = self.view.bounds.size;
//        
//        let rw = viewSize.width / contentSize.width;
//        
//        self.webView.scrollView.minimumZoomScale = rw;
//        self.webView.scrollView.maximumZoomScale = rw;
//        self.webView.scrollView.zoomScale = rw;

//        let jsCallBack = "window.getSelection().removeAllRanges();"
//        self.webView.stringByEvaluatingJavaScriptFromString(jsCallBack) //disable user markings

        /*

        // old and laggy technique to inject access token to JS code - bye bye
        // set global var
        var jsFunc = "window.particleAccessToken=\(SparkCloud.sharedInstance().accessToken)"
        self.webView.stringByEvaluatingJavaScriptFromString(jsFunc)

        jsFunc = "window.particleUsername=\(SparkCloud.sharedInstance().loggedInUsername)"
        self.webView.stringByEvaluatingJavaScriptFromString(jsFunc)
        
        jsFunc = "window.mobileClient='iOS'"
        self.webView.stringByEvaluatingJavaScriptFromString(jsFunc)

        */


    }
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        print("shouldStartLoadWithRequest \(request.description)");
        
        if let rurl = request.url {
            print("shouldStartLoadWithRequest: "+rurl.description+" : "+self.printTimestamp())
        } else {
            print("shouldStartLoadWithRequest: "+self.printTimestamp())
        }
        
        
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
//        let jsonDictString = request.URL?.fragment?.stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
        if actionType == "scanIccid" {
            SEGAnalytics.shared().track("Tinker: Electron setup scan ICCID")
            self.performSegue(withIdentifier: "scan", sender: self)
        } else if actionType == "scanCreditCard" {
            print("Scan credit card requested.. not implemented yet")
        } else if actionType == "done" {
            SEGAnalytics.shared().track("Tinker: Electron setup ended", properties: ["result":"success"])
            self.dismiss(animated: true, completion: nil)
        } else if actionType == "notification" {
//            print("\(request.URL)")
            //            print("fragment: \(request.URL?.fragment?.unescape())")
            
            let JSONDictionary : NSDictionary?
            if let JSONData = request.url?.fragment?.unescape().data(using: String.Encoding.utf8, allowLossyConversion: false) {
                do {
                    
                    JSONDictionary = try JSONSerialization.jsonObject(with: JSONData, options: .allowFragments) as? NSDictionary
                } catch _ {
                    print("could not deserialize request");
                    JSONDictionary = nil
                }
                //print (JSONDictionary?.description)
                DispatchQueue.main.async {
                    if JSONDictionary != nil {
                        if JSONDictionary!["level"] as! String == "info" {
                            TSMessage.showNotification(in: self, title: JSONDictionary!["title"] as! String!, subtitle: JSONDictionary!["message"] as! String!, type: .success)
                        } else {
                            TSMessage.showNotification(in: self, title: JSONDictionary!["title"] as! String!, subtitle: JSONDictionary!["message"] as! String!, type: .error)
                        }
                    }
                }
            }
        }
        
        return false;

        
    }
    
    // MARK: ScanBarcodeViewControllerDelegate functions
    
    func didFinishScanningBarcode(withResult scanBarcodeViewController: ScanBarcodeViewController!, barcodeValue: String!) {
//        self.startSpinner()
        self.stopSpinner()
        scanBarcodeViewController.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
            
                var jsCode : String = "var inputElement = document.getElementById('iccid');\n"
                jsCode+="inputElement.value = '\(barcodeValue)';\n"
                jsCode+="var e = new Event('change');\n"
                jsCode+="e.target = inputElement;\n"
                jsCode+="inputElement.dispatchEvent(e);\n"
            
                self.webView.stringByEvaluatingJavaScript(from: jsCode)
//            self.context = self.webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as? JSContext
//            self.context!.evaluateScript(jsCode)  // this causes a crash for some strange reason
            
            }
        })
        
        
    }
    
    func didCancelScanningBarcode(_ scanBarcodeViewController: ScanBarcodeViewController!) {
        scanBarcodeViewController .dismiss(animated: true, completion: nil)
//        print("ICCID barcode scanning cancelled by user")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan" {
            let sbcvc = segue.destination as? ScanBarcodeViewController
            sbcvc!.delegate = self
        }
    }
    

}
