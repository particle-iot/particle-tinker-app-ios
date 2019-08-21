//
// Created by Raimundas Sakalauskas on 2019-08-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

protocol SearchBarViewDelegate: class {
    func searchBarTextDidChange(searchBar: SearchBarView, text: String?)

    func searchBarDidBeginEditing(searchBar: SearchBarView)
    func searchBarDidEndEditing(searchBar: SearchBarView)
}

class SearchBarView: UIView, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var inputText: CustomizableTextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!

    weak var delegate: SearchBarViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.clear

        backgroundView.backgroundColor = ParticleStyle.EthernetToggleBackgroundColor
        backgroundView.layer.masksToBounds = true

        inputText.font = UIFont(name: ParticleStyle.RegularFont, size: CGFloat(ParticleStyle.RegularSize))
        inputText.textColor = ParticleStyle.PrimaryTextColor
        inputText.borderStyle = .none
        inputText.clearButtonMode = .whileEditing
        inputText.tintColor = ParticleStyle.ButtonColor
        inputText.placeholder = ""
        inputText.placeholderColor = ParticleStyle.SecondaryTextColor
        inputText.clearButtonTintColor = ParticleStyle.ClearButtonColor
        inputText.text = ""
        inputText.delegate = self

        cancelButton.alpha = 0
        cancelButton.isHidden = true
        cancelButton.isEnabled = false
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        NotificationCenter.default.removeObserver(self)

        if let superview = newSuperview {
            NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: Notification.Name.UITextFieldTextDidChange, object: self.inputText)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundView.layer.cornerRadius = backgroundView.frame.height / 2
    }

    @IBAction func cancelClicked() {
        inputText.text = ""

        self.endEditing(true)
        hideCancel()

        textChanged()
    }

    private func showCancel() {
        cancelButton.alpha = 0
        cancelButton.isHidden = false
        cancelButton.isEnabled = true

        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
            self.cancelButton.alpha = 1
        }
    }

    private func hideCancel() {
        cancelButton.alpha = 1
        cancelButton.isEnabled = false

        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.cancelButton.alpha = 0

        }, completion: { b in
            self.cancelButton.isHidden = true
        })
    }

    @objc
    public func textChanged() {
        if var searchTerm = inputText.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), searchTerm.count > 0 {
            self.delegate?.searchBarTextDidChange(searchBar: self, text: searchTerm)
        } else {
            self.delegate?.searchBarTextDidChange(searchBar: self, text: nil)
        }
    }

    //MARK: TextField Delegate
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchBarDidBeginEditing(searchBar: self)
        showCancel()
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let value = textField.text {
            textField.text = value.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        }
        delegate?.searchBarDidEndEditing(searchBar: self)

        if (textField.text?.isEmpty ?? false) {
            hideCancel()
        }
    }
}

class CustomizableTextField: UITextField {
    var placeholderColor: UIColor? = nil {
        didSet {
            evalPlaceholderColor()
        }
    }

    override var placeholder: String? {
        get {
            return super.placeholder
        }
        set {
            super.placeholder = newValue
            evalPlaceholderColor()
        }
    }

    var clearButtonTintColor: UIColor? = nil {
        didSet {
            evalClearButtonTintColor()
        }
    }

    func evalPlaceholderColor() {
        if let placeholder = placeholder, let placeHolderColor = placeholderColor {
            attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes: [
                NSAttributedStringKey.foregroundColor: placeHolderColor,
                NSAttributedStringKey.font: UIFont(name: ParticleStyle.RegularFont, size: CGFloat(ParticleStyle.RegularSize))!
            ])
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        evalClearButtonTintColor()
    }

    private func evalClearButtonTintColor() {
        for view in subviews as [UIView] {
            if view is UIButton {
                let button = view as! UIButton

                if let clearButtonTintColor = clearButtonTintColor {
                    let tintedImage = UIImage(named: "ClearIcon")!.image(withColor: clearButtonTintColor)

                    button.setImage(tintedImage, for: .normal)
                    button.setImage(tintedImage, for: .highlighted)
                }
            }
        }
    }
}
