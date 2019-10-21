//
// Created by Raimundas Sakalauskas on 18/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

class ParticleStyle {

    //fonts
    static var RegularFont: String = "AvenirNext-Regular"
    static var ItalicFont: String = "AvenirNext-Italic"
    static var BoldFont: String = "AvenirNext-DemiBold"

    //text sizes
    static var DetailSize = 12
    static var SmallSize = 14
    static var RegularSize = 16
    static var LargeSize = 18
    static var ExtraLargeSize = 22
    static var PriceSize = 48

    //colors
    static var PrimaryTextColor = UIColor(rgb: 0x333333)
    static var SecondaryTextColor = UIColor(rgb: 0xB1B1B1)
    static var DetailsTextColor = UIColor(rgb: 0x8A8A8F)
    static var RedTextColor = UIColor(rgb: 0xED1C24)

    static var DisclosureIndicatorColor = UIColor(rgb: 0xB1B1B1)

    static var BillingTextColor = UIColor(rgb: 0x76777A)
    static var StrikeThroughColor = UIColor(rgb: 0x002F87)

    static var DisabledTextColor = UIColor(rgb: 0xA9A9A9)
    static var PlaceHolderTextColor = UIColor(rgb: 0xA9A9A9)

    static var InputTitleColor = UIColor(rgb: 0x777777)
    static var NoteBackgroundColor = UIColor(rgb: 0xF7F7F7)

    static var NoteBorderColor = UIColor(rgb: 0xC7C7C7)

    static var ProgressBarProgressColor = UIColor(rgb: 0x02ADEF)
    static var ProgressBarTrackColor = UIColor(rgb: 0xF5F5F5)

    static var EthernetToggleBackgroundColor = UIColor(rgb: 0xF5F5F5)
    static var ViewBackgroundColor = UIColor(rgb: 0xFFFFFF)


    static var AlternativeButtonColor = UIColor(rgb: 0xFFFFFF)
    static var AlternativeButtonBorderColor = UIColor(rgb: 0x02ADEF)
    static var AlternativeButtonTitleColor = UIColor(rgb: 0x02ADEF)


    static var ButtonColor = UIColor(rgb: 0x02ADEF)
    static var ButtonRedColor = UIColor(rgb: 0xED1C24)
    static var ButtonTitleColor = UIColor(rgb: 0xFFFFFF)

    static var TableViewBackgroundColor = UIColor(rgb: 0xEFEFF4)
    static var CellSeparatorColor = UIColor(rgb: 0xBCBBC1)
    static var CellHighlightColor = UIColor(rgb: 0xF5F5F5)




    static var PairingActivityIndicatorColor = UIColor(rgb: 0x02ADEF)
    static var NetworkScanActivityIndicatorColor = UIColor(rgb: 0x333333)
    static var NetworkJoinActivityIndicatorColor = UIColor(rgb: 0x333333)
    static var ProgressActivityIndicatorColor = UIColor(rgb: 0x333333)


    static var ClearButtonColor = UIColor(rgb: 0x999999)
    static var FilterBorderColor = UIColor(rgb: 0xD9D8D6)

}

class ParticleLabel: UILabel {
    func setStyle(font: String, size: Int, color: UIColor) {
        self.textColor = color
        self.font = UIFont(name: font, size: CGFloat(size))
    }
}

class ParticleSegmentedControl: UISegmentedControl {
    func setStyle(font: String, size: Int, color: UIColor) {
        self.tintColor = color
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: font, size: CGFloat(size))], for: .normal)
    }
}

class ParticleTextField: UITextField {
    func setStyle(font: String, size: Int, color: UIColor) {
        self.textColor = color
        self.font = UIFont(name: font, size: CGFloat(size))
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        superview?.layer.cornerRadius = 3
        superview?.layer.borderColor = ParticleStyle.NoteBorderColor.cgColor
        superview?.layer.borderWidth = 1
    }
}

class ParticleTextView: UITextView {
    func setStyle(font: String, size: Int, color: UIColor) {
        self.textColor = color
        self.font = UIFont(name: font, size: CGFloat(size))
    }
}

@IBDesignable class ParticleCustomButton: UIButton {
    @IBInspectable public var upperCase: Bool = true

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3.0
    }

    override func setTitle(_ title: String?, for state: State) {
        if (self.upperCase) {
            super.setTitle(title?.uppercased(), for: state)
        } else {
            super.setTitle(title, for: state)
        }
    }

    func setTitle(_ title: String?, for state: UIControl.State, upperCase: Bool = true) {
        self.upperCase = upperCase
        self.setTitle(title, for: state)
    }

    func setStyle(font: String, size: Int, color: UIColor) {
        self.titleLabel?.font = UIFont(name: font, size: CGFloat(size))

        self.setTitleColor(color, for: .normal)
        self.setTitleColor(color, for: .selected)
        self.setTitleColor(color, for: .highlighted)
        self.setTitleColor(color.withAlphaComponent(0.5), for: .disabled)

        DispatchQueue.main.async{
            self.tintColor = color
            self.imageView?.tintColor = color
        }
    }
}

class ParticleButton: ParticleCustomButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = ParticleStyle.ButtonColor
        self.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 1, blur: 2, spread: 0)
    }

    func setStyle(font: String, size: Int) {
        self.setStyle(font: font, size: size, color: ParticleStyle.ButtonTitleColor)
    }
}

class ParticleDestructiveButton: ParticleButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = ParticleStyle.ButtonRedColor
    }
}


class ParticleAlternativeButton: ParticleCustomButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = ParticleStyle.AlternativeButtonColor

        self.layer.borderColor = ParticleStyle.AlternativeButtonBorderColor.cgColor
        self.layer.borderWidth = 1

        self.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 1, blur: 2, spread: 0)
    }

    func setStyle(font: String, size: Int) {
        self.setStyle(font: font, size: size, color: ParticleStyle.AlternativeButtonTitleColor)
    }
}

class ParticleCheckBoxButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.imageEdgeInsets = UIEdgeInsets(top: -15, left: -15, bottom: -15, right: 15)
        self.setBackgroundImage(UIImage(named: "MeshCheckBox"), for: .normal)
        self.setBackgroundImage(UIImage(named: "MeshCheckBoxSelected"), for: .selected)
        self.setBackgroundImage(UIImage(named: "MeshCheckBoxSelected"), for: .highlighted)

        self.tintColor = .clear
    }

    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: (bounds.height-20)/2, width: 20, height: 20)
    }
}

class ParticleNoteView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3
        self.backgroundColor = ParticleStyle.NoteBackgroundColor

        self.layer.borderColor = ParticleStyle.NoteBorderColor.cgColor
        self.layer.borderWidth = 1
    }
}




