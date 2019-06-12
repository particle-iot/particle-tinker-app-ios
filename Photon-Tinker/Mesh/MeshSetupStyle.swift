//
// Created by Raimundas Sakalauskas on 18/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

class MeshSetupStyle {

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
    static var PrimaryTextColor = UIColor.colorWithHexString("#333333")
    static var SecondaryTextColor = UIColor.colorWithHexString("#B1B1B1")
    static var DetailsTextColor = UIColor.colorWithHexString("#8A8A8F")
    static var RedTextColor = UIColor.colorWithHexString("#ED1C24")

    static var DisclosureIndicatorColor = UIColor.colorWithHexString("#B1B1B1")

    static var BillingTextColor = UIColor.colorWithHexString("#76777A")
    static var StrikeThroughColor = UIColor.colorWithHexString("#002F87")

    static var DisabledTextColor = UIColor.colorWithHexString("#A9A9A9")
    static var PlaceHolderTextColor = UIColor.colorWithHexString("#A9A9A9")

    static var InputTitleColor = UIColor.colorWithHexString("#777777")
    static var NoteBackgroundColor = UIColor.colorWithHexString("#F7F7F7")
    static var NoteBorderColor = UIColor.colorWithHexString("#C7C7C7")

    static var ProgressBarProgressColor = UIColor.colorWithHexString("#02ADEF")
    static var ProgressBarTrackColor = UIColor.colorWithHexString("#F5F5F5")

    static var EthernetToggleBackgroundColor = UIColor.colorWithHexString("#F5F5F5")
    static var ViewBackgroundColor = UIColor.colorWithHexString("#FFFFFF")


    static var AlternativeButtonColor = UIColor.colorWithHexString("#FFFFFF")
    static var AlternativeButtonBorderColor = UIColor.colorWithHexString("#02ADEF")
    static var AlternativeButtonTitleColor = UIColor.colorWithHexString("#02ADEF")

    static var ButtonColor = UIColor.colorWithHexString("#02ADEF")
    static var ButtonRedColor = UIColor.colorWithHexString("#ED1C24")
    static var ButtonTitleColor = UIColor.colorWithHexString("#FFFFFF")

    static var TableViewBackgroundColor = UIColor.colorWithHexString("#EFEFF4")
    static var CellSeparatorColor = UIColor.colorWithHexString("#BCBBC1")
    static var CellHighlightColor = UIColor.colorWithHexString("#F5F5F5")




    static var PairingActivityIndicatorColor = UIColor.colorWithHexString("#02ADEF")
    static var NetworkScanActivityIndicatorColor = UIColor.colorWithHexString("#333333")
    static var NetworkJoinActivityIndicatorColor = UIColor.colorWithHexString("#333333")
    static var ProgressActivityIndicatorColor = UIColor.colorWithHexString("#333333")

}

class MeshLabel : UILabel {
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
        superview?.layer.borderColor = MeshSetupStyle.NoteBorderColor.cgColor
        superview?.layer.borderWidth = 1
    }
}

class MeshSetupButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3.0
        self.backgroundColor = MeshSetupStyle.ButtonColor

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

        self.setTitleColor(MeshSetupStyle.ButtonTitleColor, for: .normal)
        self.setTitleColor(MeshSetupStyle.ButtonTitleColor, for: .selected)
        self.setTitleColor(MeshSetupStyle.ButtonTitleColor, for: .highlighted)
        self.setTitleColor(MeshSetupStyle.ButtonTitleColor.withAlphaComponent(0.5), for: .disabled)

        DispatchQueue.main.async{
            self.tintColor = MeshSetupStyle.ButtonTitleColor
            self.imageView?.tintColor = MeshSetupStyle.ButtonTitleColor
        }
    }
}

class MeshSetupRedButton : MeshSetupButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = MeshSetupStyle.ButtonRedColor
    }
}


class MeshSetupAlternativeButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3.0
        self.backgroundColor = MeshSetupStyle.AlternativeButtonColor

        self.layer.borderColor = MeshSetupStyle.AlternativeButtonBorderColor.cgColor
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

        self.setTitleColor(MeshSetupStyle.AlternativeButtonTitleColor, for: .normal)
        self.setTitleColor(MeshSetupStyle.AlternativeButtonTitleColor, for: .selected)
        self.setTitleColor(MeshSetupStyle.AlternativeButtonTitleColor, for: .highlighted)
        self.setTitleColor(MeshSetupStyle.AlternativeButtonTitleColor.withAlphaComponent(0.5), for: .disabled)

        DispatchQueue.main.async{
            self.tintColor = MeshSetupStyle.AlternativeButtonTitleColor
            self.imageView?.tintColor = MeshSetupStyle.AlternativeButtonTitleColor
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

class MeshSetupNoteView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3
        self.backgroundColor = MeshSetupStyle.NoteBackgroundColor

        self.layer.borderColor = MeshSetupStyle.NoteBorderColor.cgColor
        self.layer.borderWidth = 1
    }
}

class MeshCheckBoxButton : UIButton {
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

extension UIColor {
    static func colorWithHexString(_ hexString: String, alpha:CGFloat = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(UIColor.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha

        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }

    private static func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.3
        animation.values = [-15, 15, -7.5, 7.5, 0]
        self.layer.add(animation, forKey: "shake")
    }
}
