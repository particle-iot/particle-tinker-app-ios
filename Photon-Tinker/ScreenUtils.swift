//
// Created by Raimundas Sakalauskas on 03/10/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

enum PhoneScreenSizeClass: Int, Comparable {
    case iPhone4
    case iPhone5
    case iPhone6
    case iPhone6Plus
    case iPhoneX
    case iPhoneXMax
    case other

    public static func < (a: PhoneScreenSizeClass, b: PhoneScreenSizeClass) -> Bool {
        return a.rawValue < b.rawValue
    }
}

class ScreenUtils {

    static func isIPad() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }

    static func isIPhone() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == .phone
    }

    static func getPhoneScreenSizeClass() -> PhoneScreenSizeClass {
        let screenSize = UIScreen.main.bounds.size
        let maxLength = max(screenSize.width, screenSize.height)

        if (maxLength <= 480) {
            return .iPhone4
        } else if (maxLength <= 568) {
            return .iPhone5
        } else if (maxLength <= 667) {
            return .iPhone6
        } else if (maxLength <= 736) {
            return .iPhone6Plus
        } else if (maxLength <= 812) {
            return .iPhoneX
        } else if (maxLength <= 896) {
            return .iPhoneXMax
        } else {
            return .other
        }
    }
}