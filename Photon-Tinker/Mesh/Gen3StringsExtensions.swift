//
// Created by Raimundas Sakalauskas on 18/09/2018.
// Copyright (c) 2018 Particle. All rights reserved.
//

import Foundation


extension UIView {
    open func replaceGen3SetupStrings(deviceType : String? = nil, networkName : String? = nil, deviceName : String? = nil) {
        let subviews = self.subviews

        for subview in subviews {
            if subview is UILabel {
                let label = subview as! UILabel
                label.text = label.text?.replaceGen3SetupStrings(deviceType: deviceType, networkName: networkName, deviceName: deviceName)
            } else if (subview is ParticleButton) {
                let button = subview as! ParticleButton
                button.setTitle(button.currentTitle?.replaceGen3SetupStrings(deviceType: deviceType, networkName: networkName, deviceName: deviceName), for: .normal)
            } else if (subview is UIView) {
                subview.replaceGen3SetupStrings(deviceType: deviceType, networkName: networkName, deviceName: deviceName)
            }
        }
    }
}




extension String {
    func gen3SetupLocalized() -> String {
        return NSLocalizedString(self, tableName: "Gen3SetupStrings", comment: "")
    }

    func replaceGen3SetupStrings(deviceType : String? = nil, networkName : String? = nil, deviceName : String? = nil) -> String {
        var string = self

        if let t = deviceType {
            string = string.replacingOccurrences(of: "{{device}}", with: t.description, options: CompareOptions.caseInsensitive)
        } else {
            string = string.replacingOccurrences(of: "{{device}}", with: Gen3SetupStrings.Default.DeviceType, options: CompareOptions.caseInsensitive)
        }

        if let n = networkName {
            string = string.replacingOccurrences(of: "{{network}}", with: n, options: CompareOptions.caseInsensitive)
        }

        if let d = deviceName {
            string = string.replacingOccurrences(of: "{{deviceName}}", with: d, options: CompareOptions.caseInsensitive)
        }

        return string
    }
}

extension Gen3SetupStrings {
    static private let randomNames = ["aardvark", "bacon", "badger", "banjo", "bobcat", "boomer", "captain", "chicken", "cowboy", "maker", "splendid", "sparkling", "dentist", "doctor", "green", "easter", "ferret", "gerbil", "hacker", "hamster", "wizard", "hobbit", "hoosier", "hunter", "jester", "jetpack", "kitty", "laser", "lawyer", "mighty", "monkey", "morphing", "mutant", "narwhal", "ninja", "normal", "penguin", "pirate", "pizza", "plumber", "power", "puppy", "ranger", "raptor", "robot", "scraper", "burrito", "station", "tasty", "trochee", "turkey", "turtle", "vampire", "wombat", "zombie"]

    static func getRandomDeviceName() -> String {
        return "\(Gen3SetupStrings.randomNames.randomElement()!)_\(Gen3SetupStrings.randomNames.randomElement()!)"
    }
}
