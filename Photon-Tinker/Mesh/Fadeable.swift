//
// Created by Raimundas Sakalauskas on 2019-04-17.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

protocol Fadeable: class where Self: UIViewController {
    var isBusy: Bool { get set }
    var viewsToFade: [UIView]? { get }

    func fade()
    func resume(animated: Bool)
}

extension Fadeable {

    func fade() {
        self.isBusy = true

        ParticleSpinner.show(view)
        fadeContent()
    }

    func resume(animated: Bool) {
        ParticleSpinner.hide(view, animated: animated)
        unfadeContent(animated: true)

        self.isBusy = false
    }

    func fadeContent() {
        UIView.animate(withDuration: 0.25) { () -> Void in
            if let viewsToFade = self.viewsToFade {
                for childView in viewsToFade {
                    childView.alpha = 0.5
                }
            }
        }
    }

    func unfadeContent(animated: Bool) {
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
