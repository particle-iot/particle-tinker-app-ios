//
//  WebViewController.swift
//  Particle
//
//  Created by Ido on 6/2/15.
//  Copyright (c) 2015 Particle. All rights reserved.
//

import UIKit
import JavaScriptCore

class ElectronSetupViewController: UIViewController, UIWebViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "http://localhost:8080/")
//        self.navBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
//        self.navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        self.navBar.shadowImage = UIImage()
//        self.navBar.translucent = false
        
//        self.navBar.topItem?.title = "Electron Setup"
//        self.navBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Gotham-Book", size: 17)!]//,  NSForegroundColorAttributeName: UIColor.blackColor()]
        
        self.request = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringCacheData, timeoutInterval: 10.0)
        
//        self.webView.scalesPageToFit = true
        self.webView.delegate = self;
        
        // Amazing hack to get the JS console.logs() !
        let context = self.webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        let logFunction : @convention(block) (String) -> Void =
        {
            (msg: String) in
            NSLog("JS Console: %@", msg)
        }
        context.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, AnyObject.self), forKeyedSubscript: "log")
        
        
        context.objectForKeyedSubscript("window").setObject(unsafeBitCast(logFunction, AnyObject.self), forKeyedSubscript: "log")
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var navBar: UINavigationBar!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var webView: UIWebView!
    var request : NSURLRequest? = nil
    var loading : Bool = false
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(animated: Bool) {
        self.webView.loadRequest(self.request!)
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
                hud.dimBackground = true
                
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
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        print("DidStartLoad")
        self.startSpinner()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("DidFinishLoad")
        self.stopSpinner()
        
//        let contentSize = self.webView.scrollView.contentSize;
//        let viewSize = self.view.bounds.size;
//        
//        let rw = viewSize.width / contentSize.width;
//        
//        self.webView.scrollView.minimumZoomScale = rw;
//        self.webView.scrollView.maximumZoomScale = rw;
//        self.webView.scrollView.zoomScale = rw;

        let jsCallBack = "window.getSelection().removeAllRanges();"
        self.webView.stringByEvaluatingJavaScriptFromString(jsCallBack) //disable user markings
        
        // set global var
        var jsFunc = "window.particleAccessToken=\(SparkCloud.sharedInstance().accessToken)"
        self.webView.stringByEvaluatingJavaScriptFromString(jsFunc)

        jsFunc = "window.particleUsername=\(SparkCloud.sharedInstance().loggedInUsername)"
        self.webView.stringByEvaluatingJavaScriptFromString(jsFunc)
        
        jsFunc = "window.mobileClient='iOS'"
        self.webView.stringByEvaluatingJavaScriptFromString(jsFunc)


    }
    
}
