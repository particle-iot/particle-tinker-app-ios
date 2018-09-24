//
//  MeshSetupViewController.swift
//  
//
//  Created by Ido Kleinman on 6/19/18.
//

import UIKit

class MeshSetupViewController: UIViewController {


    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint?


    private var bottomConstraintConstant: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let constraint = buttonBottomConstraint {
            bottomConstraintConstant = constraint.constant
        }
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
