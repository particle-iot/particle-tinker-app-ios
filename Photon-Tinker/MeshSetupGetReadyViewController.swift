//
//  MeshSetupGetReadyViewController.swift
//  Particle Mesh
//
//  Created by Ido Kleinman on 6/18/18.
//  Copyright © 2018 Nordic Semiconductor. All rights reserved.
//

import UIKit
import AVFoundation


class MeshSetupGetReadyViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var videoView: UIView!
    var videoPlayer: AVPlayer?
    
    @IBOutlet weak var textLabel1: MeshLabel!
    @IBOutlet weak var textLabel2: MeshLabel!
    @IBOutlet weak var textLabel3: MeshLabel!
    
    @IBOutlet weak var continueButton: MeshSetupButton!
    
    internal var callback: (() -> ())!
    
    func setup(didPressReady: @escaping () -> (), deviceType: ParticleDeviceType?) {
        self.callback = didPressReady
        self.deviceType = deviceType
    }

    override func setStyle() {
        videoView.backgroundColor = MeshSetupStyle.VideoBackgroundColor
        videoView.layer.cornerRadius = 5
        videoView.clipsToBounds = true

        titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel1.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel2.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel3.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.ButtonTitleColor)
    }


    override func setContent() {
        titleLabel.text = MeshSetupStrings.GetReady.Title
        textLabel1.text = MeshSetupStrings.GetReady.Text1
        textLabel2.text = MeshSetupStrings.GetReady.Text2
        textLabel3.text = MeshSetupStrings.GetReady.Text3

        continueButton.setTitle(MeshSetupStrings.GetReady.Button, for: .normal)
        
        initializeVideoPlayerWithVideo(videoFileName: "xenon_power_on")

    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        callback()
    }

    func initializeVideoPlayerWithVideo(videoFileName : String?) {
        
        // get the path string for the video from assets
        let videoString:String? = Bundle.main.path(forResource: videoFileName, ofType: "mp4")
        guard let unwrappedVideoPath = videoString else {return}
        let videoUrl = URL(fileURLWithPath: unwrappedVideoPath)
        self.videoPlayer = AVPlayer(url: videoUrl)
        let layer: AVPlayerLayer = AVPlayerLayer(player: videoPlayer)
        layer.frame = videoView.bounds
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.addSublayer(layer)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.videoPlayer?.currentItem, queue: .main) { _ in
            self.videoPlayer?.seek(to: kCMTimeZero)
            self.videoPlayer?.play()
        }
        
        videoPlayer?.play()
    }
    
}
