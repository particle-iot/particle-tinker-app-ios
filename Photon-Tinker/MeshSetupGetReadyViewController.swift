//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import AVFoundation


class MeshSetupGetReadyViewController: MeshSetupViewController, Storyboardable {
    @IBOutlet weak var gatewayTitleLabel: MeshLabel!
    
    @IBOutlet weak var gatewayTextLabel1: MeshLabel!
    @IBOutlet weak var gatewayTextLabel2: MeshLabel!
    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var videoView: UIView!
    internal var videoPlayer: AVPlayer?
    
    @IBOutlet weak var gatewayTextLabel3: MeshLabel!
    @IBOutlet weak var gatewayTextLabel4: MeshLabel!
    @IBOutlet weak var textLabel1: MeshLabel!
    @IBOutlet weak var textLabel2: MeshLabel!
    @IBOutlet weak var textLabel3: MeshLabel!
    
    @IBOutlet weak var joinerView: UIView!
    @IBOutlet weak var continueButton: MeshSetupButton!
    
    internal var gatewayVideo : AVPlayerItem?
    internal var defaultVideo : AVPlayerItem?
    
    @IBOutlet weak var gatewayView: UIView!
    internal var callback: (() -> ())!
    
    func setup(didPressReady: @escaping () -> (), deviceType: ParticleDeviceType?) {
        self.callback = didPressReady
        self.deviceType = deviceType
    }
    @IBOutlet weak var setupSwitch: UISwitch!
    
    @IBAction func setupSwitchChanged(_ sender: Any) {
        if self.setupSwitch.isOn {
//            initializeVideoPlayerWithVideo(videoFileName: "ethernet_featherwing_power_on")
            self.videoPlayer?.replaceCurrentItem(with: gatewayVideo)
            self.gatewayView.isHidden = false
            self.joinerView.isHidden = true
        } else {
//            initializeVideoPlayerWithVideo(videoFileName: "xenon_power_on")
            self.videoPlayer?.replaceCurrentItem(with: defaultVideo)
            self.gatewayView.isHidden = true
            self.joinerView.isHidden = false
        }
        setVideoLoopObserver()

    }
    
    override func setStyle() {
        videoView.backgroundColor = MeshSetupStyle.VideoBackgroundColor
        videoView.layer.cornerRadius = 5
        videoView.clipsToBounds = true

        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel2.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel3.isHidden = true
        
        gatewayTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        gatewayTextLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        gatewayTextLabel2.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        gatewayTextLabel3.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        gatewayTextLabel4.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)
    }


    override func setContent() {
        titleLabel.text = MeshSetupStrings.GetReady.Title
        textLabel1.text = MeshSetupStrings.GetReady.Text1
        textLabel2.text = MeshSetupStrings.GetReady.Text2
//        textLabel3.text = MeshSetupStrings.GetReady.Text3

        continueButton.setTitle(MeshSetupStrings.GetReady.Button, for: .normal)
        
        initializeVideoPlayerWithVideo(videoFileName: "xenon_power_on")
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        callback()
    }

    func initializeVideoPlayerWithVideo(videoFileName : String?) {
        
//        desetVideoLoopObserver()
        
        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        let gatewayVideoString:String? = Bundle.main.path(forResource: "ethernet_featherwing_power_on", ofType: "mp4")
        let gatewayVideoUrl = URL(fileURLWithPath: gatewayVideoString!)
        gatewayVideo = AVPlayerItem(url: gatewayVideoUrl)

        let defaultVideoString:String? = Bundle.main.path(forResource: videoFileName, ofType: "mp4")
        let defaultVideoUrl = URL(fileURLWithPath: defaultVideoString!)
        defaultVideo = AVPlayerItem(url: defaultVideoUrl)
        
        
        // get the path string for the video from assets

//        guard let unwrappedVideoPath = videoString else {return}
//        let videoUrl = URL(fileURLWithPath: unwrappedVideoPath)
//        self.videoPlayer = AVPlayer(url: videoUrl)
        self.videoPlayer = AVPlayer(playerItem: defaultVideo)
        let layer: AVPlayerLayer = AVPlayerLayer(player: videoPlayer)
        layer.frame = videoView.bounds
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.addSublayer(layer)
        setVideoLoopObserver()
        videoPlayer?.play()
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
