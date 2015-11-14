//
//  WebViewController.swift
//  Particle
//
//  Created by Ido on 6/2/15.
//  Copyright (c) 2015 Particle. All rights reserved.
//

import UIKit

class ElectronSetupViewController: UIViewController, UIWebViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "http://localhost:8080")
        
        self.navBar.topItem?.title = "Electron Setup"
        self.navBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Gotham-Book", size: 17)!]//,  NSForegroundColorAttributeName: UIColor.blackColor()]
        
        self.request = NSURLRequest(URL: url!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 15.0)
        self.webView.loadRequest(self.request!)
        
        self.webView.scalesPageToFit = true
        self.webView.delegate = self;
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var navBar: UINavigationBar!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var webView: UIWebView!
    var link : NSURL? = nil

    var request : NSURLRequest? = nil
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startSpinner()
    {
        
        /*
        var hud : MBProgressHUD
        
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .CustomView//.Indeterminate
        hud.animationType = .ZoomIn
        hud.labelText = "Loading"
        hud.minShowTime = 0.3
        hud.dimBackground = true
        
        // prepare spinner view for first time populating of devices into table
        var spinnerView : UIImageView = UIImageView(image: UIImage(named: "imgSpinner"))
        spinnerView.frame = CGRectMake(0, 0, 37, 37);
        spinnerView.contentMode = .ScaleToFill
        var rotation = CABasicAnimation(keyPath:"transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2*M_PI
        rotation.duration = 1.0;
        rotation.repeatCount = 1000; // Repeat
        spinnerView.layer.addAnimation(rotation,forKey:"Spin")
        
        hud.customView = spinnerView
        */
        
    }
    
    func stopSpinner()
    {
        //        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.stopSpinner()
        print("failed loading")
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.startSpinner()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.stopSpinner()
        
        let contentSize = self.webView.scrollView.contentSize;
        let viewSize = self.view.bounds.size;
        
        let rw = viewSize.width / contentSize.width;
        
        self.webView.scrollView.minimumZoomScale = rw;
        self.webView.scrollView.maximumZoomScale = rw;
        self.webView.scrollView.zoomScale = rw;

        // set global var
        let jsFunc = "const mobile='ios'"
        self.webView.stringByEvaluatingJavaScriptFromString(jsFunc);

    }
    
}
