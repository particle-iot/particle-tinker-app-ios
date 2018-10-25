//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import AVFoundation


class MeshSetupGetReadyViewController: MeshSetupViewController, Storyboardable {

    internal var videoPlayer: AVPlayer?
    internal var layer: AVPlayerLayer?
    internal var gatewayVideo : AVPlayerItem?
    internal var defaultVideo : AVPlayerItem?

    @IBOutlet weak var ethernetToggleBackground: UIView!
    
    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var textLabel1: MeshLabel!
    @IBOutlet weak var textLabel2: MeshLabel!
    @IBOutlet weak var textLabel3: MeshLabel!
    @IBOutlet weak var textLabel4: MeshLabel!
    
    @IBOutlet weak var ethernetToggleTitle: MeshLabel?
    @IBOutlet weak var ethernetToggleText: MeshLabel?
    
    @IBOutlet weak var continueButton: MeshSetupButton!
    //@IBOutlet weak var contentStackView: UIStackView!
    
    
    private var callback: ((Bool) -> ())!
    
    func setup(didPressReady: @escaping (Bool) -> (), deviceType: ParticleDeviceType?) {
        self.callback = didPressReady
        self.deviceType = deviceType
    }
    @IBOutlet weak var setupSwitch: UISwitch!
    
    @IBAction func setupSwitchChanged(_ sender: Any) {
        continueButton.isUserInteractionEnabled = false
        //contentStackView.alpha = 0
        titleLabel.alpha = 0
        videoView.alpha = 0
        setViewContent()
    }

    private func setViewContent() {
        if self.setupSwitch.isOn {
            setEthernetContent()
            self.videoPlayer?.replaceCurrentItem(with: gatewayVideo)
        } else {
            setDefaultContent()
            self.videoPlayer?.replaceCurrentItem(with: defaultVideo)
        }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.125, delay: 0.125, options: [], animations: { () -> Void in
            //self.contentStackView.alpha = 1
            self.titleLabel.alpha = 1
            self.videoView.alpha = 1
        }, completion: { completed in
            self.continueButton.isUserInteractionEnabled = true
        })
    }

    override func setStyle() {
        videoView.backgroundColor = .clear
        videoView.layer.cornerRadius = 5
        videoView.clipsToBounds = true

        ethernetToggleBackground.backgroundColor = MeshSetupStyle.EthernetToggleBackgroundColor
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)


        if (MeshScreenUtils.getPhoneScreenSizeClass() <= .iPhone5) {
            //contentStackView.spacing = 15

            titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

            textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
            textLabel2.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
            textLabel3.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
            textLabel4.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)


            ethernetToggleTitle?.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
            ethernetToggleText?.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
        } else {
            //contentStackView.spacing = 20

            titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

            textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
            textLabel2.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
            textLabel3.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
            textLabel4.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

            ethernetToggleTitle?.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
            ethernetToggleText?.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        }
    }


    override func setContent() {
        setDefaultContent()

        continueButton.setTitle(MeshSetupStrings.GetReady.Button, for: .normal)

        ethernetToggleTitle?.text = MeshSetupStrings.GetReady.EthernetToggleTitle
        ethernetToggleText?.text = MeshSetupStrings.GetReady.EthernetToggleText

        switch (self.deviceType!) {
            case .xenon:
                initializeVideoPlayerWithVideo(videoFileName: "xenon_power_on")
            case .argon:
                initializeVideoPlayerWithVideo(videoFileName: "argon_power_on")
            case .boron:
                initializeVideoPlayerWithVideo(videoFileName: "boron_power_on")
            default:
                //do nothing
                break
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func setDefaultContent() {
        titleLabel.text = MeshSetupStrings.GetReady.Title
//        textLabel1.text = MeshSetupStrings.GetReady.Text1
//        textLabel2.text = MeshSetupStrings.GetReady.Text2
//        textLabel3.text = MeshSetupStrings.GetReady.Text3
//        textLabel4.text = MeshSetupStrings.GetReady.Text4

        replacePlaceHolderStrings()
//        hideEmptyLabels()
    }

    private func setEthernetContent() {
        titleLabel.text = MeshSetupStrings.GetReady.EthernetTitle
//        textLabel1.text = MeshSetupStrings.GetReady.EthernetText1
//        textLabel2.text = MeshSetupStrings.GetReady.EthernetText2
//        textLabel3.text = MeshSetupStrings.GetReady.EthernetText3
//        textLabel4.text = MeshSetupStrings.GetReady.EthernetText4

        replacePlaceHolderStrings()
//        hideEmptyLabels()
    }


//    internal func hideEmptyLabels() {
//        textLabel1.isHidden = (textLabel1.text?.count ?? 0) == 0
//        textLabel2.isHidden = (textLabel2.text?.count ?? 0) == 0
//        textLabel3.isHidden = (textLabel3.text?.count ?? 0) == 0
//        textLabel4.isHidden = (textLabel4.text?.count ?? 0) == 0
//    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        callback(self.setupSwitch.isOn)
    }

    func initializeVideoPlayerWithVideo(videoFileName: String) {
        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        let gatewayVideoString:String? = Bundle.main.path(forResource: "featherwing_power_on", ofType: "mov")
        let gatewayVideoUrl = URL(fileURLWithPath: gatewayVideoString!)
        gatewayVideo = AVPlayerItem(url: gatewayVideoUrl)

        let defaultVideoString:String? = Bundle.main.path(forResource: videoFileName, ofType: "mov")
        let defaultVideoUrl = URL(fileURLWithPath: defaultVideoString!)
        defaultVideo = AVPlayerItem(url: defaultVideoUrl)
        
        self.videoPlayer = AVPlayer(playerItem: defaultVideo)
        layer = AVPlayerLayer(player: videoPlayer)
        layer!.frame = videoView.bounds
        layer!.videoGravity = AVLayerVideoGravity.resizeAspect

        videoView.layer.addSublayer(layer!)
        setVideoLoopObserver()
        videoPlayer?.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layer?.frame = videoView.bounds
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        desetVideoLoopObserver()
    }

    func desetVideoLoopObserver() {
        NotificationCenter.default.removeObserver(self.videoPlayer?.currentItem)
    }
    
    func setVideoLoopObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.videoPlayer?.currentItem, queue: .main) { _ in
            self.videoPlayer?.seek(to: kCMTimeZero)
            self.videoPlayer?.play()
        }
    }
    
}
