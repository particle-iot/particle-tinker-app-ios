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
            newStr = newStr.stringByReplacingOccurrencesOfString(name, withString: value)
        }
        return newStr
    }
}


class ElectronSetupViewController: UIViewController, UIWebViewDelegate, ScanBarcodeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "https://setup.particle.io/") //://localhost:8080") //staging.particle.io
        
        self.request = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringCacheData, timeoutInterval: 10.0)
        self.webView.loadRequest(self.request!)
        
        
//        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.webView.scrollView.bounces = false
        self.closeButton.hidden = true
        
        // Slick hack to get the JS console.logs() to XCode debugger!
        self.context = self.webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as? JSContext
        let logFunction : @convention(block) (String) -> Void =
        {
            (msg: String) in
            NSLog("JS Console: %@", msg)
        }
        context!.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, AnyObject.self), forKeyedSubscript: "log")
        
        // force inject the access token and current username into the JS context global 'window' object
        context!.objectForKeyedSubscript("window").setObject(SparkCloud.sharedInstance().accessToken, forKeyedSubscript: "particleAccessToken")
        context!.objectForKeyedSubscript("window").setObject(SparkCloud.sharedInstance().loggedInUsername, forKeyedSubscript: "particleUsername")
        context!.objectForKeyedSubscript("window").setObject("ios", forKeyedSubscript: "mobileClient")

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var closeButton: UIButton!

    var context : JSContext? = nil
    
    @IBOutlet weak var webView: UIWebView!
    var request : NSURLRequest? = nil
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
       
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startSpinner()
    {
     
        if !self.loading
        {
            dispatch_async(dispatch_get_main_queue()) {

                var hud : MBProgressHUD
                
                hud = MBProgressHUD.showHUDAddedTo(self.webView, animated: true)
                self.loading = true
                hud.mode = .CustomView //.Indeterminate
                hud.animationType = .ZoomIn
                hud.labelText = "Loading"
//                hud.minShowTime = 0.3
                hud.dimBackground = false
                
                // prepare spinner view for first time populating of devices into table
                let spinnerView : UIImageView = UIImageView(image: UIImage(named: "imgSpinner"))
                spinnerView.frame = CGRectMake(0, 0, 37, 37);
                spinnerView.contentMode = .ScaleToFill
                let rotation = CABasicAnimation(keyPath:"transform.rotation")
                rotation.fromValue = 0
                rotation.toValue = 2*M_PI
                rotation.duration = 1.0;
                rotation.repeatCount = 1000; // Repeat
                spinnerView.layer.addAnimation(rotation,forKey:"Spin")
                hud.customView = spinnerView
            }
        }

        
    }
    
    func stopSpinner()
    {
        dispatch_async(dispatch_get_main_queue()) {
            MBProgressHUD.hideHUDForView(self.webView, animated: true)
            self.loading = false
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.stopSpinner()
        print("failed loading")
        self.closeButton.hidden = false
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        print("DidStartLoad")
        self.loadFramesCount++
//        self.startSpinner()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("DidFinishLoad")
        print(self.loadFramesCount)
        if --self.loadFramesCount <= 0 {
            self.stopSpinner()
            self.closeButton.hidden = false
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
    
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("shouldStartLoadWithRequest \(request.description)");
        
        let myAppScheme = "particle"
        
        if request.URL?.scheme != myAppScheme {
            self.startSpinner()
            return true
        }
        
        let actionType = request.URL?.host;
//        let jsonDictString = request.URL?.fragment?.stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
        if actionType == "scanIccid" {
            self.performSegueWithIdentifier("scan", sender: self)
        } else if actionType == "scanCreditCard" {
            print("Scan credit card requested.. not implemented yet")
        } else if actionType == "done" {
            self.closeButtonTapped(self)
        } else if actionType == "notification" {
//            print("\(request.URL)")
            //            print("fragment: \(request.URL?.fragment?.unescape())")
            
            let JSONDictionary : NSDictionary?
            if let JSONData = request.URL?.fragment?.unescape().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                do {
                    
                    JSONDictionary = try NSJSONSerialization.JSONObjectWithData(JSONData, options: .AllowFragments) as? NSDictionary
                } catch _ {
                    print("could not deserialize request");
                    JSONDictionary = nil
                }
                //print (JSONDictionary?.description)
                dispatch_async(dispatch_get_main_queue()) {
                    if JSONDictionary != nil {
                        if JSONDictionary!["level"] as! String == "info" {
                            TSMessage.showNotificationInViewController(self, title: JSONDictionary!["title"] as! String!, subtitle: JSONDictionary!["message"] as! String!, type: .Success)
                        } else {
                            TSMessage.showNotificationInViewController(self, title: JSONDictionary!["title"] as! String!, subtitle: JSONDictionary!["message"] as! String!, type: .Error)
                        }
                    }
                }
            }
        }
        
        return false;

        
    }
    
    // MARK: ScanBarcodeViewControllerDelegate functions
    
    func didFinishScanningBarcodeWithResult(scanBarcodeViewController: ScanBarcodeViewController!, barcodeValue: String!) {
//        self.startSpinner()
        self.stopSpinner()
        scanBarcodeViewController.dismissViewControllerAnimated(true, completion: {
            dispatch_async(dispatch_get_main_queue()) {
            
                var jsCode : String = "var inputElement = document.getElementById('iccid');\n"
                jsCode+="inputElement.value = '\(barcodeValue)';\n"
                jsCode+="var e = new Event('change');\n"
                jsCode+="e.target = inputElement;\n"
                jsCode+="inputElement.dispatchEvent(e);\n"
            
                self.webView.stringByEvaluatingJavaScriptFromString(jsCode)
//            self.context = self.webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as? JSContext
//            self.context!.evaluateScript(jsCode)  // this causes a crash for some strange reason
            
            }
        })
        
        
    }
    
    func didCancelScanningBarcode(scanBarcodeViewController: ScanBarcodeViewController!) {
        scanBarcodeViewController .dismissViewControllerAnimated(true, completion: nil)
        print("ICCID barcode scanning cancelled by user")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scan" {
            let sbcvc = segue.destinationViewController as? ScanBarcodeViewController
            sbcvc!.delegate = self
        }
    }
    

}
