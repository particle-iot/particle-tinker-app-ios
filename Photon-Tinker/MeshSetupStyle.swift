//
// Created by Raimundas Sakalauskas on 18/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

class MeshSetupStyle {

    //fonts
    static var RegularFont: String = "Gotham-Book"
    static var SemiBoldFont: String = "Gotham-Medium"
    static var BoldFont: String = "Gotham-Medium"

    //text sizes
    static var DetailSize = 12
    static var SmallSize = 14
    static var RegularSize = 16
    static var LargeSize = 18
    static var ExtraLargeSize = 22

    //colors
    static var PrimaryTextColor = UIColor.colorWithHexString("#333333")
    static var SecondaryTextColor = UIColor.colorWithHexString("#B1B1B1")

    static var DisabledTextColor = UIColor.colorWithHexString("#A9A9A9")
    static var PlaceHolderTextColor = UIColor.colorWithHexString("#A9A9A9")

    static var ButtonColor = UIColor.colorWithHexString("#02ADEF")
    static var ButtonTitleColor = UIColor.colorWithHexString("#FFFFFF")

    static var CellSeparatorColor = UIColor.colorWithHexString("#BCBBC1")
    static var CellHighlightColor = UIColor.colorWithHexString("#02ADEF")

    static var GrayBackgroundColor = UIColor.colorWithHexString("#F5F5F5")
    static var ViewBackgroundColor = UIColor.colorWithHexString("#FFFFFF")
}

class MeshLabel : UILabel {
    func setStyle(font: String, size: Int, color: UIColor) {
        self.textColor = color
        self.font = UIFont(name: font, size: CGFloat(size))
    }
}

class MeshSetupButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3.0
        self.backgroundColor = MeshSetupStyle.ButtonColor

        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.layer.shadowOpacity = 1.0

    }

    func setStyle(font: String, size: Int, color: UIColor) {
        self.titleLabel?.font = UIFont(name: font, size: CGFloat(size))

        self.setTitleColor(color, for: .normal)
        self.setTitleColor(color, for: .selected)
        self.setTitleColor(color, for: .highlighted)

        self.tintColor = color
    }
}

extension String {
    func meshLocalized() -> String {
        return NSLocalizedString(self, tableName: "MeshSetupStrings", comment: "")
    }
}

extension UIColor {
    static func colorWithHexString(_ hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(UIColor.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!

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