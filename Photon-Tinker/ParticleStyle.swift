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

}

class ParticleLabel: UILabel {
    func setStyle(font: String, size: Int, color: UIColor) {
        self.textColor = color
        self.font = UIFont(name: font, size: CGFloat(size))
    }
}

class MeshSegmentedControl : UISegmentedControl {
    func setStyle(font: String, size: Int, color: UIColor) {
        self.tintColor = color
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: font, size: CGFloat(size))], for: .normal)
    }
}

class MeshTextField: UITextField {
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

class MeshTextView: UITextView {
    func setStyle(font: String, size: Int, color: UIColor) {
        self.textColor = color
        self.font = UIFont(name: font, size: CGFloat(size))
    }
}

class MeshSetupButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3.0
        self.backgroundColor = ParticleStyle.ButtonColor

        self.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 1, blur: 2, spread: 0)
    }

    func setTitle(_ title: String?, for state: UIControlState, upperCase: Bool = true) {
        if (upperCase) {
            super.setTitle(title?.uppercased(), for: state)
        } else {
            super.setTitle(title, for: state)
        }
    }

    func setStyle(font: String, size: Int) {
        self.titleLabel?.font = UIFont(name: font, size: CGFloat(size))

        self.setTitleColor(ParticleStyle.ButtonTitleColor, for: .normal)
        self.setTitleColor(ParticleStyle.ButtonTitleColor, for: .selected)
        self.setTitleColor(ParticleStyle.ButtonTitleColor, for: .highlighted)
        self.setTitleColor(ParticleStyle.ButtonTitleColor.withAlphaComponent(0.5), for: .disabled)

        DispatchQueue.main.async{
            self.tintColor = ParticleStyle.ButtonTitleColor
            self.imageView?.tintColor = ParticleStyle.ButtonTitleColor
        }
    }
}

class MeshSetupRedButton : MeshSetupButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = ParticleStyle.ButtonRedColor
    }
}


class MeshSetupAlternativeButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3.0
        self.backgroundColor = ParticleStyle.AlternativeButtonColor

        self.layer.borderColor = ParticleStyle.AlternativeButtonBorderColor.cgColor
        self.layer.borderWidth = 1

        self.layer.applySketchShadow(color: .black, alpha: 0.3, x: 0, y: 1, blur: 2, spread: 0)
    }

    func setTitle(_ title: String?, for state: UIControlState, upperCase: Bool = true) {
        if (upperCase) {
            super.setTitle(title?.uppercased(), for: state)
        } else {
            super.setTitle(title, for: state)
        }
    }

    func setStyle(font: String, size: Int) {
        self.titleLabel?.font = UIFont(name: font, size: CGFloat(size))

        self.setTitleColor(ParticleStyle.AlternativeButtonTitleColor, for: .normal)
        self.setTitleColor(ParticleStyle.AlternativeButtonTitleColor, for: .selected)
        self.setTitleColor(ParticleStyle.AlternativeButtonTitleColor, for: .highlighted)
        self.setTitleColor(ParticleStyle.AlternativeButtonTitleColor.withAlphaComponent(0.5), for: .disabled)

        DispatchQueue.main.async{
            self.tintColor = ParticleStyle.AlternativeButtonTitleColor
            self.imageView?.tintColor = ParticleStyle.AlternativeButtonTitleColor
        }
    }
}

extension CALayer {
    func applySketchShadow(
            color: UIColor = .black,
            alpha: Float = 0.5,
            x: CGFloat = 0,
            y: CGFloat = 2,
            blur: CGFloat = 4,
            spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}



