//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupViewController: UIViewController {

    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint?
    @IBOutlet var buttonSideConstraints: [NSLayoutConstraint]?
    
    @IBOutlet var constraintsToShrinkOnSmallScreens: [NSLayoutConstraint]?

    private var bottomConstraintConstant: CGFloat?
    private var sideConstraintConstant: CGFloat?

    internal var deviceType: ParticleDeviceType?
    internal var networkName: String?
    internal var deviceName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setCommonStyle()
        setStyle()

        //so that constraints are properly disabled
        setContent()
    }

    private func setCommonStyle() {
        if (MeshScreenUtils.isIPhone() && (MeshScreenUtils.getPhoneScreenSizeClass() <= .iPhone5)) {
            if let constraints = constraintsToShrinkOnSmallScreens {
                for constraint in constraints {
                    constraint.constant = constraint.constant / 2
                }
            }
        }

        view.backgroundColor = MeshSetupStyle.ViewBackgroundColor
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

    open func setStyle() {
        fatalError("Not implemented")
    }

    open func setContent() {
        fatalError("Not implemented")
    }

    func replacePlaceHolderStrings() {
        view.replaceMeshSetupStrings(deviceType: self.deviceType?.description, networkName: networkName, deviceName: deviceName)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let constraint = buttonBottomConstraint {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
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

    @objc func keyboardWillHide(notification: NSNotification) {
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
