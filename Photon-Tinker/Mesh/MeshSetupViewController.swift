//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupViewController: UIViewController {

    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint?

    private var bottomConstraintConstant: CGFloat?

    internal var deviceType: ParticleDeviceType?
    internal var networkName: String?
    internal var deviceName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setCommonStyle()
        setStyle()
    }

    private func setCommonStyle() {
        view.backgroundColor = MeshSetupStyle.ViewBackgroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let constraint = buttonBottomConstraint {
            bottomConstraintConstant = constraint.constant
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

                var safeAreaMargin:CGFloat = 0
                if #available(iOS 11.0, *) {
                    safeAreaMargin = view.safeAreaInsets.bottom
                }

                constraint.constant = keyboardSize.height + bottomConstraintConstant! - safeAreaMargin
                UIView.animate(withDuration: 0.25) { () -> Void in
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let constraint = buttonBottomConstraint {
            constraint.constant = bottomConstraintConstant!
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.view.layoutIfNeeded()
            }
        }
    }
}
