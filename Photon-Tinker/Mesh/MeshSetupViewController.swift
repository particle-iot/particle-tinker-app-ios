//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let MeshSetupViewControllerBusyChanged = Notification.Name("io.particle.MeshSetupViewControllerBusyChanged")
}

class MeshSetupViewController: UIViewController, Fadeable {

    static var storyboardName: String {
        return "MeshSetup"
    }

    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint?
    @IBOutlet var buttonSideConstraints: [NSLayoutConstraint]?
    
    @IBOutlet var constraintsToShrinkOnSmallScreens: [NSLayoutConstraint]?

    private var bottomConstraintConstant: CGFloat?
    private var sideConstraintConstant: CGFloat?

    internal var deviceType: ParticleDeviceType?
    internal var networkName: String?
    internal var deviceName: String?

    @IBOutlet var viewsToFade:[UIView]?


    var customTitle: String {
        get {
            return ""
        }
    }

    var allowBack: Bool = true
    var ownerStepType: MeshSetupStep.Type?

    internal var isBusy: Bool = false {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.MeshSetupViewControllerBusyChanged, object: self)
        }
    }

    var viewControllerIsBusy: Bool {
        get {
            return isBusy
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setCommonStyle()
        setStyle()
    }

    private func setCommonStyle() {
        if (ScreenUtils.isIPhone() && (ScreenUtils.getPhoneScreenSizeClass() <= .iPhone5)) {
            if let constraints = constraintsToShrinkOnSmallScreens {
                for constraint in constraints {
                    constraint.constant = constraint.constant / 2
                }
            }
        }

        view.backgroundColor = ParticleStyle.ViewBackgroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let constraint = buttonBottomConstraint {
            bottomConstraintConstant = constraint.constant
        }

        if let sideConstraints = buttonSideConstraints, let constraint = sideConstraints.first {
            sideConstraintConstant = constraint.constant
        }

        setContent()
        replacePlaceHolderStrings()
    }

    func setStyle() {
        fatalError("Not implemented")
    }

    func setContent() {
        fatalError("Not implemented")
    }

    func replacePlaceHolderStrings() {
        view.replaceMeshSetupStrings(deviceType: self.deviceType?.description, networkName: networkName, deviceName: deviceName)
    }

    func resume(animated: Bool) {
        self.unfadeContent(animated: animated)
    }

    func fade(animated: Bool) {
        self.fadeContent(animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        //TODO: if we add ipad support, review this
        if (ScreenUtils.getPhoneScreenSizeClass() >= .iPhone5) {
            if let constraint = buttonBottomConstraint {
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    let keyboardHeight = keyboardSize.height

                    var safeAreaBottomMargin:CGFloat = 0
                    var safeAreaSideMargin:CGFloat = 0

                    if #available(iOS 11.0, *) {
                        safeAreaBottomMargin = view.safeAreaInsets.bottom
                        safeAreaSideMargin = max(view.safeAreaInsets.left, view.safeAreaInsets.right)
                    }
                    safeAreaSideMargin += 5 //to compensate rounded corners of the button

                    constraint.constant = keyboardSize.height - safeAreaBottomMargin - 1

                    if let sideConstraints = buttonSideConstraints {
                        for sideConstraint in sideConstraints {
                            sideConstraint.constant = -safeAreaSideMargin
                        }
                    }


                    UIView.animate(withDuration: 0.25) { () -> Void in
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        //TODO: if we add ipad support, review this
        //on iphone 4s, the button covers the input, so lets keep it snapped to the bottom of the screen.
        if (ScreenUtils.getPhoneScreenSizeClass() >= .iPhone5) {
            if let constraint = buttonBottomConstraint {
                constraint.constant = bottomConstraintConstant!

                if let sideConstraints = buttonSideConstraints {
                    for sideConstraint in sideConstraints {
                        sideConstraint.constant = sideConstraintConstant!
                    }
                }

                UIView.animate(withDuration: 0.25) { () -> Void in
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}
