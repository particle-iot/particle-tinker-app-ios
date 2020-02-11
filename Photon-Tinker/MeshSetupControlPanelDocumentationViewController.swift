//
//  WebViewController.swift
//  Particle
//
//  Copyright (c) 2019 Particle. All rights reserved.
//

import UIKit
import WebKit

class MeshSetupControlPanelDocumentationViewController: MeshSetupViewController, WKNavigationDelegate, Storyboardable {

    @IBOutlet weak var webView: WKWebView!
    var url: URL!

    var loadFramesCount : Int = 0
    var loading : Bool = false

    override func setStyle() {
        //do nothing
    }

    override func setContent() {
        //do nothing
    }

    override var customTitle: String {
        return Gen3SetupStrings.ControlPanel.Documentation.Title
    }

    func setup(_ device: ParticleDevice!) {
        switch device.type {
            case .argon, .aSeries:
                self.url = URL(string: "https://docs.particle.io/argon/")
            case .boron, .bSeries, .b5SoM:
                self.url = URL(string: "https://docs.particle.io/boron/")
            case .xenon, .xSeries:
                self.url = URL(string: "https://docs.particle.io/xenon/")
            case .photon, .P1:
                self.url = URL(string: "https://docs.particle.io/photon/")            
            case .electron:
                self.url = URL(string: "https://docs.particle.io/electron/")
            default:
                self.url = URL(string: "https://docs.particle.io/electron/")
        }
    }

    override func loadView() {
        super.loadView()

        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)

        webView.navigationDelegate = self

        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = URLRequest(url: self.url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15.0)
        self.webView.load(request)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loading = true
        ParticleSpinner.show(self.view)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ParticleSpinner.hide(self.view)
        self.loading = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ParticleSpinner.hide(self.view)
        self.loading = false
    }



}
