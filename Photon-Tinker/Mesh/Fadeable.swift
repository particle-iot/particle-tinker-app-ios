//
// Created by Raimundas Sakalauskas on 2019-04-17.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

protocol Fadeable: class where Self: UIViewController {
    var isBusy: Bool { get set }
    var viewsToFade: [UIView]? { get }

    func fade(animated: Bool)
    func resume(animated: Bool)
}

extension Fadeable {

    func fade(animated: Bool = true) {
        fadeContent(animated: animated)
    }

    func resume(animated: Bool = true) {
        unfadeContent(animated: animated)
    }

    func fadeContent(animated: Bool, showSpinner: Bool = true) {
        self.isBusy = true
        if (showSpinner) {
            ParticleSpinner.show(view)
        }

        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                if let viewsToFade = self.viewsToFade {
                    for childView in viewsToFade {
                        childView.alpha = 0.5
                    }
                }
            }
        } else {
            if let viewsToFade = self.viewsToFade {
                for childView in viewsToFade {
                    childView.alpha = 0.5
                }
            }

            self.view.setNeedsDisplay()
        }
    }

    func unfadeContent(animated: Bool) {
        ParticleSpinner.hide(view, animated: animated)
        self.isBusy = false

        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                if let viewsToFade = self.viewsToFade {
                    for childView in viewsToFade {
                        childView.alpha = 1
                    }
                }
            }
        } else {
            if let viewsToFade = self.viewsToFade {
                for childView in viewsToFade {
                    childView.alpha = 1
                }
            }

            self.view.setNeedsDisplay()
        }
    }

}
