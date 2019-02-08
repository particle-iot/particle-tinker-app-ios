//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class MeshSetupGetReadyViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var videoToButtonConstraint: NSLayoutConstraint?
    @IBOutlet weak var videoToCheckboxConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var checkboxView: UIView?
    @IBOutlet weak var checkboxButton: MeshCheckBoxButton?
    @IBOutlet weak var checkboxLabel: MeshLabel?
    
    internal var videoPlayer: AVPlayer?
    internal var layer: AVPlayerLayer?
    internal var ethernetVideo: AVPlayerItem?
    internal var defaultVideo : AVPlayerItem?

    internal var defaultVideoURL: URL!
    internal var ethernetVideoURL: URL!

    internal var isSOM:Bool!


    @IBOutlet weak var ethernetToggleBackground: UIView!
    
    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var videoView: UIControl!

    @IBOutlet weak var ethernetToggleTitle: MeshLabel?
    @IBOutlet weak var ethernetToggleText: MeshLabel?
    
    @IBOutlet weak var continueButton: MeshSetupButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        //so that constraints are properly disabled
        setContent()
    }

    private var callback: ((Bool) -> ())!
    private var dataMatrix: MeshSetupDataMatrix!

    func setup(didPressReady: @escaping (Bool) -> (), dataMatrix: MeshSetupDataMatrix) {
        self.callback = didPressReady
        self.dataMatrix = dataMatrix
        self.deviceType = dataMatrix.type

        if (self.deviceType != nil) {
            self.isSOM = (self.deviceType! == ParticleDeviceType.aSeries || self.deviceType! == ParticleDeviceType.bSeries || self.deviceType! == ParticleDeviceType.xSeries)
        } else {
            self.isSOM = false
        }
    }
    @IBOutlet weak var setupSwitch: UISwitch?
    
    @IBAction func setupSwitchChanged(_ sender: Any) {
        continueButton.isUserInteractionEnabled = false
        titleLabel.alpha = 0
        videoView.alpha = 0

        setViewContent()
    }

    private func setViewContent() {
        if self.setupSwitch!.isOn {
            setEthernetContent()
            self.videoPlayer?.replaceCurrentItem(with: ethernetVideo)
        } else {
            setDefaultContent()
            self.videoPlayer?.replaceCurrentItem(with: defaultVideo)
        }

        if let checkbox = checkboxView, checkbox.isHidden {
            self.videoToCheckboxConstraint?.isActive = false
            self.videoToButtonConstraint?.isActive = true
        } else {
            self.videoToCheckboxConstraint?.isActive = true
            self.videoToButtonConstraint?.isActive = false
        }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.125, delay: 0.125, options: [], animations: { () -> Void in
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
            titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

            ethernetToggleTitle?.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
            ethernetToggleText?.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)

            checkboxLabel?.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
        } else {
            titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

            ethernetToggleTitle?.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
            ethernetToggleText?.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

            checkboxLabel?.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        }
    }


    override func setContent() {
        setDefaultContent()

        continueButton.setTitle(MeshSetupStrings.GetReady.Button, for: .normal)

        ethernetToggleTitle?.text = self.isSOM ? MeshSetupStrings.GetReady.SOMEthernetToggleTitle : MeshSetupStrings.GetReady.EthernetToggleTitle
        ethernetToggleText?.text = self.isSOM ? MeshSetupStrings.GetReady.SOMEthernetToggleText : MeshSetupStrings.GetReady.EthernetToggleText

        switch (self.deviceType ?? .xenon) {
            case .argon:
                initializeVideoPlayerWithVideo(videoFileName: "argon_power_on")

                checkboxLabel?.text = MeshSetupStrings.GetReady.WifiCheckboxText
                checkboxView?.isHidden = false
            case .aSeries:
                initializeVideoPlayerWithVideo(videoFileName: "a_power_on")

                checkboxLabel?.text = MeshSetupStrings.GetReady.SOMWifiCheckboxText
                checkboxView?.isHidden = false
            case .boron:
                if (ParticleDeviceType.requiresBattery(serialNumber: dataMatrix!.serialNumber)) {
                    initializeVideoPlayerWithVideo(videoFileName: "boron_power_on_battery")
                } else {
                    initializeVideoPlayerWithVideo(videoFileName: "boron_power_on")
                }

                checkboxLabel?.text = MeshSetupStrings.GetReady.CellularCheckboxText
                checkboxView?.isHidden = false
            case .bSeries:
                if (ParticleDeviceType.requiresBattery(serialNumber: dataMatrix!.serialNumber)) {
                    initializeVideoPlayerWithVideo(videoFileName: "b_power_on_battery")
                } else {
                    initializeVideoPlayerWithVideo(videoFileName: "b_power_on")
                }

                checkboxLabel?.text = MeshSetupStrings.GetReady.SOMCellularCheckboxText
                checkboxView?.isHidden = false
            case .xSeries:
                initializeVideoPlayerWithVideo(videoFileName: "x_power_on")
                checkboxView?.isHidden = true
            default: //.xenon
                initializeVideoPlayerWithVideo(videoFileName: "xenon_power_on")

                checkboxView?.isHidden = true
        }

        if let checkbox = checkboxView, checkbox.isHidden {
            self.videoToCheckboxConstraint?.isActive = false
            self.videoToButtonConstraint?.isActive = true
        } else {
            self.videoToCheckboxConstraint?.isActive = true
            self.videoToButtonConstraint?.isActive = false
        }

        videoView.addTarget(self, action: #selector(videoViewTapped), for: .touchUpInside)

        NSLog("setting content")
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    @objc public func videoViewTapped(sender: UIControl) {
        let player = AVPlayer(url: (self.setupSwitch?.isOn ?? false) ? ethernetVideoURL : defaultVideoURL)

        let playerController = AVPlayerViewController()
        playerController.player = player

        present(playerController, animated: true) {
            player.play()
        }
    }

    private func setDefaultContent() {
        titleLabel.text = self.isSOM ? MeshSetupStrings.GetReady.SOMTitle : MeshSetupStrings.GetReady.Title

        replacePlaceHolderStrings()

        switch (self.deviceType ?? .xenon) {
            case .argon, .aSeries:
                checkboxView?.isHidden = false
            case .boron, .bSeries:
                checkboxView?.isHidden = false
            default: //.xenon
                checkboxView?.isHidden = true
        }

        NSLog("setting default content")
    }

    private func setEthernetContent() {
        titleLabel.text = self.isSOM ? MeshSetupStrings.GetReady.SOMEthernetTitle : MeshSetupStrings.GetReady.EthernetTitle

        replacePlaceHolderStrings()
        checkboxView?.isHidden = true
    }


    @IBAction func checkboxTapped(_ sender: MeshCheckBoxButton) {
        sender.isSelected = !sender.isSelected
    }
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if let checkbox = self.checkboxButton, let checkBoxView = self.checkboxView, checkBoxView.isHidden == false {
            if checkbox.isSelected {
                callback(self.setupSwitch!.isOn)
            } else {
                self.checkboxView?.shake()
            }
        } else {
            callback(self.setupSwitch!.isOn)
        }
    }

    func initializeVideoPlayerWithVideo(videoFileName: String) {
        if (self.videoPlayer != nil) {
            return
        }

        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        let ethernetVideoString:String? = Bundle.main.path(forResource: "featherwing_power_on", ofType: "mov")
        ethernetVideoURL = URL(fileURLWithPath: ethernetVideoString!)
        ethernetVideo = AVPlayerItem(url: ethernetVideoURL)

        let defaultVideoString:String? = Bundle.main.path(forResource: videoFileName, ofType: "mov")
        defaultVideoURL = URL(fileURLWithPath: defaultVideoString!)
        defaultVideo = AVPlayerItem(url: defaultVideoURL)
        
        self.videoPlayer = AVPlayer(playerItem: defaultVideo)
        layer = AVPlayerLayer(player: videoPlayer)
        layer!.frame = videoView.bounds
        layer!.videoGravity = AVLayerVideoGravity.resizeAspect

        NSLog("initializing layer?")
        videoView.layer.addSublayer(layer!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setVideoLoopObserver()
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
        self.videoPlayer?.pause()
        NotificationCenter.default.removeObserver(self.videoPlayer?.currentItem)
    }
    
    func setVideoLoopObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.videoPlayer?.currentItem, queue: .main) { _ in
            self.videoPlayer?.seek(to: kCMTimeZero)
            self.videoPlayer?.play()
        }

        self.videoPlayer?.seek(to: kCMTimeZero)
        self.videoPlayer?.play()
    }
    
}
