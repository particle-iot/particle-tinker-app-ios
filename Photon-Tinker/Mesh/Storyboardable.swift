//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

protocol Storyboardable: class {
    static var storyboardName: String { get }
    static func storyboardViewController() -> Self
}

extension Storyboardable where Self: UIViewController {
    static var storyboardName: String {
        return String(describing: self)
    }

    static func storyboardViewController() -> Self {
        let storyboard = UIStoryboard(name: "MeshSetup", bundle: nil)

        guard let vc = storyboard.instantiateViewController(withIdentifier: storyboardName) as? Self else {
            fatalError("Could not instantiate initial storyboard with name: \(storyboardName)")
        }

        return vc
    }
}
