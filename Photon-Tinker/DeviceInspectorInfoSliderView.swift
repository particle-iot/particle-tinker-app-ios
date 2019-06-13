//
// Created by Raimundas Sakalauskas on 2019-06-06.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInspectorInfoSliderView: UIView, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var yConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collapsedContent: UIView!
    @IBOutlet weak var collapsedDeviceImageView: UIImageView!
    @IBOutlet weak var collapsedDeviceStateImageView: UIImageView!
    @IBOutlet weak var collapsedDeviceNameLabel: MeshLabel!
    @IBOutlet weak var collapsedDeviceTypeLabel: MeshLabel!
    @IBOutlet weak var collapsedDeviceIconImage: DeviceTypeIcon!
    
    
    @IBOutlet weak var expandedContent: UIView!
    @IBOutlet weak var expandedDeviceImageView: UIImageView!
    @IBOutlet weak var expandedDeviceImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandedDeviceStateImageView: UIImageView!
    @IBOutlet weak var expandedDeviceNameLabel: MeshLabel!
    @IBOutlet weak var expandedDeviceStateLabel: MeshLabel!
    @IBOutlet weak var expandedDeviceSignalLabel: MeshLabel!
    @IBOutlet weak var expandedTableView: UITableView!
    @IBOutlet weak var expandedTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandedDeviceNotesTitleLabel: MeshLabel!
    @IBOutlet weak var expandedDeviceNotesLabel: MeshLabel!
    @IBOutlet weak var expandedPingButton: MeshSetupAlternativeButton!
    @IBOutlet weak var expandedPingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var expandedSignalToggle: UISwitch!
    
    @IBOutlet var constraintsToShrinkOnSmallScreens: [NSLayoutConstraint]?

    
    let contentSwitchDistanceInPixels: CGFloat = 180
    let contentSwitchDelayInPixels: CGFloat = 100

    var device: ParticleDevice!
    var collapsedPosConstraint: CGFloat!
    var collapsedPosFrame: CGFloat!


    var panGestureRecognizer: UIPanGestureRecognizer!
    var startY: CGFloat = 0
    var collapsed: Bool = true
    var animating: Bool = false
    var beingDragged: Bool = false
    var displayLink: CADisplayLink!

    var details: [String: Any]!
    var detailsOrder: [String]!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(_ device: ParticleDevice!) {
        self.device = device
        self.details = device.getInfoDetails()
        self.detailsOrder = device.getInfoDetailsOrder()
        internalInit()
    }

    private func internalInit() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(rgb: 0xD9D8D6).cgColor

        self.adjustConstraintPositions()
        self.yConstraint.constant = collapsedPosConstraint

        self.setStyle()
        self.setContent()

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureTriggered))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.isEnabled = true
        self.addGestureRecognizer(panGestureRecognizer)
    }

    private func setContent() {
        self.collapsedDeviceImageView.image = self.device.type.getImage()
        self.collapsedDeviceNameLabel.text = self.device.getName()
        self.collapsedDeviceIconImage.setDeviceType(self.device.type)
        self.collapsedDeviceTypeLabel.text = self.device.type.description

        self.expandedDeviceImageView.image = self.device.type.getImage()
        self.expandedDeviceNameLabel.text = self.device.getName()
        self.expandedDeviceStateLabel.text = self.device.isFlashing ? "Flashing" : (self.device.connected ? "Online" : "Offline")
        self.expandedDeviceSignalLabel.text = "Signal Device"
        self.expandedDeviceNotesTitleLabel.text = "Notes"
        self.expandedDeviceNotesLabel.text = self.device.notes ?? "Use this space to keep notes on this device. Add or edit them."

        self.expandedPingButton.setTitle("Ping", for: .normal, upperCase: false)

        self.expandedTableViewHeightConstraint.constant = CGFloat(self.detailsOrder.count * 30)

        ParticleUtils.animateOnlineIndicatorImageView(self.collapsedDeviceStateImageView, online: self.device.connected, flashing: self.device.isFlashing)
        ParticleUtils.animateOnlineIndicatorImageView(self.expandedDeviceStateImageView, online: self.device.connected, flashing: self.device.isFlashing)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsOrder.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceInfoSliderCell") as! DeviceInfoSliderCell
        let key = detailsOrder[indexPath.row]
        cell.setup(title: key, value: details[key])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DeviceInfoSliderCell
        tableView.deselectRow(at: indexPath, animated: true)

        UIPasteboard.general.string = cell.valueLabel.text!
        RMessage.dismissActiveNotification()
        RMessage.showNotification(withTitle: "Copied", subtitle: "\(cell.titleLabel.text!) value was copied to the clipboard", type: .success, customTypeName: nil, callback: nil)
    }

    private func setStyle() {
        if (MeshScreenUtils.isIPhone() && (MeshScreenUtils.getPhoneScreenSizeClass() <= .iPhone5)) {
            if let constraints = constraintsToShrinkOnSmallScreens {
                self.expandedDeviceImageViewHeightConstraint.constant = 120
                for constraint in constraints {
                    constraint.constant = constraint.constant / 2
                }
            }
        }

        self.expandedTableView.separatorColor = .clear

        self.collapsedDeviceNameLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        self.collapsedDeviceTypeLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        self.expandedDeviceNameLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        self.expandedDeviceStateLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        self.expandedDeviceSignalLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

        self.expandedDeviceNotesTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        self.expandedDeviceNotesLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.DetailsTextColor)

        self.expandedPingButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
        self.expandedPingButton.layer.shadowColor = UIColor.clear.cgColor
        self.expandedPingButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

        self.expandedPingActivityIndicator.hidesWhenStopped = true
    }

    func update() {
        self.setContent()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.adjustConstraintPositions()

        //if safe area insets change during idle state
        if !animating && !beingDragged {
            if (self.yConstraint.constant > 0) {
                self.yConstraint.constant = collapsedPosConstraint
            }
        }

        let progress = min(self.contentSwitchDistanceInPixels, self.collapsedPosFrame - self.frame.origin.y - self.contentSwitchDelayInPixels) / self.contentSwitchDistanceInPixels
        updateState(progress: progress)
    }

    private func updateState(progress: CGFloat) {
        self.layer.cornerRadius = 10 * progress

        self.collapsedContent.alpha = 1 - progress
        self.expandedContent.alpha = progress
    }


    private func adjustConstraintPositions() {
        collapsedPosConstraint = UIScreen.main.bounds.height - 100
        collapsedPosFrame = collapsedPosConstraint
        if #available(iOS 11, *), let superview = self.superview {
            self.heightConstraint.constant = self.safeAreaInsets.bottom + 11

            collapsedPosConstraint! -= (superview.safeAreaInsets.bottom + superview.safeAreaInsets.top)
            collapsedPosFrame = collapsedPosConstraint + superview.safeAreaInsets.top
        }
    }


    @objc
    func panGestureTriggered(_ recognizer:UIPanGestureRecognizer) {
        switch (recognizer.state) {
            case.began:
                self.beingDragged = true
                let pos = recognizer.translation(in: self)
                self.startY = yConstraint.constant
            case .changed:
                let change = recognizer.translation(in: self)

                var offset = startY + change.y
                if (offset >= collapsedPosConstraint) {
                    //if we reach end of motion, move initial offset so that when user
                    //starts scrolling in different direction he gets instant feedback
                    self.startY = collapsedPosConstraint - change.y
                    offset = collapsedPosConstraint
                } else if (offset <= 0) {
                    //if we reach end of motion, move initial offset so that when user
                    //starts scrolling in different direction he gets instant feedback
                    self.startY = 0 - change.y
                    offset = 0
                }

                yConstraint.constant = offset
                self.layoutSubviews()
            case .failed:
                fallthrough
            case.cancelled:
                fallthrough
            case .ended:
                self.beingDragged = false

                let change = recognizer.translation(in: self)
                let velocity = recognizer.velocity(in: self)

                if (collapsed) {
                    if (-1 * change.y > collapsedPosConstraint / 4) || (-1 * (change.y + velocity.y) > collapsedPosConstraint) {
                        expand()
                    } else {
                        collapse()
                    }
                } else {
                    if (change.y > collapsedPosConstraint / 4) || ((change.y + velocity.y) > collapsedPosConstraint) {
                        collapse()
                    } else {
                        expand()
                    }
                }

            case.possible:
                //do nothing
                break
        }
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !animating
    }


    @IBAction func expandTapped(_ sender: Any) {
        if collapsed && !animating && !beingDragged {
            self.expand()
        }
    }
    
    func expand() {
        animating = true

        self.superview?.layoutIfNeeded()
        let duration:Double = Double(self.yConstraint.constant / self.collapsedPosConstraint * 0.25)
        self.yConstraint.constant = 0

        animateStateChange(duration: duration, collapsed: false)
    }

    @IBAction func collapseTapped(_ sender: Any) {
        if !collapsed && !animating && !beingDragged {
            self.collapse()
        }
    }
    
    func collapse() {
        animating = true

        self.device.signal(false)
        self.expandedSignalToggle.setOn(false, animated: true)

        self.superview?.layoutIfNeeded()
        let duration:Double = Double((self.collapsedPosConstraint - self.yConstraint.constant) / self.collapsedPosConstraint * 0.25)
        self.yConstraint.constant = self.collapsedPosConstraint

        animateStateChange(duration: duration, collapsed: true)
    }

    private func animateStateChange(duration: Double, collapsed: Bool) {
        displayLink = CADisplayLink(target: self, selector: #selector(animationDidUpdate))
        displayLink.add(to: .main, forMode: .defaultRunLoopMode)

        UIView.animate(withDuration: duration, delay:0, options:.curveEaseOut, animations: { () -> Void in
            self.superview?.layoutIfNeeded()
        }, completion: { [weak self] b in
            self?.displayLink.invalidate()
            self?.displayLink = nil
            self?.animating = false
            self?.collapsed = collapsed
        })
    }

    @objc func animationDidUpdate(displayLink: CADisplayLink) {
        let presentationLayer = self.layer.presentation() as! CALayer

        let progress = min(self.contentSwitchDistanceInPixels, self.collapsedPosFrame - presentationLayer.frame.origin.y - self.contentSwitchDelayInPixels) / self.contentSwitchDistanceInPixels
        self.updateState(progress: progress)
    }

    @IBAction func signalSwitchValueChanged(_ sender: Any) {
        if expandedSignalToggle.isOn {
            self.device.signal(true)
        } else {
            self.device.signal(false)
        }
    }

    @IBAction func pingButtonTapped(_ sender: Any) {
        self.expandedPingActivityIndicator.startAnimating()
        self.expandedPingButton.isHidden = true

        RMessage.dismissActiveNotification()
        RMessage.showNotification(withTitle: "Pinging device", subtitle: "The Particle Cloud has sent a ping to this device. It will wait up to 15 seconds to hear back.", type: .warning, customTypeName: nil, callback: nil)

        self.device.ping { [weak self] connected, error in
            if let self = self {
                DispatchQueue.main.async {
                    self.expandedPingActivityIndicator.stopAnimating()
                    self.expandedPingButton.isHidden = false
                }
            }

            if error != nil || !connected {
                RMessage.dismissActiveNotification()
                RMessage.showNotification(withTitle: "Error", subtitle: "This device was unreachable by the Particle cloud within 15 seconds. The device may be powered off, or may be having trouble connecting to the Particle Cloud.", type: .error, customTypeName: nil, callback: nil)
            } else {
                RMessage.dismissActiveNotification()
                RMessage.showNotification(withTitle: "Success", subtitle: "This device is online and connected!", type: .success, customTypeName: nil, callback: nil)
            }
        }
    }

}
