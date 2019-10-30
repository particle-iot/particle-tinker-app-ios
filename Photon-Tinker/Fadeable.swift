//
// Created by Raimundas Sakalauskas on 2019-04-17.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

protocol Fadeable: class {
    var isBusy: Bool { get set }
    var viewsToFade: [UIView]? { get }

    func fade(animated: Bool)
    func resume(animated: Bool)
}

extension Fadeable {

    func getView() -> UIView? {
        if let view = self as? UIView {
            return view
        } else if let vc = self as? UIViewController, let view = vc.view {
            return view
        } else {
            return nil
        }
    }

    func fade(animated: Bool = true) {
        fadeContent(animated: animated)
    }

    func resume(animated: Bool = true) {
        unfadeContent(animated: animated)
    }

    func fadeContent(animated: Bool, showSpinner: Bool = true) {
        self.isBusy = true


        if (showSpinner) {
            if let view = self.getView() {
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

                if let view = self.getView() {
                    view.setNeedsDisplay()
                }
            }
        }
    }

    func unfadeContent(animated: Bool) {
        if let view = self.getView() {
            ParticleSpinner.hide(view, animated: animated)
        }
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

            if let view = self.getView() {
                view.setNeedsDisplay()
            }
        }
    }

}
