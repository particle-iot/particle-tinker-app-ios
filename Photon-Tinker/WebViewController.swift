//
//  WebViewController.swift
//  Particle
//
//  Created by Ido on 6/2/15.
//  Copyright (c) 2015 Particle. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: WKWebView!

    var loadFramesCount : Int = 0
    var loading : Bool = false

    var link : URL? = nil
    var linkTitle : String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar.topItem?.title = self.linkTitle
        self.navBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Gotham-Book", size: 17)!, NSAttributedString.Key.foregroundColor: ParticleUtils.particleGrayColor]

        self.webView.navigationDelegate = self

        let request = URLRequest(url: self.link!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15.0)
        self.webView.load(request)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ParticleSpinner.hide(self.view)
        self.loading = false
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        ParticleSpinner.hide(self.view)
        self.loading = false
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !self.loading {
            self.loading = true
            ParticleSpinner.show(self.view)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ParticleSpinner.hide(self.view)
        self.loading = false
        // WKWebView honours the page viewport, so no manual page-to-fit scaling is required.
    }

    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
