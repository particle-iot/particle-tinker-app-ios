//
//  WebViewController.swift
//  Particle
//
//  Created by Ido on 6/2/15.
//  Copyright (c) 2015 Particle. All rights reserved.
//

import UIKit
import WebKit

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


class ElectronSetupViewController: UIViewController, WKNavigationDelegate, ScanBarcodeViewControllerDelegate {

    typealias ElectronSetupCallback = (Bool) -> ()

    private var callback: ElectronSetupCallback?

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }


    public func setCallback(callback: @escaping ElectronSetupCallback) {
        self.callback = callback
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
            self.setupWebAddress = URL(string: "https://setup.staging.particle.io?mobile=true&enableElectronStickerScan=true&enableESeriesStickerScan=true")
        } else {
            self.setupWebAddress = URL(string: "https://setup.particle.io?mobile=true&enableElectronStickerScan=true&enableESeriesStickerScan=true")
        }
//        let url =
        
        self.request = URLRequest(url: self.setupWebAddress!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)

        // Force inject the access token and current username into the page's global
        // 'window' object before any page script runs. On UIWebView this was done by
        // reaching into the private JSContext; the WKWebView equivalent is a user
        // script injected at document start.
        let bootstrapJS = """
            window.particleAccessToken = \(Self.jsString(ParticleCloud.sharedInstance().accessToken));
            window.particleUsername = \(Self.jsString(ParticleCloud.sharedInstance().loggedInUsername));
            window.mobileClient = "ios";
        """
        let userContentController = WKUserContentController()
        userContentController.addUserScript(WKUserScript(source: bootstrapJS, injectionTime: .atDocumentStart, forMainFrameOnly: true))

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        // Keep the web view behind the close button, which is wired up in the storyboard.
        self.view.insertSubview(webView, at: 0)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
        self.webView = webView

        self.closeButton.isHidden = false//true

        self.webView.load(self.request!)
    }

    // Encodes a Swift optional string as a safe JavaScript string literal (or `null`).
    private static func jsString(_ value: String?) -> String {
        guard let value = value,
              let data = try? JSONSerialization.data(withJSONObject: [value], options: []),
              let json = String(data: data, encoding: .utf8) else {
            return "null"
        }
        // json is `["..."]`; strip the surrounding array brackets to get the literal.
        return String(json.dropFirst().dropLast())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var closeButton: UIButton!

    var setupWebAddress : URL? = nil

    var webView: WKWebView!
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
        self.dismiss(animated: true) { [weak self] in
            if let callback = self?.callback {
                callback(false)
            }
        }
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
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.stopSpinner()
//        print("failed loading")
        self.closeButton.isHidden = false
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.stopSpinner()
        self.closeButton.isHidden = false
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        print("DidStartLoad")
        self.loadFramesCount += 1
//        self.startSpinner()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        print("webViewDidFinishLoad:"+self.printTimestamp())
        self.loadFramesCount-=1
        if self.loadFramesCount <= 0 {
            self.stopSpinner()
            self.closeButton.isHidden = false
        }
    }


    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        let myAppScheme = "particle"

        if request.url?.scheme != myAppScheme { //&& request.URL?.host != self.setupWebAddress?.host {
            if navigationAction.navigationType == .linkActivated {
                if let url = request.url {
                    UIApplication.shared.open(url)
                }
                decisionHandler(.cancel)
                return
            } else {

                self.startSpinner()
                decisionHandler(.allow)
                return
            }
        }

        let actionType = request.url?.host;
        if actionType == "scanSerialNum" {
            SEGAnalytics.shared().track("Tinker_ESerisSetupScanSerialNumber")
            self.performSegue(withIdentifier: "scan", sender: "eseries")
        } else if actionType == "scanIccid" {
            SEGAnalytics.shared().track("Tinker_ElectronSetupScanICCID")
            self.performSegue(withIdentifier: "scan", sender: "iccid")
        } else if actionType == "scanCreditCard" {
            print("Scan credit card requested.. not implemented yet")
        } else if actionType == "done" {
            SEGAnalytics.shared().track("Tinker_ElectronSetupEnded", properties: ["result":"success"])
            self.dismiss(animated: true) { [weak self] in
                if let callback = self?.callback {
                    callback(true)
                }
            }
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
                        let title: String? = JSONDictionary!["title"] as? String
                        let message: String? = JSONDictionary!["message"] as? String

                        DispatchQueue.main.async {
                            if JSONDictionary!["level"] as! String == "info" {
                                RMessage.showNotification(in: self, title: title ?? "", subtitle: message ?? "", type: .success, customTypeName: nil, callback: nil)
                            } else {
                                RMessage.showNotification(in: self, title: title ?? "", subtitle: message ?? "", type: .error, customTypeName: nil, duration: -1, callback: nil)
                            }
                        }
                    }
                }
            }
        }

        decisionHandler(.cancel)
    }

    // MARK: ScanBarcodeViewControllerDelegate functions

    func didFinishScanningBarcode(withResult scanBarcodeViewController: ScanBarcodeViewController, barcodeValue: String) {
        self.stopSpinner()
        scanBarcodeViewController.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
            
                let jsCode : String = """
                    if (window.__PARTICLE_SET_SCANCODE){
                        window.__PARTICLE_SET_SCANCODE("\(barcodeValue)");
                    }
                """

                self.webView.evaluateJavaScript(jsCode, completionHandler: nil)
            }
        })
        
        
    }
    
    func didCancelScanningBarcode(_ scanBarcodeViewController: ScanBarcodeViewController) {
        scanBarcodeViewController .dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan" {
            let sbcvc = segue.destination as! ScanBarcodeViewController
            if let code = sender as? String {
                sbcvc.eSeriesSetup = (code == "eseries")
            } else {
                sbcvc.eSeriesSetup = false
            }
            sbcvc.delegate = self
        }
    }
}
