//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class Gen3SetupGetReadyViewController: Gen3SetupViewController, Storyboardable {

    @IBOutlet weak var videoToButtonConstraint: NSLayoutConstraint?
    @IBOutlet weak var videoToCheckboxConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var checkboxView: UIView?
    @IBOutlet weak var checkboxButton: ParticleCheckBoxButton?
    @IBOutlet weak var checkboxLabel: ParticleLabel?
    
    internal var videoPlayer: AVPlayer?
    internal var layer: AVPlayerLayer?
    internal var ethernetVideo: AVPlayerItem?
    internal var defaultVideo : AVPlayerItem?

    internal var defaultVideoURL: URL!
    internal var ethernetVideoURL: URL!

    internal var isSOM:Bool!


    @IBOutlet weak var ethernetToggleBackground: UIView!
    
    @IBOutlet weak var titleLabel: ParticleLabel!
    @IBOutlet weak var videoView: UIControl!

    @IBOutlet weak var ethernetToggleTitle: ParticleLabel?
    @IBOutlet weak var ethernetToggleText: ParticleLabel?
    
    @IBOutlet weak var continueButton: ParticleButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        //so that constraints are properly disabled
        setContent()
    }

    private var callback: ((Bool) -> ())!
    private var dataMatrix: Gen3SetupDataMatrix!

    func setup(didPressReady: @escaping (Bool) -> (), dataMatrix: Gen3SetupDataMatrix) {
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

        ethernetToggleBackground.backgroundColor = ParticleStyle.EthernetToggleBackgroundColor
        continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)


        if (ScreenUtils.getPhoneScreenSizeClass() <= .iPhone5) {
            titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

            ethernetToggleTitle?.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.SmallSize, color: ParticleStyle.PrimaryTextColor)
            ethernetToggleText?.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.PrimaryTextColor)

            checkboxLabel?.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.PrimaryTextColor)
        } else {
            titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

            ethernetToggleTitle?.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
            ethernetToggleText?.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

            checkboxLabel?.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
        }
    }


    override func setContent() {
        setDefaultContent()

        continueButton.setTitle(Gen3SetupStrings.GetReady.Button, for: .normal)

        ethernetToggleTitle?.text = self.isSOM ? Gen3SetupStrings.GetReady.SOMEthernetToggleTitle : Gen3SetupStrings.GetReady.EthernetToggleTitle
        ethernetToggleText?.text = self.isSOM ? Gen3SetupStrings.GetReady.SOMEthernetToggleText : Gen3SetupStrings.GetReady.EthernetToggleText

        switch (self.deviceType ?? .xenon) {
            case .argon:
                initializeVideoPlayerWithVideo(videoFileName: "argon_power_on")

                checkboxLabel?.text = Gen3SetupStrings.GetReady.WifiCheckboxText
                checkboxView?.isHidden = false
            case .aSeries:
                initializeVideoPlayerWithVideo(videoFileName: "b_power_on") //a_power_on

                checkboxLabel?.text = Gen3SetupStrings.GetReady.SOMWifiCheckboxText
                checkboxView?.isHidden = false
            case .boron:
                if (ParticleDeviceType.requiresBattery(serialNumber: dataMatrix!.serialNumber)) {
                    initializeVideoPlayerWithVideo(videoFileName: "boron_power_on_battery")
                } else {
                    initializeVideoPlayerWithVideo(videoFileName: "boron_power_on")
                }

                checkboxLabel?.text = Gen3SetupStrings.GetReady.CellularCheckboxText
                checkboxView?.isHidden = false
            case .bSeries, .b5SoM:
                if (ParticleDeviceType.requiresBattery(serialNumber: dataMatrix!.serialNumber)) {
                    initializeVideoPlayerWithVideo(videoFileName: "b_power_on") //b_power_on_battery
                } else {
                    initializeVideoPlayerWithVideo(videoFileName: "b_power_on")
                }

                checkboxLabel?.text = Gen3SetupStrings.GetReady.SOMCellularCheckboxText
                checkboxView?.isHidden = false
            case .xSeries:
                initializeVideoPlayerWithVideo(videoFileName: "b_power_on") //x_power_on

                checkboxLabel?.text = Gen3SetupStrings.GetReady.SOMBluetoothCheckboxText
                checkboxView?.isHidden = false
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
        titleLabel.text = self.isSOM ? Gen3SetupStrings.GetReady.SOMTitle : Gen3SetupStrings.GetReady.Title

        replacePlaceHolderStrings()

        switch (self.deviceType ?? .xenon) {
            case .argon:
                checkboxLabel?.text = Gen3SetupStrings.GetReady.WifiCheckboxText
                checkboxView?.isHidden = false
            case .aSeries:
                checkboxLabel?.text = Gen3SetupStrings.GetReady.SOMWifiCheckboxText
                checkboxView?.isHidden = false
            case .boron:
                checkboxLabel?.text = Gen3SetupStrings.GetReady.CellularCheckboxText
                checkboxView?.isHidden = false
            case .bSeries:
                checkboxLabel?.text = Gen3SetupStrings.GetReady.SOMCellularCheckboxText
                checkboxView?.isHidden = false
            case .xSeries:
                checkboxLabel?.text = Gen3SetupStrings.GetReady.SOMBluetoothCheckboxText
                checkboxView?.isHidden = false
            default: //.xenon
                checkboxView?.isHidden = true
        }
    }

    private func setEthernetContent() {
        titleLabel.text = self.isSOM ? Gen3SetupStrings.GetReady.SOMEthernetTitle : Gen3SetupStrings.GetReady.EthernetTitle

        replacePlaceHolderStrings()

        switch (self.deviceType ?? .xenon) {
            case .aSeries, .bSeries, .xSeries:
                checkboxLabel?.text = Gen3SetupStrings.GetReady.SOMBluetoothCheckboxText
                checkboxView?.isHidden = false
            default:
                checkboxView?.isHidden = true
        }

    }


    @IBAction func checkboxTapped(_ sender: ParticleCheckBoxButton) {
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
        var ethernetVideoString:String? = Bundle.main.path(forResource: "ethernet_power_on", ofType: "mov")
        if (self.isSOM) {
            ethernetVideoString = Bundle.main.path(forResource: "som_ethernet_power_on", ofType: "mov")
        }

        ethernetVideoURL = URL(fileURLWithPath: ethernetVideoString!)
        ethernetVideo = AVPlayerItem(url: ethernetVideoURL)

        let defaultVideoString:String? = Bundle.main.path(forResource: videoFileName, ofType: "mov")
        defaultVideoURL = URL(fileURLWithPath: defaultVideoString!)
        defaultVideo = AVPlayerItem(url: defaultVideoURL)
        
        self.videoPlayer = AVPlayer(playerItem: defaultVideo)
        layer = AVPlayerLayer(player: videoPlayer)
        layer!.frame = videoView.bounds
        layer!.videoGravity = AVLayerVideoGravity.resizeAspect

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
            self.videoPlayer?.seek(to: CMTime.zero)
            self.videoPlayer?.play()
        }

        self.videoPlayer?.seek(to: CMTime.zero)
        self.videoPlayer?.play()
    }
    
}
