//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright (c) 2018 spark. All rights reserved.
//

import Foundation

protocol Storyboardable: class {
    static var storyboardName: String { get }
    static var storyboardId: String { get }
    static var nibName: String { get }

    static func loadedViewController() -> Self

    static func storyboardViewController() -> Self
    static func nibViewController() -> Self?
}

extension Storyboardable where Self: UIViewController {
    static var storyboardName: String {
        return "Main"
    }

    static var storyboardId: String {
        return String(describing: self)
    }

    static var nibName: String {
        return String(describing: self)
    }

    static func loadedViewController() -> Self {
        if let nib = nibViewController() {
            return nib
        } else {
            return storyboardViewController()
        }
    }

    static func storyboardViewController() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)

        guard let vc = storyboard.instantiateViewController(withIdentifier: storyboardId) as? Self else {
            fatalError("Could not instantiate initial storyboard with name: \(storyboardId)")
        }

        return vc
    }

    static func nibViewController() -> Self? {
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            return Self.init(nibName: nibName, bundle: nil)
        } else {
            return nil
        }
    }

}
