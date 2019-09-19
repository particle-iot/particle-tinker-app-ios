//
//  WebViewController.swift
//  Particle
//
//  Created by Ido on 6/2/15.
//  Copyright (c) 2015 Particle. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!

    var loadFramesCount : Int = 0
    var loading : Bool = false

    var link : URL? = nil
    var linkTitle : String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.topItem?.title = self.linkTitle
        self.navBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Gotham-Book", size: 17)!, NSAttributedString.Key.foregroundColor: ParticleUtils.particleGrayColor]
        
        
        let request = URLRequest(url: self.link!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15.0)
        self.webView.loadRequest(request)
        
        self.webView.scalesPageToFit = true
        self.webView.delegate = self;
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        ParticleSpinner.hide(self.view)
        self.loading = false
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        if !self.loading {
            self.loading = true
            ParticleSpinner.show(self.view)
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ParticleSpinner.hide(self.view)
        self.loading = false

        let contentSize = self.webView.scrollView.contentSize;
        let viewSize = self.view.bounds.size;
        
        let rw = viewSize.width / contentSize.width;
        
        self.webView.scrollView.minimumZoomScale = rw;
        self.webView.scrollView.maximumZoomScale = rw;
        self.webView.scrollView.zoomScale = rw;
    }

    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
